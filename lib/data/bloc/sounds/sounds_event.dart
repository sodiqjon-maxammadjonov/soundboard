part of 'sounds_bloc.dart';

@immutable
sealed class SoundsEvent {}

final class LoadSoundsEvent extends SoundsEvent {
  final String searchQuery;
  LoadSoundsEvent({this.searchQuery = ''});
}

class AddFavoriteEvent extends SoundsEvent{
  final int id;
  AddFavoriteEvent(this.id);
}

class RemoveFavoriteEvent extends SoundsEvent{
  final int id;
  RemoveFavoriteEvent(this.id);
}

