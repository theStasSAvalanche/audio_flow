part of 'bottom_bar_bloc.dart';

@immutable
class BottomBarState {
  final bool randomState;
  final RepeatStatus repeatState;
  const BottomBarState({required this.randomState, required this.repeatState});

  bool get isRandom => randomState;
  RepeatStatus get repeatMode => repeatState;

  BottomBarState copyWith({
    bool? newRandomState,
    RepeatStatus? newRepeatState,
  }) {
    return BottomBarState(
      randomState: newRandomState ?? randomState,
      repeatState: newRepeatState ?? repeatState,
    );
  }
}
