part of 'audio_player_bloc.dart';

@immutable
sealed class AudioPlayerState {
  final int _trackNumber;
  const AudioPlayerState(this._trackNumber);

  int get trackNumber => _trackNumber;
}

final class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial() : super(-1);
}
final class AudioPlayerPlaying extends AudioPlayerState {
  AudioPlayerPlaying() : super(settings.currentTrackNumber);
}
final class AudioPlayerPaused extends AudioPlayerState {
  AudioPlayerPaused() : super(settings.currentTrackNumber);
}
