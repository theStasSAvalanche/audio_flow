part of 'storage_navigator_bloc.dart';

@immutable
sealed class StorageNavigatorState {
  final List<FileSystemCustomEntity> items;
  const StorageNavigatorState({required this.items});
}

final class StorageNavigatorLoading extends StorageNavigatorState {
  const StorageNavigatorLoading({super.items = const []});
}

final class StorageNavigatorCurrentState extends StorageNavigatorState {
  const StorageNavigatorCurrentState({required super.items});
}
