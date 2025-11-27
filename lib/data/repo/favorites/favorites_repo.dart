import '../../library/libray.dart';

abstract class FavoritesRepo {
  Future<List<Sound>> loadFavoriteSounds();
  Future<void> removeFavorite(int id);
}

class FavoritesRepoImpl extends FavoritesRepo {
  final Function(FavoritesState) emitState;
  FavoritesRepoImpl(this.emitState);

  List<Sound>? _cachedSounds;
  @override
  Future<List<Sound>> loadFavoriteSounds({String searchQuery = ''}) async {
    final List<Sound> baseList = SoundsList.sounds;
    final List<int> favoriteIds = await getFavorites();
    final List<Sound> favoriteSounds = [];

    if (favoriteIds.isEmpty) {
      emitState(FavoritesLoadingState(
        loadedSounds: [],
        allSounds: baseList,
        favoriteIds: favoriteIds.toSet(),
        searchQuery: searchQuery,
      ));
      return [];
    }

    final filteredList = baseList.where((sound) {
      final isFavorite = favoriteIds.contains(sound.id);
      final matchesSearch = searchQuery.isEmpty ||
          sound.name.toLowerCase().contains(searchQuery.toLowerCase());
      return isFavorite && matchesSearch;
    }).toList();

    if (filteredList.isEmpty) {
      emitState(FavoritesLoadingState(
        loadedSounds: [],
        allSounds: baseList,
        favoriteIds: favoriteIds.toSet(),
        searchQuery: searchQuery,
      ));
      return [];
    }

    for (final sound in filteredList) {
      try {
        final updated = await _loadWithDuration(sound);
        favoriteSounds.add(updated.copyWith(isFavorite: true));
      } catch (e) {
        print("⚠️ Error loading favorite sound ${sound.name}: $e");
        favoriteSounds.add(sound.copyWith(duration: null, isFavorite: true));
      }

      emitState(FavoritesLoadingState(
        loadedSounds: List.from(favoriteSounds),
        allSounds: baseList,
        favoriteIds: favoriteIds.toSet(),
        searchQuery: searchQuery,
      ));
    }

    _cachedSounds = favoriteSounds;

    return favoriteSounds;
  }

  Future<Sound> _loadWithDuration(Sound sound) async {
    final player = AudioPlayer();
    try {
      final cleanPath = sound.assetPath.replaceFirst('assets/', '');
      await player.setSource(AssetSource(cleanPath));
      final duration = await player.getDuration();
      await player.dispose();
      return sound.copyWith(duration: duration);
    } catch (e) {
      await player.dispose();
      throw e;
    }
  }


  Future<List<int>> getFavorites() async {
    try {
      final favSet = await FavoritesBox.getFavorites();
      return favSet.toList();
    } catch (e) {
      emitState(FavoritesErrorState("Error getting favorites!"));
      return [];
    }
  }

  @override
  Future<void> removeFavorite(int id) async {
    try {
      await FavoritesBox.removeFavorite(id);
      final favs = await getFavorites();

      if (_cachedSounds != null) {
        final updatedSounds = _cachedSounds!.map((sound) {
          if (sound.id == id) return sound.copyWith(isFavorite: false);
          return sound;
        }).toList();

        _cachedSounds = updatedSounds;
        emitState(FavoritesLoadingState(
          loadedSounds: updatedSounds,
          allSounds: updatedSounds,
          favoriteIds: favs.toSet(),
        ));
      }
    } catch (e) {
      emitState(FavoritesErrorState("Error removing favorite"));
    }
  }
}