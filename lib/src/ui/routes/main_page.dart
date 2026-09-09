import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/ui/elements/playlists_top_menu.dart'
    show PlayListMenu;
import 'package:audio_flow/src/ui/elements/track_info.dart' show TrackInformation;
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'
    show ProgressBar;
import 'package:flutter/material.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/ui/elements/songs_sliverlist.dart'
    show SongsListBuilder;
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatelessWidget {
  final ThemeBloc themeBloc;
  final AudioPlayerBloc audioPlayerBloc;
  final BottomBarBloc bottomBarBloc;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;
  const MainPage({
    super.key,
    required this.themeBloc,
    required this.audioPlayerBloc,
    required this.bottomBarBloc,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
  });

  @override
  Widget build(BuildContext context) {
    logger.log.d(
      'Start building slivers inside custom scrollview on main page route!',
    );
    // final double screenHeight = MediaQuery.sizeOf(context).height;
    final double headerHeight = MediaQuery.sizeOf(context).height * 0.2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          TrackInformation(audioPlayerBloc: audioPlayerBloc, headerHeight: headerHeight),
          BlocBuilder<PlaylistFilesBloc, PlaylistFilesState>(
            bloc: playlistFilesBloc,
            builder: (context, state) {
              return SizedBox(
                height: headerHeight * 0.15,
                child: PlayListMenu(
                  headerHeight: headerHeight,
                  themeBloc: themeBloc,
                  audioPlayerBloc: audioPlayerBloc,
                  bottomBarBloc: bottomBarBloc,
                  playlistFilesBloc: playlistFilesBloc,
                  playlistNameBloc: playlistNameBloc,
                ),
              );
            },
          ),
          Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SongsListBuilder(
                  audioPlayerBloc: audioPlayerBloc,
                  playlistFilesBloc: playlistFilesBloc,
                  headerHeight: headerHeight,
                ),
              ],
            ),
          ),
          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            bloc: audioPlayerBloc,
            builder: (context, state) {
              return ProgressBar(
                barHeight: 8.0,
                progress: state.position ?? Duration.zero,
                total: state.duration ?? Duration.zero,
                onSeek: (newPosition) {
                  audioPlayerBloc.add(
                    AudioPlayerSeekPositionEvent(
                      position: newPosition,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}