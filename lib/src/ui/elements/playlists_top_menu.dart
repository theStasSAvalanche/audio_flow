import 'package:flutter/material.dart';

class PlayListMenu extends StatelessWidget {
  final double headerHeight;
  const PlayListMenu({super.key, required this.headerHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: headerHeight * 0.15,
      child: Container(
        padding: .directional(start: 24, end: 24),
        child: Row(
          children: [
            Text(
              'Playlist 1',
              style: TextStyle(fontSize: 20.0, fontWeight: .w700),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.create_sharp,
            ),
            Spacer(),
            Icon(
              Icons.add_outlined,
            ),
            SizedBox(width: 8),
            Icon(
              Icons.playlist_remove,
            ),
            Icon(
              Icons.close_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
