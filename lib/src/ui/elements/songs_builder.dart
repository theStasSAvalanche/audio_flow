import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/instruments/hive_audio_database.dart'
    show getPlaylistFromHive;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget;

class SongsList extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  const SongsList({super.key, required this.audioPlayerBloc});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioFlowFile>>(
      future: getPlaylistFromHive('playlist'),
      builder: (context, snapshot) {
        // check connection state and errors during snapshot with data already done.
        if (snapshot.connectionState == ConnectionState.waiting) {
          logger.logNS.d('Waiting for audio builder');
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.log.e('Error during audio builder: ${snapshot.error}');
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          logger.logNS.d('Audio builder in process: snapshot has data');
          logger.logNS.d('Returning ListView.builder');
          settings.audioPlaylist = snapshot.data!;
          final ScrollController scrollController = ScrollController();
          return MyHookField(
            snapshot: snapshot,
            audioPlayerBloc: audioPlayerBloc,
            scrollController: scrollController,
          );
        } else {
          // Если данных нет, показываем сообщение об этом
          return Center(child: Text('No audio data found'));
        }
      },
    );
  }
}

class SongsListView extends StatelessWidget {
  final AsyncSnapshot<List<AudioFlowFile>> snapshot;
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  const SongsListView({
    super.key,
    required this.snapshot,
    required this.audioPlayerBloc,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double tileExtent = screenHeight * 0.06;
    return ListView.custom(
      itemExtent: tileExtent * 1.0,
      controller: scrollController,
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final song = snapshot.data![index];
          return SongTile(
            audioPlayerBloc: audioPlayerBloc,
            song: song,
            index: index,
            extent: tileExtent,
            scrollController: scrollController,
          );
        },
        childCount: snapshot.data!.length,
        findChildIndexCallback: (Key key) {
          final ValueKey targetKey = key as ValueKey;
          final index = snapshot.data!.indexWhere(
            (song) => ValueKey(song.filePath) == targetKey,
          );
          return index >= 0 ? index : null;
        },
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final AudioFlowFile song;
  final int index;
  final double extent;
  final ScrollController scrollController;
  const SongTile({
    super.key,
    required this.audioPlayerBloc,
    required this.song,
    required this.index,
    required this.extent,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        return previous != current || current is AudioPlayerPlaying;
      },
      builder: (context, state) {
        scrollToSelected(settings.currentTrackNumber);
        return ListTile(
          key: ValueKey(song.filePath),
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

  void scrollToSelected(int index) {
    index = index == -1 ? 0 : index;
    if (scrollController.hasClients) {
      scrollController.animateTo(
        extent * index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

class MyHookField extends HookWidget {
  final AsyncSnapshot<List<AudioFlowFile>> snapshot;
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  const MyHookField({
    super.key,
    required this.snapshot,
    required this.audioPlayerBloc,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SongsListView(
      snapshot: snapshot,
      audioPlayerBloc: audioPlayerBloc,
      scrollController: scrollController,
    );
  }
}
