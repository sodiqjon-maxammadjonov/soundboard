import 'dart:async';


import '../../library/libray.dart';

abstract class PlayerRepo {
  Future<void> playSound(Sound sound);
  Future<void> stopSound();
  void dispose();
}

class PlayerRepoImpl extends PlayerRepo {
  final Function(SoundPlayerState) emitState;
  final AudioPlayer _player = AudioPlayer();
  Sound? _currentSound;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _stateSubscription;

  PlayerRepoImpl(this.emitState) {
    _initializeListeners();
  }

  void _initializeListeners() {
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (_currentSound != null) {
        _updateState();
      }
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (_currentSound != null) {
        _updateState();
      }
    });

    _player.onPlayerComplete.listen((_) {
      emitState(SoundPlayerStoppedState());
      _currentSound = null;
    });
  }

  Future<void> _updateState() async {
    if (_currentSound == null) return;

    final position = await _player.getCurrentPosition() ?? Duration.zero;
    final duration = await _player.getDuration() ?? _currentSound!.duration ?? Duration.zero;
    final playerState = _player.state;

    if (playerState == PlayerState.playing) {
      emitState(SoundPlayerPlayingState(
        currentSound: _currentSound!,
        position: position,
        duration: duration,
      ));
    }
  }

  @override
  Future<void> playSound(Sound sound) async {
    try {
      // Agar boshqa sound o'ynayotgan bo'lsa, to'xtatamiz
      if (_currentSound != null && _currentSound!.id != sound.id) {
        await _player.stop();
      }

      _currentSound = sound;
      final cleanPath = sound.assetPath.replaceFirst('assets/', '');
      await _player.play(AssetSource(cleanPath));

      await _updateState();
    } catch (e) {
      emitState(SoundPlayerErrorState("Failed to play sound: $e"));
    }
  }

  @override
  Future<void> stopSound() async {
    try {
      await _player.stop();
      emitState(SoundPlayerStoppedState());
      _currentSound = null;
    } catch (e) {
      emitState(SoundPlayerErrorState("Failed to stop sound: $e"));
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
  }
}