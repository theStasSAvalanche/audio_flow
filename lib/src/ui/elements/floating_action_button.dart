import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings, AudioStatus;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class AudioFlowFloatingActionButton extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  const AudioFlowFloatingActionButton({super.key, required this.audioPlayerBloc});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        logger.log.d('Settigs player status is ${settings.playerStatus}');
        logger.logNS.d('Audio player BLoC state is ${audioPlayerBloc.state}');
        if (settings.playerStatus == AudioStatus.initial) {
          audioPlayerBloc.add(
            AudioPlayerStartPlayEvent(),
          );
        } else if (settings.playerStatus == AudioStatus.playing) {
          logger.logNS.d('Pause event submitted');
          audioPlayerBloc.add(AudioPlayerPauseEvent());
        } else if (settings.playerStatus == AudioStatus.paused) {
          audioPlayerBloc.add(AudioPlayerResumeEvent());
        }
      },
      tooltip: 'Play/Pause',
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        bloc: audioPlayerBloc,
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (settings.playerStatus == AudioStatus.playing) {
            return Icon(Icons.pause);
          }

          return Icon(Icons.play_arrow);
        },
      ),
    );
  }
}