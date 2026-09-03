part of 'storage_navigator_bloc.dart';

@immutable
sealed class StorageNavigatorEvent {
  final String dir;
  final bool isChecked;
  const StorageNavigatorEvent({required this.dir, required this.isChecked});
}

class StorageNavigatorScanEvent extends StorageNavigatorEvent {
  const StorageNavigatorScanEvent({required super.dir, required super.isChecked});
}