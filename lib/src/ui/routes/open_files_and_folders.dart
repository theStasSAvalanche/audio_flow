import 'dart:io';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/storage_navigator_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/instruments/storage_audio_reader.dart'
    show getFoldersRecursivly, setParentDirectoriesSemiChecked;
import 'package:audio_flow/src/models/filesystem_entity.dart'
    show FileSystemCustomEntity;
import 'package:audio_flow/src/ui/elements/app_bar.dart' show AudioFlowAppBar;
import 'package:audio_flow/src/ui/elements/bottom_bar.dart'
    show AudioFlowBottomBar;
import 'package:audio_flow/src/ui/elements/floating_action_button.dart';
import 'package:audio_flow/src/ui/elements/left_drawer.dart'
    show AudioFlowDrawer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OpenFilesAndFolders extends HookWidget {
  final ThemeBloc themeBloc;
  final AudioPlayerBloc audioPlayerBloc;
  final BottomBarBloc bottomBarBloc;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;
  final storageNavigatorBloc = StorageNavigatorBloc();
  OpenFilesAndFolders({
    super.key,
    required this.themeBloc,
    required this.audioPlayerBloc,
    required this.bottomBarBloc,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
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
        return Scaffold(
          body: Column(
            children: [
              Builder(
                builder: (context) {
                  if (state is StorageNavigatorLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Expanded(
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
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: .spaceEvenly,
                crossAxisAlignment: .center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      settings.currentScanDir = '/storage/emulated/0';
                      logger.log.d(
                        'Files and folders to scan: ${settings.pathsToScan}',
                      );
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
          floatingActionButton: AudioFlowFloatingActionButton(
            audioPlayerBloc: audioPlayerBloc,
          ),
        );
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
        tristate: true,
        value: widget.entity.isChecked,
        onChanged: (_) {
          if (widget.entity.isChecked == null || !widget.entity.isChecked!) {
            widget.entity.isChecked = true;
          }
          else {
            widget.entity.isChecked = false;
          }
          if (widget.entity.isChecked! && widget.entity.isDir) {
            var dirs = getFoldersRecursivly(widget.entity);
            for (var dir in dirs) {
              settings.pathsToScan.add(dir);
              settings.semiCheckedPaths.remove(dir);
            }
          } else if (widget.entity.isChecked!) {
            settings.pathsToScan.add(widget.entity);
            setParentDirectoriesSemiChecked(widget.entity, '/storage/emulated/0');
          } else if (!widget.entity.isChecked! && widget.entity.isDir) {
            var dirs = getFoldersRecursivly(widget.entity);
            for (var dir in dirs) {
              settings.pathsToScan.remove(dir);
            }
            setParentDirectoriesSemiChecked(widget.entity, '/storage/emulated/0');
          } else {
            settings.pathsToScan.remove(widget.entity);
            setParentDirectoriesSemiChecked(widget.entity, '/storage/emulated/0');
          }

          if (widget.entity.name == '..') {
            logger.log.d('Checkbox near .. activated:');
            logger.log.d('Current dir: ${settings.currentScanDir}');
            StorageNavigatorScanEvent(
              dir: settings.currentScanDir,
              isChecked: widget.entity.isChecked!,
            );
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
        if (widget.entity.name == '..') {
          settings.currentScanDir = widget.entity.fullPath;
          widget.storageNavigatorBloc.add(
            StorageNavigatorScanEvent(
              dir: widget.entity.fullPath,
              isChecked: false,
            ),
          );
          return;
        }

        var nextDir =
            '${settings.currentScanDir}${Platform.pathSeparator}${widget.entity.name}';
        settings.currentScanDir = nextDir;
        logger.log.d('Next scan dir: $nextDir');
        widget.storageNavigatorBloc.add(
          StorageNavigatorScanEvent(
            dir: nextDir,
            isChecked: widget.entity.isChecked!,
          ),
        );
      },
    );
  }
}
