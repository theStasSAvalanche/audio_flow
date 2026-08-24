import 'package:audio_flow/src/bloc/bottom_bar_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart';
import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;

class AudioFlowBottomBar extends StatelessWidget
    implements PreferredSizeWidget {
  final AudioPlayerBloc audioPlayerBloc;

  final BottomBarBloc bottomBarBloc;

  const AudioFlowBottomBar({
    super.key,
    required this.audioPlayerBloc,
    required this.bottomBarBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: BlocBuilder<BottomBarBloc, BottomBarState>(
          bloc: bottomBarBloc,
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Opacity(
                  opacity: state.isRandom ? 1.0 : 0.25,
                  child: IconButton(
                    icon: const Icon(Icons.call_split),
                    tooltip: 'Random mode',
                    onPressed: () {
                      bottomBarBloc.add(BottomBarRandomChanged());
                      logger.log.d('Random is ${state.isRandom}');
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Previous track',
                  onPressed: () {
                    audioPlayerBloc.add(AudioPlayerPreviousEvent());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop',
                  onPressed: () {
                    audioPlayerBloc.add(AudioPlayerStopEvent());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Next track',
                  onPressed: () {
                    audioPlayerBloc.add(AudioPlayerNextEvent());
                  },
                ),
                Stack(
                  alignment: .topRight,
                  children: [
                    Opacity(
                      opacity: state.repeatMode == RepeatStatus.off ? 0.25 : 1.0,
                      child: IconButton(
                        icon: const Icon(Icons.repeat),
                        tooltip: 'Repeat mode',
                        onPressed: () {
                          bottomBarBloc.add(BottomBarRepeatChanged());
                          logger.log.d(
                            'Repeat mode set to ${settings.repeatMode.name}',
                          );
                        },
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        if (state.repeatMode == RepeatStatus.one) {
                          return const Text('1');   
                        }

                        return const Text('');
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
