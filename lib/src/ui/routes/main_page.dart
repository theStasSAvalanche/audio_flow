import 'dart:io' show File;

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/ui/elements/playlists_top_menu.dart'
    show PlayListMenu;
import 'package:flutter/material.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/ui/elements/songs_sliverlist.dart'
    show SongsListBuilder;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget;

class MainPage extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;
  const MainPage({
    super.key,
    required this.audioPlayerBloc,
    required this.scrollController,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
  });

  @override
  Widget build(BuildContext context) {
    logger.log.d(
      'Start building slivers inside custom scrollview on main page route!',
    );
    // final double screenHeight = MediaQuery.sizeOf(context).height;
    final double headerHeight = MediaQuery.sizeOf(context).height / 4;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          SizedBox(
            height: headerHeight * 0.65,
            child: Row(
              // Album picture
              children: [
                Image.file(
                  File(
                    '/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/cover.jpg',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: headerHeight * 0.05),
          SizedBox(
            height: headerHeight * 0.15,
            child: Row(
              // Current song name
              children: [
                Text(
                  '02. Immortalized',
                  style: TextStyle(fontSize: 18.0, fontWeight: .w700),
                ),
              ],
            ),
          ),
          BlocBuilder<PlaylistFilesBloc, PlaylistFilesState>(
            bloc: playlistFilesBloc,
            builder: (context, state) {
              return SizedBox(
                height: headerHeight * 0.15,
                child: PlayListMenu(
                  headerHeight: headerHeight,
                  playlistFilesBloc: playlistFilesBloc,
                  playlistNameBloc: playlistNameBloc,
                ),
              );
            }
          ),
          Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              controller: scrollController,
              slivers: [
                SongsListBuilder(
                  audioPlayerBloc: audioPlayerBloc,
                  playlistFilesBloc: playlistFilesBloc,
                  scrollController: scrollController,
                  headerHeight: headerHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioFlowScrollController extends HookWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;

  const AudioFlowScrollController({
    super.key,
    required this.audioPlayerBloc,
    required this.scrollController,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MainPage(
      audioPlayerBloc: audioPlayerBloc,
      scrollController: scrollController,
      playlistFilesBloc: playlistFilesBloc,
      playlistNameBloc: playlistNameBloc,
    );
  }
}
