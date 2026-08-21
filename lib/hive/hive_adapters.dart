import 'dart:typed_data';
import 'package:hive_ce/hive.dart';

import 'package:audio_flow/src/models/audio_flow_file.dart' show AudioFlowFile;

part 'hive_adapters.g.dart';


@GenerateAdapters([
  AdapterSpec<AudioFlowFile>(),
])
class HiveAdapters {}
