import '../../library/libray.dart';

abstract class SoundsRepo {
  Future<List<Sound>> loadSounds({String searchQuery});
  Future<List<int>> getFavorites();
  Future<void> addFavorite(int id);
  Future<void> removeFavorite(int id);
}

class SoundsRepoImpl extends SoundsRepo {
  final Function(SoundsState) emitState;
  List<Sound>? _cachedSounds;

  SoundsRepoImpl(this.emitState);

  @override
  Future<List<Sound>> loadSounds({String searchQuery = ''}) async {
    final List<Sound> baseList = SoundsList.sounds;
    final List<Sound> loadedList = [];
    final favoriteIds = await getFavorites();

    final filteredBaseList = searchQuery.isEmpty
        ? baseList
        : baseList.where((sound) {
      return sound.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredBaseList.isEmpty) {
      emitState(SoundsLoadingProgressState(
        loadedSounds: [],
        allSounds: baseList,
        favoriteIds: favoriteIds.toSet(),
        searchQuery: searchQuery,
      ));
      return [];
    }

    for (int i = 0; i < filteredBaseList.length; i++) {
      final sound = filteredBaseList[i];

      try {
        final updated = await _loadWithDuration(sound);
        final finalSound = updated.copyWith(
          isFavorite: favoriteIds.contains(updated.id),
        );
        loadedList.add(finalSound);
      } catch (e) {
        print("⚠️ Error loading sound ${sound.name}: $e");
        final fallbackSound = sound.copyWith(
          duration: null,
          isFavorite: favoriteIds.contains(sound.id),
        );
        loadedList.add(fallbackSound);
      }

      emitState(SoundsLoadingProgressState(
        loadedSounds: List.from(loadedList),
        allSounds: baseList,
        favoriteIds: favoriteIds.toSet(),
        searchQuery: searchQuery,
      ));
    }

    _cachedSounds = loadedList;

    return loadedList;
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

  @override
  Future<void> addFavorite(int id) async {
    try {
      await FavoritesBox.addFavorite(id);
      final favs = await getFavorites();

      if (_cachedSounds != null) {
        final updatedSounds = _cachedSounds!.map((sound) {
          if (sound.id == id) return sound.copyWith(isFavorite: true);
          return sound;
        }).toList();

        _cachedSounds = updatedSounds;
        emitState(SoundsLoadingProgressState(
          loadedSounds: updatedSounds,
          allSounds: updatedSounds,
          favoriteIds: favs.toSet(),
        ));
      }
    } catch (e) {
      emitState(SoundsErrorState("Error adding favorite"));
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
        emitState(SoundsLoadingProgressState(
          loadedSounds: updatedSounds,
          allSounds: updatedSounds,
          favoriteIds: favs.toSet(),
        ));
      }
    } catch (e) {
      emitState(SoundsErrorState("Error removing favorite"));
    }
  }

  @override
  Future<List<int>> getFavorites() async {
    try {
      final favSet = await FavoritesBox.getFavorites();
      return favSet.toList();
    } catch (e) {
      emitState(SoundsErrorState("Error getting favorites!"));
      return [];
    }
  }
}
