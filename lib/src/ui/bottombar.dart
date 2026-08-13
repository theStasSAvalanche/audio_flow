import 'package:flutter/material.dart';


class AudioFlowBottomBar extends StatelessWidget implements PreferredSizeWidget {
  const AudioFlowBottomBar({super.key});

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
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.repeat),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}