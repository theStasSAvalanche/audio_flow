import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<RequestPermissionEvent>(_onRequestPermission);
    add(RequestPermissionEvent());
  }

  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    final status = await Permission.audio.request();
    if (status.isGranted) {
      emit(PermissionGranted());
    } else {
      emit(PermissionDenied());
    }
  }
}