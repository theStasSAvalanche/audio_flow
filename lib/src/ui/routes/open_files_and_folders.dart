import 'dart:io' show Platform;

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/storage_navigator_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
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
          StorageNavigatorLoadEvent(
            item: FileSystemCustomEntity(
              name: 'rootDir',
              fullPath: settings.localStorage,
              isDir: true,
              isChecked: false,
            ),
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
                            items: state.items,
                            entity: item,
                            index: index,
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
                    child: const Text('Add'),
                    onPressed: () {
                      logger.log.d(
                        'Files and folders to scan: ${settings.pathsToScan}',
                      );
                      playlistFilesBloc.add(
                        PlaylistFilesOpen(pathsToScan: settings.pathsToScan),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(),
                  ElevatedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      logger.log.d(
                        'Loading files cancelled, clear all structures',
                      );
                      settings.pathsToScan.clear();
                      settings.semiCheckedPaths.clear();
                      settings.uncheckedFiles.clear();
                      Navigator.pop(context);
                    },
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

class SystemEntityTile extends StatelessWidget {
  final List<FileSystemCustomEntity> items;
  final FileSystemCustomEntity entity;
  final int index;
  final StorageNavigatorBloc storageNavigatorBloc;
  const SystemEntityTile({
    super.key,
    required this.items,
    required this.entity,
    required this.index,
    required this.storageNavigatorBloc,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        tristate: true,
        value: entity.isChecked,
        onChanged: (_) {
          storageNavigatorBloc.add(
            StorageNavigatorCheckEvent(items: items, itemIndex: index),
          );
        },
      ),
      title: Row(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        children: [
          Icon(
            entity.isDir
                ? (entity.name != '..'
                      ? Icons.folder_outlined
                      : Icons.arrow_upward)
                : Icons.audio_file,
          ),
          SizedBox(width: 8),
          Expanded(child: Text(entity.name)),
        ],
      ),
      onTap: () {
        if (entity.isDir && entity.name == '..') {
          // build parent folder
          var splitPaths = entity.fullPath.split(Platform.pathSeparator)
            ..removeLast();
          var parentDir = splitPaths.join(Platform.pathSeparator);
          storageNavigatorBloc.add(
            StorageNavigatorLoadEvent(
              item: FileSystemCustomEntity(
                name: splitPaths.last,
                fullPath: parentDir,
                isDir: true,
              ),
            ),
          );
        } else if (entity.isDir) {
          storageNavigatorBloc.add(StorageNavigatorLoadEvent(item: entity));
        } else {
          storageNavigatorBloc.add(
            StorageNavigatorCheckEvent(items: items, itemIndex: index),
          );
        }
      },
    );
  }
}
