import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
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
          return Row(
            children: [
              SizedBox(
                height: headerHeight,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).scaffoldBackgroundColor,
                    BlendMode.dstOver,
                  ),
                  child: Image.asset('assets/images/album.png'),
                ),
              ),
              Column(
                mainAxisAlignment: .spaceAround,
                crossAxisAlignment: .center,
                children: [
                  Text(artist),
                  SizedBox(height: headerHeight * 0.025),
                  Text(album),
                  SizedBox(height: headerHeight * 0.075),
                  Text(title),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
