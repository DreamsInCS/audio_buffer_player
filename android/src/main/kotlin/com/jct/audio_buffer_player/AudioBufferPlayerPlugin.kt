package com.jct.audio_buffer_player

import android.annotation.TargetApi
import android.content.ContentValues.TAG
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Process
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** AudioBufferPlayerPlugin */
public class AudioBufferPlayerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var audioThread : HandlerThread
  private lateinit var audioHandler : Handler
  private lateinit var channel : MethodChannel
  private lateinit var track : AudioTrack
  private var sampleRate = 22050

  // May vary based on audio quality.
  private val minBufferSize = AudioTrack.getMinBufferSize(
          sampleRate,
          AudioFormat.CHANNEL_OUT_MONO,
          AudioFormat.ENCODING_PCM_16BIT
  )
  

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "audio_buffer_player")
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "audio_buffer_player")
      channel.setMethodCallHandler(AudioBufferPlayerPlugin())
    }
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "playAudio" -> {
        playAudio(audioData = call.arguments as List<Int>)
        result.success(null)
      }
      "deafenAudio" -> {
        deafenAudio()
      }
      "undeafenAudio" -> {
        undeafenAudio()
      }
      "stopAudio" -> {
        stopAudio()
      }
      "init" -> {
        init()
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  @TargetApi(Build.VERSION_CODES.M)
  private fun init() {
    Log.d(TAG, "init() from Android.")

    // Setup message loop
    audioThread = HandlerThread(TAG, Process.THREAD_PRIORITY_AUDIO)
    audioThread.start()
    audioHandler = Handler(audioThread.looper)

    audioHandler.post(
      Runnable {
        track = AudioTrack.Builder()
                .setAudioAttributes(AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build())
                .setAudioFormat(AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(sampleRate)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build())
                .setBufferSizeInBytes(minBufferSize)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()
                
        track.play()
      }
    )

    Log.d(TAG, "init() from Android complete.")
  }

  @TargetApi(Build.VERSION_CODES.M)
    private fun playAudio(audioData: List<Int>) {
      if (track.playState != AudioTrack.PLAYSTATE_PLAYING) {
        audioHandler.post(
          Runnable {
            track = AudioTrack.Builder()
                .setAudioAttributes(AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build())
                .setAudioFormat(AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(sampleRate)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build())
                .setBufferSizeInBytes(minBufferSize)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()

                track.play()
          }
        )
      }

    val shortData = ShortArray(audioData.size)

    for ((i, data) in audioData.withIndex()) {
      shortData[i] = data.toShort()
    }

      audioHandler.post(
        Runnable {
          track.write(shortData, 0, audioData.size, AudioTrack.WRITE_BLOCKING)
        }
      )
  }

  private fun undeafenAudio() {
    // audioHandler.post(
    //   Runnable {
      Log.d(TAG, "Undeafening audio.")
        track.play()
    //   }
    // )
  }

  private fun deafenAudio() {
    // audioHandler.postAtFrontOfQueue(
    //   Runnable {
      Log.d(TAG, "Deafening audio.")
      track.stop()
          // track.pause()
          // track.flush()
    //   }
    // )
  }

  private fun stopAudio() {
    // audioThread.quitSafely()
    // audioThread.join()

    track.stop()
    Handler(Looper.getMainLooper()).post {
      channel.invokeMethod("donePlaying", null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
