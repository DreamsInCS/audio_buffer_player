import Flutter
import UIKit
import AVFoundation

public class SwiftAudioBufferPlayerPlugin: NSObject, FlutterPlugin {
    let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)
    static var channel: FlutterMethodChannel!
    var engine: AVAudioEngine!
    var playerNode: AVAudioPlayerNode!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "audio_buffer_player", binaryMessenger: registrar.messenger())
        let instance = SwiftAudioBufferPlayerPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
        case "init":
            print("Initializing buffer player.")
            initAudio()
            result(nil)
        case "playAudio":
            let arr = call.arguments as! Array<NSNumber>
            handleAudio(audioData: arr)
            result(nil)
        case "deafenAudio":
            print("Deafening audio.")
            deafenAudio()
        case "undeafenAudio":
            print("Undeafening audio.")
            undeafenAudio()
        case "stopAudio":
            print("Stopped audio.")
            stopAudio()
            result(nil)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            print("Received unsupported method call. (default)")
            result(nil)
        }
    }
    
    public func initAudio() {
        print("iOS: Calling initAudio().")
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)
        engine.prepare()
        
        do {
            try engine.start()
        } catch {
            print("iOS: Engine start failed in initAudio()!")
            debugPrint(#line, error)
        }
    }

    public func handleAudio(audioData: Array<NSNumber>) {
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(audioData.count))

        print("iOS: audioData's count is \(audioData.count).")

        for (index, data) in audioData.enumerated() {
            audioBuffer!.floatChannelData![0][index] = data.floatValue
        }
        
        audioBuffer!.frameLength = UInt32(audioData.count)
        
        playerNode.play()
        playerNode.scheduleBuffer(audioBuffer!, at: nil, completionHandler: nil)
    }

    public func deafenAudio() {
        playerNode.stop()
    }

    public func undeafenAudio() {
        playerNode.play()
    }

    public func stopAudio() {
        playerNode.stop()
        SwiftAudioBufferPlayerPlugin.channel.invokeMethod("donePlaying", arguments: nil)
    }
}
