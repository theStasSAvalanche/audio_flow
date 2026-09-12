import 'dart:io';

import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/configuration/logger.dart';
import 'package:audio_flow/src/instruments/storage_audio_reader.dart' show checkEntityIsAudio;
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
    List<FileSystemCustomEntity> items = [];
    for (var entity in entities) {
      if (entity is File && !checkEntityIsAudio(entity.path)) {
        continue;
      }
      var item = FileSystemCustomEntity.fromEntity(entity);
      if (event.isChecked) {
        item.isChecked = event.isChecked;
      }
      else if (settings.semiCheckedPaths.contains(item)) {
        item.isChecked = null;
      }
      else if (settings.pathsToScan.contains(item)) {
        item.isChecked = true;
      }
      items.add(item);
    }  
    items.sort((a, b) => a.fullPath.toLowerCase().compareTo(b.fullPath.toLowerCase()));

    logger.log.d('Paths to scan in settings: ${settings.pathsToScan}');
    
    if (event.dir != '/storage/emulated/0') {
      var parentDirList = directory.path.split(Platform.pathSeparator);
      parentDirList.removeLast();
      var parentDir = parentDirList.join(Platform.pathSeparator);
      items.insert(0, FileSystemCustomEntity(name: '..', fullPath: parentDir, isDir: true));
    }
    

    logger.logNS.d('Current directory is ${event.dir}. Items:');
    logger.logNS.d(items);

    emit(StorageNavigatorCurrentState(items: items));
  }
}
