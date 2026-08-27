import 'package:audio_flow/src/bloc/playlist_files_bloc.dart';
import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class SongsListBuilder extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final PlaylistFilesBloc playlistFilesBloc;
  final ScrollController scrollController;
  final double headerHeight;
  const SongsListBuilder({
    super.key,
    required this.audioPlayerBloc,
    required this.playlistFilesBloc,
    required this.scrollController,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistFilesBloc, PlaylistFilesState>(
      bloc: playlistFilesBloc..add(PlaylistFilesFromHive(playlistName: settings.playlistName)),
      builder: (context, state) {
          return SongsListView(
            audioPlaylist: state.audioPlaylist,
            audioPlayerBloc: audioPlayerBloc,
            scrollController: scrollController,
            headerHeight: headerHeight,
          );
      }
    );
  }
}

class SongsListView extends StatelessWidget {
  final List<AudioFlowFile> audioPlaylist;
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  final double headerHeight;
  const SongsListView({
    super.key,
    required this.audioPlaylist,
    required this.audioPlayerBloc,
    required this.scrollController,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final song = audioPlaylist[index];
          final List<GlobalKey> targetSliverKey = List<GlobalKey>.generate(audioPlaylist.length, (_) => GlobalKey());
          return SongTile(
            audioPlayerBloc: audioPlayerBloc,
            song: song,
            index: index,
            tileKey: targetSliverKey[index],
            scrollController: scrollController,
            headerHeight: headerHeight,
          );
        },
        childCount: audioPlaylist.length,
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final AudioFlowFile song;
  final int index;
  final GlobalKey tileKey; 
  final ScrollController scrollController;
  final double headerHeight;
  const SongTile({
    super.key,
    required this.audioPlayerBloc,
    required this.song,
    required this.index,
    required this.tileKey,
    required this.scrollController,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        return previous != current || current is AudioPlayerPlaying;
      },
      builder: (context, state) {
        if (index == state.trackNumber) {
          scrollToSliver(tileKey);
        }
        return ListTile(
          key: tileKey,
          title: Text(song.toString()),
          selectedTileColor: Colors.lightBlue.withValues(alpha: 0.3),
          selected: index == state.trackNumber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onTap: () {
            audioPlayerBloc.add(AudioPlayerPlayEvent(index));
          },
          trailing: IconButton(
            icon: Icon(Icons.music_note),
            onPressed: () {
              audioPlayerBloc.add(AudioPlayerPlayEvent(index));
            },
          ),
        );
      },
    );
  }

  void scrollToSliver(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      // Находим RenderBox нужного слейвера
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      
      // Получаем позицию слейвера относительно Scrollable-родителя
      final position = renderBox.localToGlobal(
        Offset(0, -headerHeight), 
        ancestor: context.findAncestorRenderObjectOfType<RenderAbstractViewport>(),
      );

      // Вычисляем итоговый offset с учетом текущей прокрутки
      final targetOffset = scrollController.offset + position.dy;

      // Плавно скроллим
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
