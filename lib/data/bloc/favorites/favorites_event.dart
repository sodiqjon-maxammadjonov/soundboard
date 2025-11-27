part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesEvent {}

final class LoadFavoriteSoundsEvent extends FavoritesEvent {
  final String searchQuery;
  LoadFavoriteSoundsEvent({this.searchQuery = ''});
}

class RemoveFavoriteFromFavoriteEvent extends FavoritesEvent{
  final int id;
  RemoveFavoriteFromFavoriteEvent(this.id);
}

