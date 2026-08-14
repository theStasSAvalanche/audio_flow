import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/ui/elements/songs_builder.dart' show SongsList;


class MainPage extends StatelessWidget {
  MainPage({super.key});

  final audioList = <String>[];

  @override
  Widget build(BuildContext context) {
    logger.log.d('Srart building widgets on main page route!');
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          SizedBox(
            height: screenHeight / 5,
            child: Row(
              // Album picture
              children: [
                Image.file(File('/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/cover.jpg')),
              ],
            ),
          ),
          const SizedBox(
            height: 16, 
          ),
          Row(
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
          const SizedBox(
            height: 8, 
          ),
          Expanded(
            child: const SongsList(),
          ),
        ],
      ),
    );
  }
}