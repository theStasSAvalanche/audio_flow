import 'dart:io';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/ui/elements/songs_builder.dart' show SongsList;
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget;

class MainPage extends StatelessWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;
  const MainPage({
    super.key,
    required this.audioPlayerBloc,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    logger.log.d(
      'Start building slivers inside custom scrollview on main page route!',
    );
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenHeight / 5,
              child: Row(
                children: [
                  Image.file(
                    File(
                      '/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/cover.jpg',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: screenHeight / 50)),
          SliverToBoxAdapter(
            child: Text(
              '02. Immortalized',
              style: TextStyle(fontSize: 18.0, fontWeight: .w700),
            ),
          ),
          SongsList(
            audioPlayerBloc: audioPlayerBloc,
            scrollController: scrollController,
          ),
        ],
      ),
    );
  }
}

class AudioFlowScrollController extends HookWidget {
  final AudioPlayerBloc audioPlayerBloc;
  final ScrollController scrollController;

  const AudioFlowScrollController({
    super.key,
    required this.audioPlayerBloc,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return MainPage(
      audioPlayerBloc: audioPlayerBloc,
      scrollController: scrollController,
    );
  }
}
