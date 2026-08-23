part of 'bottom_bar_bloc.dart';

@immutable
sealed class BottomBarEvent {}

final class BottomBarRandomChanged extends BottomBarEvent {}
final class BottomBarRepeatChanged extends BottomBarEvent {}