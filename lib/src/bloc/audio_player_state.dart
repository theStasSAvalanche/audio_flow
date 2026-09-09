part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final AudioFlowFile? audioTrack;
  final Duration? position;
  final Duration? duration;
  final bool isPlaying;

  const AudioPlayerState({
    this.audioTrack,
    this.position,
    this.duration,
    this.isPlaying = false,
  });

  AudioPlayerState copyWith({
    final AudioFlowFile? audioTrack,
    final Duration? position,
    final Duration? duration,
    final bool? isPlaying,
  }) {
    return AudioPlayerState(
      audioTrack: audioTrack ?? this.audioTrack,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [audioTrack, position, isPlaying];
}