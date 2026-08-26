import 'dart:io' show File;

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:flutter/material.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/ui/elements/songs_builder.dart' show SongsListBuilder;
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
    // final double screenHeight = MediaQuery.sizeOf(context).height;
    final double headerHeight = MediaQuery.sizeOf(context).height / 4;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [          
          SizedBox(
            height: headerHeight * 0.8,
            child: Row(
              // Album picture
              children: [
                Image.file(File('/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/cover.jpg')),
              ],
            ),
          ),
          SizedBox(height: headerHeight * 0.05),
          SizedBox(
            height: headerHeight * 0.15,
            child: Row(
              // Current song name
              children: [
                Text(
                  '02. Immortalized',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: .w700
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              controller: scrollController,
              slivers: [
                SongsListBuilder(
                  audioPlayerBloc: audioPlayerBloc,
                  scrollController: scrollController,
                  headerHeight: headerHeight,
                ),
              ],
            ),
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


class MainPageHeader extends SliverPersistentHeaderDelegate {
  final double headerHeight;

  const MainPageHeader({
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          SizedBox(
            height: headerHeight * 0.8,
            child: Row(
              // Album picture
              children: [
                Image.file(File('/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/cover.jpg')),
              ],
            ),
          ),
          SizedBox(
            height: headerHeight * 0.05, 
          ),
          Row(
            // Current song name
            children: [
              SizedBox(
                height: headerHeight * 0.15,
                child: Text(
                  '02. Immortalized',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: .w700
                  ),
                ),
              ),
            ],
          ),
        ],
      );
  }
  
  @override
  double get minExtent => headerHeight;

  @override
  double get maxExtent => headerHeight;

  @override
  bool shouldRebuild(covariant MainPageHeader oldDelegate) {
    return oldDelegate.headerHeight != headerHeight;
  }
}