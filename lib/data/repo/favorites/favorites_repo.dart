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
    final List<int> favoriteIds = await getFavorites(); // Bu tartiblangan!
    final List<Sound> favoriteSounds = [];

    if (favoriteIds.isEmpty) {
      _cachedSounds = null; // ✅ Cache ni tozalaymiz
      emitState(
        FavoritesLoadingState(
          loadedSounds: [],
          allSounds: baseList,
          favoriteIds: favoriteIds.toSet(),
          searchQuery: searchQuery,
        ),
      );
      return [];
    }

    // ✅ favoriteIds tartibida soundlarni olamiz
    final filteredList = <Sound>[];
    for (final id in favoriteIds) {
      try {
        final sound = baseList.firstWhere((s) => s.id == id);

        // Search filterni qo'llaymiz
        final matchesSearch = searchQuery.isEmpty ||
            sound.name.toLowerCase().contains(searchQuery.toLowerCase());

        if (matchesSearch) {
          filteredList.add(sound);
        }
      } catch (e) {
        print("⚠️ Sound with id $id not found in baseList");
      }
    }

    if (filteredList.isEmpty) {
      _cachedSounds = null; // ✅ Cache ni tozalaymiz
      emitState(
        FavoritesLoadingState(
          loadedSounds: [],
          allSounds: baseList,
          favoriteIds: favoriteIds.toSet(),
          searchQuery: searchQuery,
        ),
      );
      return [];
    }

    // Duration bilan yuklash
    for (final sound in filteredList) {
      try {
        final updated = await _loadWithDuration(sound);
        favoriteSounds.add(updated.copyWith(isFavorite: true));
      } catch (e) {
        print("⚠️ Error loading favorite sound ${sound.name}: $e");
        favoriteSounds.add(sound.copyWith(duration: null, isFavorite: true));
      }

      emitState(
        FavoritesLoadingState(
          loadedSounds: List.from(favoriteSounds),
          allSounds: baseList,
          favoriteIds: favoriteIds.toSet(),
          searchQuery: searchQuery,
        ),
      );
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
      final favList = await FavoritesBox.getFavorites();
      return favList;
    } catch (e) {
      emitState(FavoritesErrorState("Error getting favorites!"));
      return [];
    }
  }

  @override
  Future<void> removeFavorite(int id) async {
    try {
      await FavoritesBox.removeFavorite(id);

      _cachedSounds = null;
      await loadFavoriteSounds();

    } catch (e) {
      emitState(FavoritesErrorState("Error removing favorite"));
    }
  }
}