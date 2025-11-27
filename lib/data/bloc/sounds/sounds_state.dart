part of 'sounds_bloc.dart';

@immutable
sealed class SoundsState {}

final class SoundsInitial extends SoundsState {}

final class SoundsSuccessState extends SoundsState{
  final String message;
  SoundsSuccessState(this.message);
}

final class SoundsLoadedState extends SoundsState{
  final List<Sound> sounds;
  SoundsLoadedState(this.sounds);
}

final class SoundsErrorState extends SoundsState{
  final String message;
  SoundsErrorState(this.message);
}