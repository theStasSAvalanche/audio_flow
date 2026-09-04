import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings, AudioStatus;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class AudioFlowFloatingActionButton extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  const AudioFlowFloatingActionButton({super.key, required this.audioPlayerBloc});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (settings.playerStatus == AudioStatus.initial) {
          audioPlayerBloc.add(
            AudioPlayerPlayEvent(settings.currentTrackNumber),
          );
        } else if (settings.playerStatus == AudioStatus.playing) {
          audioPlayerBloc.add(AudioPlayerPauseEvent());
        } else if (settings.playerStatus == AudioStatus.paused) {
          audioPlayerBloc.add(AudioPlayerResumeEvent());
        }
      },
      tooltip: 'Play/Pause',
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        bloc: audioPlayerBloc,
        builder: (contextA, stateA) {
          if (stateA is AudioPlayerPlaying) {
            return Icon(Icons.pause);
          }

          return Icon(Icons.play_arrow);
        },
      ),
    );
  }
}