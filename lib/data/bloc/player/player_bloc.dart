import 'dart:async';
import '../../library/libray.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, SoundPlayerState> {
  late final PlayerRepoImpl _repo;

  PlayerBloc() : super(SoundPlayerInitial()) {
    _repo = PlayerRepoImpl((state) => emit(state));

    on<PlaySoundEvent>(playSound);
    on<StopSoundEvent>(stopSound);
  }

  FutureOr<void> playSound(
      PlaySoundEvent event,
      Emitter<SoundPlayerState> emit,
      ) async {
    await _repo.playSound(event.sound);
  }

  FutureOr<void> stopSound(
      StopSoundEvent event,
      Emitter<SoundPlayerState> emit,
      ) async {
    await _repo.stopSound();
  }

  @override
  Future<void> close() {
    _repo.dispose();
    return super.close();
  }
}