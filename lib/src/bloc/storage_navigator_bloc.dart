import 'dart:io';

import 'package:audio_flow/src/configuration/logger.dart';
import 'package:audio_flow/src/models/filesystem_entity.dart'
    show FileSystemCustomEntity;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'storage_navigator_event.dart';
part 'storage_navigator_state.dart';

class StorageNavigatorBloc
    extends Bloc<StorageNavigatorEvent, StorageNavigatorState> {
  StorageNavigatorBloc() : super(StorageNavigatorLoading()) {
    on<StorageNavigatorEvent>(_onStorageNavigatorEvent);
  }

  Future<void> _onStorageNavigatorEvent(
    StorageNavigatorEvent event,
    Emitter<StorageNavigatorState> emit,
  ) async {
    emit(StorageNavigatorLoading());
    var directory = Directory(event.dir);
    List<FileSystemEntity> entities = directory.listSync(recursive: false);
    var items = entities
        .map((e) => FileSystemCustomEntity.fromEntity(e))
        .toList();
    items.sort((a, b) => a.fullPath.compareTo(b.fullPath));
    if (event.dir != '/storage/emulated/0') {
      // List<String> pieces = event.dir.split(Platform.pathSeparator);
      // if (pieces.isNotEmpty) pieces.removeLast();
      // String parentPath = pieces.join(Platform.pathSeparator);
      // logger.log.d('parent path is $parentPath');

      items.insert(0, FileSystemCustomEntity(name: '..', fullPath: directory.parent.path, isDir: true));
    }

    logger.log.d('Current directory is ${event.dir}. Items:');
    logger.logNS.d(items);

    emit(StorageNavigatorCurrentState(items: items));
  }
}
