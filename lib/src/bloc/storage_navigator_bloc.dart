import 'dart:io';

import 'package:audio_flow/src/configuration/config.dart' show settings;
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
    items.sort((a, b) => a.fullPath.toLowerCase().compareTo(b.fullPath.toLowerCase()));
    if (event.dir != '/storage/emulated/0') {
      var parentDirList = directory.path.split(Platform.pathSeparator);
      parentDirList.removeLast();
      var parentDir = parentDirList.join(Platform.pathSeparator);
      items.insert(0, FileSystemCustomEntity(name: '..', fullPath: parentDir, isDir: true));
    }
    if (event.isChecked) {
      for (var item in items) {
        item.isChecked = event.isChecked;
      }
    }
    else {
      for (var item in items) {
        if (settings.pathsToScan.contains(item)) {
          item.isChecked = true;
        }
      }
    }

    logger.log.d('Current directory is ${event.dir}. Items:');
    logger.logNS.d(items);

    emit(StorageNavigatorCurrentState(items: items));
  }
}
