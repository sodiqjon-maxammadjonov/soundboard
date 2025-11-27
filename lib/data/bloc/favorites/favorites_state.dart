part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

class FavoritesLoadingState extends FavoritesState{
  final List<Sound> loadedSounds;
  final List<Sound> allSounds;
  final Set<int> favoriteIds;
  final String searchQuery;
  FavoritesLoadingState({
    required this.loadedSounds,
    this.allSounds = const [],
    required this.favoriteIds,
    this.searchQuery = '',
});
}

final class FavoritesErrorState extends FavoritesState{
  final String message;
  FavoritesErrorState(this.message);
}