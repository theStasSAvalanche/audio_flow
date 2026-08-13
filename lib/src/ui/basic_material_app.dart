import 'package:audio_flow/src/bloc/permission_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:audio_flow/src/bloc/theme_bloc.dart';
import 'package:audio_flow/src/configuration/config.dart' show Settings;
import 'package:audio_flow/src/configuration/logger.dart';
import 'package:audio_flow/src/ui/theme.dart' show darkTheme, lightTheme;
import 'package:audio_flow/src/ui/routes/main_page.dart' show MainPage;
import 'package:audio_flow/src/ui/appbar.dart' show AudioFlowAppBar;
import 'package:audio_flow/src/ui/bottombar.dart' show AudioFlowBottomBar;
import 'package:audio_flow/src/ui/left_drawer.dart' show AudioFlowDrawer;
import 'package:permission_handler/permission_handler.dart';


final settings = Settings();


class AudioFlowApp extends StatelessWidget {
  const AudioFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AudioFlowMaterial();
  }
}


class AudioFlowMaterial extends StatelessWidget {
  const AudioFlowMaterial({super.key});
  
  @override
  Widget build(BuildContext context) {
    logger.log.i('Start building MaterialApp widget');
    final themeBloc = ThemeBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        bloc: themeBloc,
        builder: (context, state) {
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state,
            home: Scaffold(
              appBar: AudioFlowAppBar(themeBloc: themeBloc),
              body: SafeArea(
                child: BlocProvider(
                  create: (context) => PermissionBloc(),
                  child: BlocBuilder<PermissionBloc, PermissionState>(
                    builder: (context, state) {
                      if (state is PermissionGranted) {
                        return MainPage();
                      } else if (state is PermissionDenied) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Permission Denied. Please enable it in settings."),
                              ElevatedButton(
                                onPressed: () => openAppSettings(),
                                child: const Text("Open Settings"),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              drawer: AudioFlowDrawer(),
              bottomNavigationBar: AudioFlowBottomBar(),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                tooltip: 'Play/Pause',
                child: const Icon(Icons.play_arrow),
              ),
              floatingActionButtonLocation: .centerDocked,
            ),
          );
        }
      ),
    );
  }
}