import 'dart:io';

import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/configuration/logger.dart';
import 'package:audio_flow/src/instruments/storage_audio_reader.dart'
    show
        checkEntityIsAudio,
        setParentDirectoriesSemiChecked,
        getFoldersRecursivly,
        setDirectoryContentUncheckedRecursievly;
import 'package:audio_flow/src/models/filesystem_entity.dart'
    show FileSystemCustomEntity;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'storage_navigator_event.dart';
part 'storage_navigator_state.dart';

class StorageNavigatorBloc
    extends Bloc<StorageNavigatorEvent, StorageNavigatorState> {
  StorageNavigatorBloc() : super(StorageNavigatorLoading()) {
    on<StorageNavigatorLoadEvent>(_onStorageNavigatorLoadEvent);
    on<StorageNavigatorCheckEvent>(_onStorageNavigatorCheckEvent);
  }

  Future<void> _onStorageNavigatorLoadEvent(
    StorageNavigatorLoadEvent event,
    Emitter<StorageNavigatorState> emit,
  ) async {
    logger.log.d('Start storage loading of ${event.item.fullPath}');
    emit(StorageNavigatorLoading());
    var directory = Directory(event.item.fullPath);
    List<FileSystemEntity> entities = directory.listSync(
      recursive: false,
      followLinks: false,
    );
    List<FileSystemCustomEntity> items = [];

    for (var entity in entities) {
      if (entity.path.split(Platform.pathSeparator).last.startsWith('.')) {
        continue;
      }
      if (entity is File && !checkEntityIsAudio(entity.path)) {
        continue;
      }

      var item = FileSystemCustomEntity.fromEntity(entity);
      items.add(item);
    }
    logger.logNS.d('Items: $items');

    // work with '..'
    if (settings.pathsToScan.contains(event.item)) {
      event.item.isChecked = true;
    }
    // collect checkboxes values from settings structures
    for (var thisItem in items) {
      if (settings.uncheckedFiles.contains(thisItem)) {
        thisItem.isChecked = false;
      } else if (settings.semiCheckedPaths.contains(thisItem)) {
        thisItem.isChecked = null;
      } else if (settings.pathsToScan.contains(thisItem)) {
        thisItem.isChecked = true;
      } else if (!thisItem.isDir && event.item.isChecked == true) {
        thisItem.isChecked = true;
      }
      logger.logNS.d('Item: $thisItem');
      logger.logNS.d('Checked: ${thisItem.isChecked}');
    }

    items.sort((a, b) => a.fullPath.compareTo(b.fullPath));
    if (event.item.fullPath != settings.localStorage ||
        event.item.fullPath != settings.externalStorage) {
      var firstItem = FileSystemCustomEntity(
        name: '..',
        fullPath: event.item.fullPath,
        isDir: true,
      );
      items.insert(0, firstItem);
    }

    emit(StorageNavigatorCurrentState(items: items));
  }

  Future<void> _onStorageNavigatorCheckEvent(
    StorageNavigatorCheckEvent event,
    Emitter<StorageNavigatorState> emit,
  ) async {
    emit(StorageNavigatorLoading());
    var items = event.items;
    var index = event.itemIndex;
    var item = items[index];
    var isChecked = true;
    // if (item.isChecked == null || item.isChecked == false) {
    //   isChecked = true;
    // }
    if (item.isChecked == true) {
      isChecked = false;
    }
    try {
      if (items[index].isDir && isChecked) {
        var subDirectories = getFoldersRecursivly(item);
        setDirectoryContentUncheckedRecursievly(items[index]);
        for (var dir in subDirectories) {
          settings.pathsToScan.add(dir);
        }
        items[index].isChecked = true;
      } else if (items[index].isDir && !isChecked) {
        setDirectoryContentUncheckedRecursievly(item);
        settings.uncheckedFiles.add(items[index]);
        items[index].isChecked = false;
      } else if (!items[index].isDir && isChecked) {
        settings.uncheckedFiles.remove(item);
        settings.pathsToScan.add(item);
        items[index].isChecked = true;
      } else {
        // (!items[index].isDir && !event.isChecked)
        settings.uncheckedFiles.add(item);
        settings.pathsToScan.remove(item);
        items[index].isChecked = false;
      }
      setParentDirectoriesSemiChecked(item);
    }
    catch (e) {
      logger.log.e(e);
    }

    if (item.name == '..') {
      add(StorageNavigatorLoadEvent(item: item));
      return;
    }

    emit(StorageNavigatorCurrentState(items: items));
  }
}
