import 'dart:io';

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
    entities.sort((a, b) => a.path.compareTo(b.path));
    var items = entities
        .map((e) => FileSystemCustomEntity.fromEntity(e))
        .toList();

    emit(StorageNavigatorCurrentState(items: items));
  }
}
