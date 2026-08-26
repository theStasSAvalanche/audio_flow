import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/instruments/hive_audio_database.dart'
    show getPlaylistFromHive;
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class SongsListBuilder extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  final double headerHeight;
  const SongsListBuilder({
    super.key,
    required this.audioPlayerBloc,
    required this.scrollController,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioFlowFile>>(
      future: getPlaylistFromHive('playlist'),
      builder: (context, snapshot) {
        // check connection state and errors during snapshot with data already done.
        if (snapshot.connectionState == ConnectionState.waiting) {
          logger.logNS.d('Waiting for audio builder');
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          logger.log.e('Error during audio builder: ${snapshot.error}');
          return SliverToBoxAdapter(
            child: Center(child: Text('Ошибка: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          logger.logNS.d('Audio builder in process: snapshot has data');
          logger.logNS.d('Returning ListView.builder');
          settings.audioPlaylist = snapshot.data!;
          return SongsListView(
            snapshot: snapshot,
            audioPlayerBloc: audioPlayerBloc,
            scrollController: scrollController,
            headerHeight: headerHeight,
          );
        } else {
          // Если данных нет, показываем сообщение об этом
          return SliverToBoxAdapter(child: Center(child: Text('No audio data found')));
        }
      },
    );
  }
}

class SongsListView extends StatelessWidget {
  final AsyncSnapshot<List<AudioFlowFile>> snapshot;
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  final double headerHeight;
  const SongsListView({
    super.key,
    required this.snapshot,
    required this.audioPlayerBloc,
    required this.scrollController,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final song = snapshot.data![index];
          final List<GlobalKey> targetSliverKey = List<GlobalKey>.generate(snapshot.data!.length, (_) => GlobalKey());
          return SongTile(
            audioPlayerBloc: audioPlayerBloc,
            song: song,
            index: index,
            tileKey: targetSliverKey[index],
            scrollController: scrollController,
            headerHeight: headerHeight,
          );
        },
        childCount: snapshot.data!.length,
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
