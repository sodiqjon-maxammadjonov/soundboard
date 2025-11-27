

import '../../library/libray.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  late final FavoritesRepoImpl _repo;
  FavoritesBloc() : super(FavoritesInitial()) {
    _repo = FavoritesRepoImpl((state) => emit(state));
    on<LoadFavoriteSoundsEvent>(loadFavorites);
    on<RemoveFavoriteFromFavoriteEvent>(removeFavorite);
  }

  FutureOr<void> loadFavorites(
      LoadFavoriteSoundsEvent event,
      Emitter<FavoritesState> state
      ) async {
    await _repo.loadFavoriteSounds(searchQuery: event.searchQuery);
  }

  FutureOr<void> removeFavorite(
      RemoveFavoriteFromFavoriteEvent event,
      Emitter<FavoritesState> state
      ) async {
    await _repo.removeFavorite(event.id);
  }
}
