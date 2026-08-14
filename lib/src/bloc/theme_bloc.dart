import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'package:audio_flow/src/configuration/config.dart' show settings;


class ThemeBloc extends Bloc<ThemeChanged, ThemeMode> {
  ThemeBloc() : super(settings.themeMode) {
    on<ThemeChanged>((event, emit) {
      settings.setNewThemeMode(event.isDark ? ThemeMode.dark : ThemeMode.light);
      emit(event.isDark ? ThemeMode.dark : ThemeMode.light);
    });
  }
}


class ThemeChanged {
  final bool isDark;

  ThemeChanged(this.isDark);
}