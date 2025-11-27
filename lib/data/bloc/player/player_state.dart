part of 'player_bloc.dart';

@immutable
sealed class SoundPlayerState {}

final class SoundPlayerInitial extends SoundPlayerState {}

final class SoundPlayerPlayingState extends SoundPlayerState {
  final Sound currentSound;
  final Duration position;
  final Duration duration;

  SoundPlayerPlayingState({
    required this.currentSound,
    required this.position,
    required this.duration,
  });
}

final class SoundPlayerStoppedState extends SoundPlayerState {}

final class SoundPlayerErrorState extends SoundPlayerState {
  final String message;
  SoundPlayerErrorState(this.message);
}