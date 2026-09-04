import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/bloc/storage_navigator_bloc.dart';
import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/ui/routes/open_files_and_folders.dart' show OpenFilesAndFolders;
import 'package:flutter/material.dart';

class PlayListMenu extends StatelessWidget {
  final double headerHeight;
  final ThemeBloc themeBloc;
  final AudioPlayerBloc audioPlayerBloc;
  final BottomBarBloc bottomBarBloc;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;
  const PlayListMenu({
    super.key,
    required this.headerHeight,
    required this.themeBloc,
    required this.audioPlayerBloc,
    required this.bottomBarBloc,
    required this.playlistFilesBloc,
    required this.playlistNameBloc,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: headerHeight * 0.15,
      child: Container(
        padding: .directional(start: 24, end: 24),
        child: Row(
          children: [
            Text(
              'Playlist 1',
              style: TextStyle(fontSize: 18.0, fontWeight: .w500),
            ),
            SizedBox(width: 8),
            Icon(Icons.create_sharp),
            Spacer(),
            IconButton(
              icon: Icon(Icons.add_outlined),
              tooltip: 'Add files and folders',
              onPressed: () {
                logger.log.d('Add folders to playlist');
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => OpenFilesAndFolders(
                      themeBloc: themeBloc,
                      audioPlayerBloc: audioPlayerBloc,
                      bottomBarBloc: bottomBarBloc,
                      playlistFilesBloc: playlistFilesBloc,
                      playlistNameBloc: playlistNameBloc,
                      storageNavigatorBloc: StorageNavigatorBloc(),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.playlist_remove),
              tooltip: 'Clear playlist',
              onPressed: () {
                logger.log.d('Clear current playlist from audio files');
                playlistFilesBloc.add(
                  PlaylistFilesClear(playlistName: settings.playlistName),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
