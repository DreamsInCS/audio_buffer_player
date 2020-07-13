import 'dart:async';
import 'package:flutter/services.dart';

class AudioBufferPlayer {
  static const MethodChannel _channel =
      const MethodChannel('audio_buffer_player');

  AudioBufferPlayer() {
    init();
  }

  void init() async {
    await _channel.invokeMethod('init');
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void playAudio(List<double> audioData) async {
    await _channel.invokeMethod('playAudio', audioData);
  }

  void stopAudio() async {
    _channel.invokeMethod('stopAudio');
  }
}
