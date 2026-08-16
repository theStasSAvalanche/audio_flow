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
              opacity: 0.3,
              child: IconButton(
                icon: const Icon(Icons.call_split),
                onPressed: () {},
              ),
            ),
            IconButton(icon: const Icon(Icons.skip_previous), onPressed: () {}),
            IconButton(icon: const Icon(Icons.skip_next), onPressed: () {}),
            IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
