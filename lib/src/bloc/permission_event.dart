part of 'permission_bloc.dart';

@immutable
sealed class PermissionEvent {}

final class RequestPermissionEvent extends PermissionEvent {}