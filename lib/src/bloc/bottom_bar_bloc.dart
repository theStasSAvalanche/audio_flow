import 'package:audio_flow/src/configuration/config.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/widgets.dart';

part 'bottom_bar_event.dart';
part 'bottom_bar_state.dart';

class BottomBarBloc extends Bloc<BottomBarEvent, BottomBarState> {
  BottomBarBloc()
    : super(
        BottomBarState(
          randomState: settings.isRandom,
          repeatState: settings.repeatMode,
        ),
      ) {
    on<BottomBarRandomChanged>(
      _onBottomBarRandomChanged,
      transformer: sequential(),
    );
    on<BottomBarRepeatChanged>(
      _onBottomBarRepeatChanged,
      transformer: sequential(),
    );
  }

  void _onBottomBarRandomChanged(
    BottomBarRandomChanged event,
    Emitter<BottomBarState> emit,
  ) {
    settings.changeRandomMode();
    emit(
      BottomBarState(
        randomState: settings.isRandom,
        repeatState: settings.repeatMode,
      ),
    );
  }

  void _onBottomBarRepeatChanged(
    BottomBarRepeatChanged event,
    Emitter<BottomBarState> emit,
  ) {
    settings.changeRepeatMode();
    emit(
      BottomBarState(
        randomState: settings.isRandom,
        repeatState: settings.repeatMode,
      ),
    );
  }
}
