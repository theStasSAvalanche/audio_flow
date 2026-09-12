import 'dart:io';

import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class SongsListBuilder extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final PlaylistFilesBloc playlistFilesBloc;
  final double headerHeight;
  const SongsListBuilder({
    super.key,
    required this.audioPlayerBloc,
    required this.playlistFilesBloc,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SongsListView(
      audioPlaylist: playlistFilesBloc.state.audioPlaylist,
      audioPlayerBloc: audioPlayerBloc,
      headerHeight: headerHeight,
    );
  }
}

class SongsListView extends StatelessWidget {
  final List<AudioFlowFile> audioPlaylist;
  final AudioPlayerBloc audioPlayerBloc;
  final double headerHeight;
  const SongsListView({
    super.key,
    required this.audioPlaylist,
    required this.audioPlayerBloc,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: audioPlaylist.length,
      itemBuilder: (context, index) {
        final song = audioPlaylist[index];
        final List<GlobalKey> targetSliverKey = List<GlobalKey>.generate(
          audioPlaylist.length,
          (_) => GlobalKey(),
        );
        return SongTile(
          audioPlayerBloc: audioPlayerBloc,
          song: song,
          index: index,
          tileKey: targetSliverKey[index],
          headerHeight: headerHeight,
        );
      },
      separatorBuilder: (context, index) {
        // index here represents the separator position.
        // The item BEFORE this separator is at index.
        // The item AFTER this separator is at index + 1.
        var currentItem = audioPlaylist[index];
        var currentParent = currentItem.filePath.split(Platform.pathSeparator)
          ..removeLast();
        var currentDir = currentParent.join(Platform.pathSeparator);
        var nextItem = audioPlaylist[index + 1];
        var nextParent = nextItem.filePath.split(Platform.pathSeparator)
          ..removeLast();
        var nextDir = nextParent.join(Platform.pathSeparator);
        if (currentDir != nextDir) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SizedBox(
              height: 48,
              child: Column(
                mainAxisAlignment: .end,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    nextParent.last,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: .w600,
                      color: Colors.blue,
                    ),
                  ),
                  Divider(color: Colors.grey, thickness: 2),
                ],
              ),
            ),
          );
        }

        // Default separator if condition isn't met
        return const Divider(color: Colors.grey, thickness: 0.5);
      },
    );
  }
}

class SongTile extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final AudioFlowFile song;
  final int index;
  final GlobalKey tileKey;
  final double headerHeight;
  const SongTile({
    super.key,
    required this.audioPlayerBloc,
    required this.song,
    required this.index,
    required this.tileKey,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        return previous != current;
      },
      builder: (context, state) {
        return ListTile(
          key: tileKey,
          title: Text('${index + 1}. ${song.title}'),
          subtitle: Text('${song.artist} - ${song.album}'),
          selectedTileColor: Colors.lightBlue.withValues(alpha: 0.3),
          selected: song == state.audioTrack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onTap: () {
            audioPlayerBloc.add(AudioPlayerStartPlayEvent(audioTrack: song));
          },
          trailing: IconButton(
            icon: Icon(Icons.music_note),
            onPressed: () {
              audioPlayerBloc.add(AudioPlayerStartPlayEvent(audioTrack: song));
            },
          ),
        );
      },
    );
  }
}
