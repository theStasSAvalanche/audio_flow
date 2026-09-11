import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart'
    show DeviceInfoPlugin, AndroidDeviceInfo;
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
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final int sdkVersion = androidInfo.version.sdkInt;
    logger.log.d("Android SDK Version: $sdkVersion");

    late PermissionStatus status;
    if (sdkVersion >= 33) {
      status = await Permission.audio.status;

      if (!status.isGranted) {
        status = await Permission.audio.request();
      }
    }
    else {
      status = await Permission.storage.status;

      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }
    if (status.isGranted) {
      emit(PermissionGranted());
    } else {
      emit(PermissionDenied());
    }
  }
}
