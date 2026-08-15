import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/instruments/audio_reader.dart' show AudioFlowFile, getAudioContent;


class SongsList extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  const SongsList({super.key, required this.audioPlayerBloc});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioFlowFile>>(
      future: getAudioContent(),
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var song = snapshot.data![index];
              return ListTile(
                title: Text(song.toString()),
                onTap: () => audioPlayerBloc.add(AudioPlayerPlayEvent(song.metadata!.file.path)),
                trailing: IconButton(
                  icon: Icon(
                    Icons.remove,
                  ),
                  onPressed: () {},
                )
              );
            },
          );
        } else {
          // Если данных нет, показываем сообщение об этом
          return Center(child: Text('No audio data found'));
        }
      },
    );
  }
}