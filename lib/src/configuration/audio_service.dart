import 'package:audio_service/audio_service.dart';

class AudioFlowService {
  late AudioHandler audioHandler; // singleton.
  
  void initAudioService() async {
    audioHandler = await AudioService.init(
      builder: () => BaseAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.audio_flow.audio',
        androidNotificationChannelName: 'Audio Service Demo',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}

final audioFlowService = AudioFlowService();