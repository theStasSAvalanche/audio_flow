import 'package:audio_flow/src/configuration/config.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';

class AudioFlowBottomBar extends StatelessWidget
    implements PreferredSizeWidget {
  final AudioPlayerBloc audioPlayerBloc;

  const AudioFlowBottomBar({super.key, required this.audioPlayerBloc});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Opacity(
              opacity: settings.isRandom ? 1.0 : 0.25,
              child: IconButton(
                icon: const Icon(Icons.call_split),
                tooltip: 'Random',
                onPressed: () {
                  settings.changeRandomMode();
                  logger.log.d('Random is ${settings.isRandom}');
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                audioPlayerBloc.add(AudioPlayerPreviousEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                audioPlayerBloc.add(AudioPlayerStopEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                audioPlayerBloc.add(AudioPlayerNextEvent());
              },
            ),
            IconButton(icon: const Icon(Icons.repeat), onPressed: () {
              settings.changeRepeatMode();
              logger.log.d('Repeat is ${settings.isRepeat}');
            }),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
