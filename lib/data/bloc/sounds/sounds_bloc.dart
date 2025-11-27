import 'dart:async';

import 'package:soundboard/data/bloc/favorites/favorites_bloc.dart';
import 'package:soundboard/data/library/libray.dart';
import 'package:soundboard/data/repo/sounds/sounds_repo.dart';

part 'sounds_event.dart';
part 'sounds_state.dart';

class SoundsBloc extends Bloc<SoundsEvent, SoundsState> {

  late final SoundsRepoImpl _repo;

  SoundsBloc() : super(SoundsInitial()) {
    _repo = SoundsRepoImpl((state) => emit(state));
    on<LoadSoundsEvent>(loadSounds);
    on<AddFavoriteEvent>(addFavorite);
    on<RemoveFavoriteEvent>(removeFavorite);
  }

  FutureOr<void> loadSounds(
      LoadSoundsEvent event,
      Emitter<SoundsState> emit
      ) async {
    await _repo.loadSounds(searchQuery: event.searchQuery);
  }

  FutureOr<void> addFavorite(
      AddFavoriteEvent event,
      Emitter<SoundsState> emit
      ) async {
    await _repo.addFavorite(event.id);
  }

  FutureOr<void> removeFavorite(
      RemoveFavoriteEvent event,
      Emitter<SoundsState> emit
      ) async {
    await _repo.removeFavorite(event.id);
  }
}