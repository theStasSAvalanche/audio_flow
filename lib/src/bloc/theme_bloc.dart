import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'package:audio_flow/src/configuration/config.dart' show Settings;



final settings = Settings();

class ThemeBloc extends Bloc<ThemeChanged, ThemeMode> {
  ThemeBloc() : super(settings.themeMode) {
    on<ThemeChanged>((event, emit) {
      emit(event.isDark ? ThemeMode.dark : ThemeMode.light);
    });
  }
}


class ThemeChanged {
  final bool isDark;

  ThemeChanged(this.isDark);
}