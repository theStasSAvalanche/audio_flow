import 'dart:io';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart'
    show settings, AudioStatus;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/models/filesystem_entity.dart' show FileSystemCustomEntity;
import 'package:audio_flow/src/ui/elements/app_bar.dart' show AudioFlowAppBar;
import 'package:audio_flow/src/ui/elements/bottom_bar.dart'
    show AudioFlowBottomBar;
import 'package:audio_flow/src/ui/elements/left_drawer.dart'
    show AudioFlowDrawer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenFilesAndFolders extends StatelessWidget {
  final ThemeBloc themeBloc;
  final AudioPlayerBloc audioPlayerBloc;
  final BottomBarBloc bottomBarBloc;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;
  const OpenFilesAndFolders({
    super.key,
    required this.themeBloc,
    required this.audioPlayerBloc,
    required this.bottomBarBloc,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkDir(),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<FileSystemCustomEntity>?> asyncSnapshot,
          ) {
            // 1. Handle the waiting/loading state
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Handle errors if they occur
            if (asyncSnapshot.hasError) {
              return Center(child: Text('Error: ${asyncSnapshot.error}'));
            }

            // 3. Handle successful data state
            if (asyncSnapshot.hasData) {
              for (var entity in asyncSnapshot.data!) {
                logger.logNS.d(entity.toString());
              }
              final List<FileSystemCustomEntity> items = asyncSnapshot.data!;
              return Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: items.length,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Row(children: [
                            Checkbox(value: true, onChanged: (_) {}),
                            Icon(item.isDir ? Icons.folder_open : Icons.insert_drive_file),
                            SizedBox(width: 8,),
                            Text(item.name),
                          ]);
                        },
                      ),
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: .spaceEvenly,
                      crossAxisAlignment: .center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                        SizedBox(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16,),
                  ],
                ),
                appBar: AudioFlowAppBar(themeBloc: themeBloc),
                drawer: AudioFlowDrawer(
                  playlistNameBloc: playlistNameBloc,
                ), // Left-sided menu
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
              );
            }

            return const Center(child: Text('No data found'));
          },
    );
  }
}

Future<List<FileSystemCustomEntity>?> checkDir() async {
  const String rootPath = '/storage/emulated/0';
  final Directory rootDir = Directory(rootPath);
  if (await rootDir.exists()) {
    logger.log.d(rootDir.toString());
    final List<FileSystemEntity> entities = rootDir.listSync(recursive: false);
    final customEntities = entities.map((e) => FileSystemCustomEntity.fromEntity(e)).toList();
    return customEntities;
  } else {
    logger.log.w('Directory does not exist!');
    return null;
  }
}
