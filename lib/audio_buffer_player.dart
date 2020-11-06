import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class AudioBufferPlayer {
  static const INT16_MAX = 32767;
  static const MethodChannel _channel =
      const MethodChannel('audio_buffer_player');

  bool donePlaying;

  AudioBufferPlayer() {
    donePlaying = false;
    init();
  }

  void init() async {
    await _channel.invokeMethod('init');
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'donePlaying':
        donePlaying = true;
        return;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  void playAudio(List<int> audioData) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('playAudio', audioData);
    } else if (Platform.isIOS) {
      final doubleAudioData = List<double>();

      for (int data in audioData) {
        doubleAudioData.add((data.toDouble() / INT16_MAX));
      }

      await _channel.invokeMethod('playAudio', doubleAudioData);
    }
  }

  void deafenAudio() async {
    await _channel.invokeMethod('deafenAudio', null);
  }

  void undeafenAudio() async {
    await _channel.invokeMethod('undeafenAudio', null);
  }

  void stopAudio() async {
    _channel.invokeMethod('stopAudio');
  }
}
