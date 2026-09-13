import 'dart:io' show File;

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class TrackInformation extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final double headerHeight;
  const TrackInformation({
    super.key,
    required this.audioPlayerBloc,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        bloc: audioPlayerBloc,
        buildWhen: (previous, current) =>
            current.audioTrack != previous.audioTrack,
        builder: (context, state) {
          var artist = state.audioTrack?.artist ?? '';
          var album = state.audioTrack?.album ?? '';
          var title = state.audioTrack?.title ?? '';
          var albumArt = Image.asset('assets/images/album.png');
          if (state.audioTrack?.albumArt != null) {
            albumArt = Image.memory(state.audioTrack!.albumArt!);
          } else if (state.audioTrack?.directoryPicture != null) {
            albumArt = Image.file(
              File(state.audioTrack!.directoryPicture!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                logger.log.e(error);
                return Text('Image was not loaded');
              },
            );
          }

          return Row(
            children: [
              SizedBox(
                height: headerHeight,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).scaffoldBackgroundColor,
                    BlendMode.dstOver,
                  ),
                  child: albumArt,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: .spaceAround,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 20.0, fontWeight: .w800),
                    ),
                    SizedBox(height: headerHeight * 0.075),
                    Text(
                      artist,
                      style: TextStyle(fontSize: 16.0, fontWeight: .w600),
                    ),
                    SizedBox(height: headerHeight * 0.025),
                    Text(
                      album,
                      style: TextStyle(fontSize: 16.0, fontWeight: .w500),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
