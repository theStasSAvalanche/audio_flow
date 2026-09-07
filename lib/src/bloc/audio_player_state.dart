part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final AudioFlowFile? audioTrack;
  final Duration? position;
  final bool isPlaying;

  const AudioPlayerState({
    this.audioTrack,
    this.position = Duration.zero,
    this.isPlaying = false,
  });

  AudioPlayerState copyWith({
    final AudioFlowFile? audioTrack,
    final Duration? position,
    final bool? isPlaying,
  }) {
    return AudioPlayerState(
      audioTrack: audioTrack ?? this.audioTrack,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [audioTrack, position, isPlaying];
}

final class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial() : super(isPlaying: false);
}

final class AudioPlayerStartPlaying extends AudioPlayerState {
  const AudioPlayerStartPlaying({
    required super.audioTrack,
  }) : super(position: Duration.zero, isPlaying: true);

  @override
  AudioPlayerStartPlaying copyWith({
    final AudioFlowFile? audioTrack,
    final Duration? position,
    final bool? isPlaying,
  }) {
    return AudioPlayerStartPlaying(
      audioTrack: audioTrack ?? this.audioTrack,
    );
  }
}

final class AudioPlayerPaused extends AudioPlayerState {
  const AudioPlayerPaused({required super.audioTrack, required super.position})
    : super(isPlaying: false);

  @override
  AudioPlayerPaused copyWith({
    final AudioFlowFile? audioTrack,
    final Duration? position,
    final bool? isPlaying,
  }) {
    return AudioPlayerPaused(
      audioTrack: audioTrack ?? this.audioTrack,
      position: position ?? this.position,
    );
  }
}

final class AudioPlayerPlayingProgress extends AudioPlayerState {
  const AudioPlayerPlayingProgress({required super.audioTrack, required super.position})
    : super(isPlaying: true);

  @override
  AudioPlayerPlayingProgress copyWith({
    final AudioFlowFile? audioTrack,
    final Duration? position,
    final bool? isPlaying,
  }) {
    return AudioPlayerPlayingProgress(
      audioTrack: audioTrack ?? this.audioTrack,
      position: position ?? this.position,
    );
  }
}
