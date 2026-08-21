import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/instruments/audio_hive_middleware.dart' show getPlaylistFromHive;


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
          return SongsListView(
            snapshot: snapshot,
            audioPlayerBloc: audioPlayerBloc,
          );
        } else {
          // Если данных нет, показываем сообщение об этом
          return Center(child: Text('No audio data found'));
        }
      },
    );
  }
}

class SongsListView extends StatefulWidget {
  final AsyncSnapshot<List<AudioFlowFile>> snapshot;
  final AudioPlayerBloc audioPlayerBloc;
  const SongsListView({
    super.key,
    required this.snapshot,
    required this.audioPlayerBloc,
  });

  @override
  State<SongsListView> createState() => _SongsListViewState();
}

class _SongsListViewState extends State<SongsListView> {
  int? _selectedItemId;

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final song = widget.snapshot.data![index];
          final isSelected = _selectedItemId == index;
          return ListTile(
            key: ValueKey(song.filePath), 
            title: Text(song.toString()),
            selectedTileColor: Colors.blue.withValues(alpha: 0.2),
            selected: isSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Adjust the radius here
            ),
            onTap: () {
              setState(() {
                _selectedItemId = index;
                settings.currentTrack = index;
              });
              widget.audioPlayerBloc.add(AudioPlayerPlayEvent(song.filePath));
            },
            trailing: IconButton(
              icon: Icon(
                Icons.music_note,
              ),
              onPressed: () {
                setState(() {
                  _selectedItemId = index;
                  settings.currentTrack = index;
                });
                widget.audioPlayerBloc.add(AudioPlayerPlayEvent(song.filePath));
              },
            )
          );
        },
        childCount: widget.snapshot.data!.length,
        findChildIndexCallback: (Key key) {
          final ValueKey targetKey = key as ValueKey;
          final index  = widget.snapshot.data!.indexWhere((song) => ValueKey(song.filePath) == targetKey);
          return index >= 0 ? index : null;
        },
      ),
    );
  }
}

