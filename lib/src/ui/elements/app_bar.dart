import 'package:flutter/material.dart';

import 'package:audio_flow/src/bloc/theme_bloc.dart';

class AudioFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeBloc themeBloc;

  const AudioFlowAppBar({
    super.key,
    required this.themeBloc,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Audio Flow'),
      actions: [
        Switch(
          value: themeBloc.state == ThemeMode.dark,
          onChanged: (value) {
            themeBloc.add(ThemeChanged(value));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
