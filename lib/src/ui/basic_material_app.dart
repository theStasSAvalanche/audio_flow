import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/permission_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart'
    show AudioStatus, settings;
import 'package:audio_flow/src/configuration/logger.dart';
import 'package:audio_flow/src/ui/theme.dart' show darkTheme, lightTheme;
import 'package:audio_flow/src/ui/routes/main_page.dart'
    show AudioFlowScrollController;
import 'package:audio_flow/src/ui/elements/app_bar.dart' show AudioFlowAppBar;
import 'package:audio_flow/src/ui/elements/bottom_bar.dart'
    show AudioFlowBottomBar;
import 'package:audio_flow/src/ui/elements/left_drawer.dart'
    show AudioFlowDrawer;
import 'package:permission_handler/permission_handler.dart';

class AudioFlowApp extends StatelessWidget {
  const AudioFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AudioFlowMaterial();
  }
}

class AudioFlowMaterial extends StatelessWidget {
  const AudioFlowMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    logger.log.d('Start building MaterialApp widget');
    final themeBloc = ThemeBloc();
    final audioPlayerBloc = AudioPlayerBloc();
    final bottomBarBloc = BottomBarBloc();
    final playlistFilesBloc = PlaylistFilesBloc();
    final playlistNameBloc = PlaylistNameBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => themeBloc),
        BlocProvider<AudioPlayerBloc>(create: (context) => audioPlayerBloc),
        BlocProvider<BottomBarBloc>(create: (context) => bottomBarBloc),
        BlocProvider<PlaylistFilesBloc>(create: (context) => playlistFilesBloc),
        BlocProvider<PlaylistNameBloc>(create: (context) => playlistNameBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        bloc: themeBloc,
        builder: (contextT, stateT) {
          return MaterialApp(
            debugShowCheckedModeBanner: settings.isDebug,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: stateT,
            home: Scaffold(
              appBar: AudioFlowAppBar(themeBloc: themeBloc),
              body: SafeArea(
                child: BlocProvider(
                  create: (context) => PermissionBloc(),
                  child: BlocBuilder<PermissionBloc, PermissionState>(
                    builder: (context, state) {
                      if (state is PermissionGranted) {
                        // Next Widgets chain associated with songs list builder
                        settings.isAudioFilesPermissionGranted = true;
                        return AudioFlowScrollController(
                          audioPlayerBloc: audioPlayerBloc,
                          scrollController: ScrollController(),
                          playlistFilesBloc: playlistFilesBloc,
                          playlistNameBloc: playlistNameBloc,
                        );
                      }
                      
                      else if (state is PermissionDenied) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Permission Denied. Please enable it in settings.",
                              ),
                              ElevatedButton(
                                onPressed: () => openAppSettings(),
                                child: const Text("Open Settings"),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              drawer: AudioFlowDrawer(playlistNameBloc: playlistNameBloc,), // Left-sided menu
              bottomNavigationBar: AudioFlowBottomBar(
                audioPlayerBloc: audioPlayerBloc,
                bottomBarBloc: bottomBarBloc,
              ),
              floatingActionButtonLocation: .centerDocked,
              floatingActionButton: FloatingActionButton(
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
              ),
            ),
          );
        },
      ),
    );
  }
}
