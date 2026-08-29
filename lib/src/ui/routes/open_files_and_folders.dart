import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart'
    show settings, AudioStatus;
import 'package:audio_flow/src/ui/elements/app_bar.dart' show AudioFlowAppBar;
import 'package:audio_flow/src/ui/elements/bottom_bar.dart'
    show AudioFlowBottomBar;
import 'package:audio_flow/src/ui/elements/left_drawer.dart'
    show AudioFlowDrawer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenFilesAndFolders extends StatelessWidget {
  const OpenFilesAndFolders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
      appBar: AudioFlowAppBar(themeBloc: ThemeBloc()),
      drawer: AudioFlowDrawer(
        playlistNameBloc: PlaylistNameBloc(),
      ), // Left-sided menu
      bottomNavigationBar: AudioFlowBottomBar(
        audioPlayerBloc: AudioPlayerBloc(),
        bottomBarBloc: BottomBarBloc(),
      ),
      floatingActionButtonLocation: .centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (settings.playerStatus == AudioStatus.initial) {
            AudioPlayerBloc().add(
              AudioPlayerPlayEvent(settings.currentTrackNumber),
            );
          } else if (settings.playerStatus == AudioStatus.playing) {
            AudioPlayerBloc().add(AudioPlayerPauseEvent());
          } else if (settings.playerStatus == AudioStatus.paused) {
            AudioPlayerBloc().add(AudioPlayerResumeEvent());
          }
        },
        tooltip: 'Play/Pause',
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          bloc: AudioPlayerBloc(),
          builder: (contextA, stateA) {
            if (stateA is AudioPlayerPlaying) {
              return Icon(Icons.pause);
            }

            return Icon(Icons.play_arrow);
          },
        ),
      ),
    );
  }
}
