part of 'similar_bloc.dart';

@immutable
sealed class SimilarEvent {}

final class LoadSimilarSoundsEvent extends SimilarEvent {
  final Sound currentSound;

  LoadSimilarSoundsEvent({required this.currentSound});
}

// class AddFavoriteEvent extends SimilarEvent{
//   final int id;
//   AddFavoriteEvent(this.id);
// }
//
// class RemoveFavoriteEvent extends SimilarEvent{
//   final int id;
//   RemoveFavoriteEvent(this.id);
// }

