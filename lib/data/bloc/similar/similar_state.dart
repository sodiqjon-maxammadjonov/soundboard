part of 'similar_bloc.dart';

@immutable
sealed class SimilarState {}

final class SimilarInitial extends SimilarState {}

final class SimilarSoundsLoadingProgressState extends SimilarState {
  final List<Sound> loadedSounds;
  final List<Sound> allSounds;
  final Set<int> favoriteIds;
  final Sound currentSound;

  SimilarSoundsLoadingProgressState({
    required this.loadedSounds,
    this.allSounds = const [],
    required this.favoriteIds,
    required this.currentSound,
  });
}

final class SimilarSoundsErrorState extends SimilarState {
  final String message;
  SimilarSoundsErrorState(this.message);
}