
import '../../library/libray.dart';

part 'similar_event.dart';
part 'similar_state.dart';

class SimilarBloc extends Bloc<SimilarEvent, SimilarState> {

  late final SimilarRepoImpl _repo;
  
  SimilarBloc() : super(SimilarInitial()) {
    _repo = SimilarRepoImpl((state) => emit(state));
    on<LoadSimilarSoundsEvent>(loadSounds);
    // on<AddFavoriteEvent>(addFavorite);
    // on<RemoveFavoriteEvent>(removeFavorite);
    
  }
  FutureOr<void> loadSounds(
      LoadSimilarSoundsEvent event,
      Emitter<SimilarState> emit
      ) async {
    await _repo.loadSimilarSounds(event.currentSound);
  }

  FutureOr<void> addFavorite(
      AddFavoriteEvent event,
      Emitter<SimilarState> emit
      ) async {
    await _repo.addFavorite(event.id);
  }

  FutureOr<void> removeFavorite(
      RemoveFavoriteEvent event,
      Emitter<SimilarState> emit
      ) async {
    await _repo.removeFavorite(event.id);
  }
}
