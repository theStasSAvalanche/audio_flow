part of 'audio_player_bloc.dart';

@immutable
sealed class AudioPlayerState {}

final class AudioPlayerInitial extends AudioPlayerState {}
final class AudioPlayerPlaying extends AudioPlayerState {}
final class AudioPlayerPaused extends AudioPlayerState {}