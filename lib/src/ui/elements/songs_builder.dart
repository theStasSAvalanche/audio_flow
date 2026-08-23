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
          final List<GlobalKey> _keys = List.generate(snapshot.data!.length, (index) => GlobalKey());
          return MyHookField(
            snapshot: snapshot,
            audioPlayerBloc: audioPlayerBloc,
            keys: _keys,
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
  final List<GlobalKey> keys;
  const SongsListView({
    super.key,
    required this.snapshot,
    required this.audioPlayerBloc,
    required this.keys,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final song = snapshot.data![index];
          return SongTile(audioPlayerBloc: audioPlayerBloc, song: song, index: index);
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

  double getTilePosition(int index) {
  final context = keys[0].currentContext;
  if (context != null) {
    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.size.height * index; // Возвращает точную высоту в double
  }
  return 0.0; // Элемент еще не отрендерен (находится за пределами экрана)
}
}


class SongTile extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final AudioFlowFile song;
  final int index;
  const SongTile({
    super.key,
    required this.audioPlayerBloc,
    required this.song,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        return previous != current || current is AudioPlayerPlaying;
      },
      builder: (context, state) {
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
}

class MyHookField extends HookWidget {
  final AsyncSnapshot<List<AudioFlowFile>> snapshot;
  final AudioPlayerBloc audioPlayerBloc;
  final List<GlobalKey> keys;
  const MyHookField({
    super.key,
    required this.snapshot,
    required this.audioPlayerBloc,
    required this.keys,
  });

  @override
  Widget build(BuildContext context) {
    return SongsListView(
      snapshot: snapshot,
      audioPlayerBloc: audioPlayerBloc,
      keys: keys,
    );
  }
}