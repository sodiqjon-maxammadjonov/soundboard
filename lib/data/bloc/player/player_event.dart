part of 'player_bloc.dart';

@immutable
sealed class PlayerEvent {}

final class PlaySoundEvent extends PlayerEvent {
  final Sound sound;
  PlaySoundEvent(this.sound);
}

final class StopSoundEvent extends PlayerEvent {}