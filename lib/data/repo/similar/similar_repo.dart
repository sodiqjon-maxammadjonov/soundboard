import 'package:soundboard/data/bloc/similar/similar_bloc.dart' hide SoundsErrorState;

import '../../library/libray.dart';

abstract class SimilarRepo {
  Future<List<Sound>> loadSimilarSounds(Sound currentSound, {int limit = 20});
  Future<List<int>> getFavorites();
  Future<void> addFavorite(int id);
  Future<void> removeFavorite(int id);
}

class SimilarRepoImpl extends SimilarRepo {
  final Function(SimilarState) emitState;
  List<Sound>? _cachedSounds;

  SimilarRepoImpl(this.emitState);

  @override
  Future<List<Sound>> loadSimilarSounds(
      Sound currentSound, {
        int limit = 20,
      }) async {
    final List<Sound> similarSounds = SoundsList.getSimilarSounds(
      currentSound,
      limit: limit,
    );

    final List<Sound> loadedList = [];
    final favoriteIds = await getFavorites();

    if (similarSounds.isEmpty) {
      emitState(SimilarSoundsLoadingProgressState(
        loadedSounds: [],
        allSounds: SoundsList.sounds,
        favoriteIds: favoriteIds.toSet(),
        currentSound: currentSound,
      ));
      return [];
    }

    for (int i = 0; i < similarSounds.length; i++) {
      final sound = similarSounds[i];

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

      // ✅ Progress state emit qilish
      emitState(SimilarSoundsLoadingProgressState(
        loadedSounds: List.from(loadedList),
        allSounds: SoundsList.sounds,
        favoriteIds: favoriteIds.toSet(),
        currentSound: currentSound,
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

        // ✅ Faqat progress state
        emitState(SimilarSoundsLoadingProgressState(
          loadedSounds: updatedSounds,
          allSounds: SoundsList.sounds,
          favoriteIds: favs.toSet(),
          currentSound: _cachedSounds!.first, // yoki saqlab qo'yilgan currentSound
        ));
      }
    } catch (e) {
      emitState(SoundsErrorState("Error adding favorite") as SimilarState);
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

        // ✅ Faqat progress state
        emitState(SimilarSoundsLoadingProgressState(
          loadedSounds: updatedSounds,
          allSounds: SoundsList.sounds,
          favoriteIds: favs.toSet(),
          currentSound: _cachedSounds!.first, // yoki saqlab qo'yilgan currentSound
        ));
      }
    } catch (e) {
      emitState(SoundsErrorState("Error removing favorite") as SimilarState);
    }
  }

  @override
  Future<List<int>> getFavorites() async {
    try {
      final favSet = await FavoritesBox.getFavorites();
      return favSet.toList();
    } catch (e) {
      emitState(SimilarSoundsErrorState("Error getting favorites!") as SimilarState);
      return [];
    }
  }
}