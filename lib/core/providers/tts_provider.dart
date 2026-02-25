import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tts_service.dart';

final ttsProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() {
    service.stop();
  });
  return service;
});