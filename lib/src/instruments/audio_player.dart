import 'package:audioplayers/audioplayers.dart';


class AudioFlowPlayer{
  static final AudioFlowPlayer _instance = AudioFlowPlayer._internal();

  AudioFlowPlayer._internal();

  factory AudioFlowPlayer() {
    return _instance;
  }

  final audioPlayer = AudioPlayer();

  // 1. Play from App Assets
  // File location: project_root/assets/audio/song.mp3
  // Note: Omit 'assets/' from the path as AssetSource assumes it by default.
  // Future<void> playAssetAudio() async {
  //   await audioPlayer.play(AssetSource('audio/song.mp3'));
  // }

  // // 2. Play from Internet URL
  // Future<void> playNetworkAudio() async {
  //   String url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  //   await audioPlayer.play(UrlSource(url));
  // }

  // 3. Play from local Android device storage file path
  Future<void> playDeviceFileAudio(String filePath) async {
    await audioPlayer.play(DeviceFileSource(filePath));
  }

  // Control Functions
  Future<void> pauseAudio() async => await audioPlayer.pause();
  Future<void> resumeAudio() async => await audioPlayer.resume();
  Future<void> stopAudio() async => await audioPlayer.stop();

  void dispose() {
    audioPlayer.dispose(); // Always release resources when done
  }
}


final player = AudioFlowPlayer();