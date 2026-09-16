part of 'storage_navigator_bloc.dart';

@immutable
sealed class StorageNavigatorEvent {
  const StorageNavigatorEvent();
}


class StorageNavigatorLoadEvent extends StorageNavigatorEvent {
  final FileSystemCustomEntity item;
  const StorageNavigatorLoadEvent({required this.item});
}


class StorageNavigatorCheckEvent extends StorageNavigatorEvent {
  final List<FileSystemCustomEntity> items;
  final int itemIndex;
  const StorageNavigatorCheckEvent({required this.items, required this.itemIndex});
}