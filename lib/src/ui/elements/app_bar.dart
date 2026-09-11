import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/theme_bloc.dart';

class AudioFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeBloc themeBloc;

  const AudioFlowAppBar({super.key, required this.themeBloc});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Audio Flow'),
      actions: [
        Icon(
          themeBloc.state == ThemeMode.dark
              ? Icons.wb_sunny_outlined
              : Icons.dark_mode_outlined,
        ),
        SizedBox(width: 16.0),
        Switch(
          value: themeBloc.state == ThemeMode.dark,
          onChanged: (value) {
            themeBloc.add(ThemeChanged(value));
          },
        ),
        SizedBox(width: 16.0),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
