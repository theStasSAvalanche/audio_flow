import 'dart:io';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/storage_navigator_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart'
    show settings, AudioStatus;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/models/filesystem_entity.dart'
    show FileSystemCustomEntity;
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
  final StorageNavigatorBloc storageNavigatorBloc;
  const OpenFilesAndFolders({
    super.key,
    required this.themeBloc,
    required this.audioPlayerBloc,
    required this.bottomBarBloc,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
    required this.storageNavigatorBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageNavigatorBloc, StorageNavigatorState>(
      bloc: storageNavigatorBloc
        ..add(
          StorageNavigatorScanEvent(
            dir: settings.currentScanDir,
            isChecked: false,
          ),
        ),
      builder: (context, state) {
        if (state is StorageNavigatorLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: state.items.length,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return SystemEntityTile(
                        key: ValueKey(item.fullPath),
                        entity: item,
                        storageNavigatorBloc: storageNavigatorBloc,
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: .spaceEvenly,
                  crossAxisAlignment: .center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        settings.currentScanDir = '/storage/emulated/0';
                        logger.log.d('Folder to scan: ${settings.pathsToScan}');
                        playlistFilesBloc.add(
                          PlaylistFilesOpen(pathsToScan: settings.pathsToScan),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                    SizedBox(),
                    ElevatedButton(
                      onPressed: () {
                        settings.currentScanDir = '/storage/emulated/0';
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
      },
    );
  }
}

class SystemEntityTile extends StatefulWidget {
  final FileSystemCustomEntity entity;
  final StorageNavigatorBloc storageNavigatorBloc;
  const SystemEntityTile({
    super.key,
    required this.entity,
    required this.storageNavigatorBloc,
  });

  @override
  State<SystemEntityTile> createState() => _SystemEntityTileState();
}

class _SystemEntityTileState extends State<SystemEntityTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: widget.entity.isChecked,
        onChanged: (_) {
          widget.entity.isChecked = !widget.entity.isChecked;
          if (widget.entity.isChecked) {
            settings.pathsToScan.add(widget.entity);
          } else {
            settings.pathsToScan.remove(widget.entity);
          }
          setState(() {});
        },
      ),
      title: Row(
        children: [
          Icon(
            widget.entity.isDir
                ? (widget.entity.name != '..'
                      ? Icons.folder_outlined
                      : Icons.arrow_upward)
                : Icons.audio_file,
          ),
          SizedBox(width: 8),
          Text(widget.entity.name),
        ],
      ),
      onTap: () {
        late String nextDir;
        if (widget.entity.name == '..') {
          nextDir = widget.entity.fullPath;
        } else {
          nextDir =
              '${settings.currentScanDir}${Platform.pathSeparator}${widget.entity.name}';
        }
        settings.currentScanDir = nextDir;
        logger.log.d('Next scan dir: $nextDir');
        widget.storageNavigatorBloc.add(
          StorageNavigatorScanEvent(
            dir: nextDir,
            isChecked: widget.entity.isChecked,
          ),
        );
      },
    );
  }
}
