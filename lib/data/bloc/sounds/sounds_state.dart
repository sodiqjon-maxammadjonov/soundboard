part of 'sounds_bloc.dart';

@immutable
sealed class SoundsState {}

final class SoundsInitial extends SoundsState {}

final class SoundsSuccessState extends SoundsState {
  final String message;
  SoundsSuccessState(this.message);
}

final class SoundsLoadingProgressState extends SoundsState {
  final List<Sound> loadedSounds;
  final List<Sound> allSounds;
  final Set<int> favoriteIds;
  final String searchQuery;

  SoundsLoadingProgressState({
    required this.loadedSounds,
    this.allSounds = const [],
    required this.favoriteIds,
    this.searchQuery = '',
  });
}

final class SoundsErrorState extends SoundsState {
  final String message;
  SoundsErrorState(this.message);
}