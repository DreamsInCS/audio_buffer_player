import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:audio_buffer_player/audio_buffer_player.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioBufferPlayer _bufferPlayer;
  String _platformVersion = 'Unknown';
  Socket socket;

  @override
  void initState() {
    super.initState();
    _bufferPlayer = AudioBufferPlayer();
    initSocket();
    initPlatformState();
  }

  void initSocket() {
    socket = io('http://8cf965702e98.ngrok.io', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('playaudio', (audio) {
      _bufferPlayer.playAudio(List<int>.from(audio));
    });

    socket.connect();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.`
    try {
      platformVersion = await AudioBufferPlayer.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
