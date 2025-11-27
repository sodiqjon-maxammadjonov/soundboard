part of 'sounds_bloc.dart';

@immutable
sealed class SoundsEvent {}

class LoadSoundsEvent extends SoundsEvent{}