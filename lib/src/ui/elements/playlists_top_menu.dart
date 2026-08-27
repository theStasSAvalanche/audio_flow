import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/bloc/playlist_name_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:flutter/material.dart';

class PlayListMenu extends StatelessWidget {
  final double headerHeight;
  final PlaylistFilesBloc playlistFilesBloc;
  final PlaylistNameBloc playlistNameBloc;
  const PlayListMenu({
    super.key,
    required this.headerHeight,
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
              style: TextStyle(fontSize: 20.0, fontWeight: .w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.create_sharp),
            Spacer(),
            Icon(Icons.add_outlined),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.playlist_remove),
              onPressed: () {
                logger.log.d('Clear current playlist from audio files');
                playlistFilesBloc.add(PlaylistFilesClear(playlistName: settings.playlistName));
              },
            ),
            Icon(Icons.close_outlined),
          ],
        ),
      ),
    );
  }
}
