import Flutter
import UIKit
import AVFoundation
//import AudioToolbox

public class SwiftAudioBufferPlayerPlugin: NSObject, FlutterPlugin {
    let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)
    
//    var audioFormat: AVAudioFormat!
    
//    let audioFormat = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: <#T##AudioFormatID#>, mFormatFlags: <#T##AudioFormatFlags#>, mBytesPerPacket: <#T##UInt32#>, mFramesPerPacket: <#T##UInt32#>, mBytesPerFrame: <#T##UInt32#>, mChannelsPerFrame: <#T##UInt32#>, mBitsPerChannel: <#T##UInt32#>, mReserved: <#T##UInt32#>)
    
    var engine: AVAudioEngine!
    var playerNode: AVAudioPlayerNode!
//    var audioQueue: AudioQueueRef!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_buffer_player", binaryMessenger: registrar.messenger())
        let instance = SwiftAudioBufferPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
        case "init":
            initAudio()
            result(nil)
        case "playAudio":
            let arr = call.arguments as! Array<NSNumber>
            playAudio(audioData: arr)
            result(nil)
        case "stopAudio":
            print("Stopped audio.")
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
//        AudioQueueNewOutput(audioFormat, <#T##inCallbackProc: AudioQueueOutputCallback##AudioQueueOutputCallback##(UnsafeMutableRawPointer?, AudioQueueRef, AudioQueueBufferRef) -> Void#>, <#T##inUserData: UnsafeMutableRawPointer?##UnsafeMutableRawPointer?#>, CFRunLoop?, <#T##inCallbackRunLoopMode: CFString?##CFString?#>, <#T##inFlags: UInt32##UInt32#>, audioQueue)
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        engine.attach(playerNode)
        
//        format = engine.mainMixerNode.outputFormat(forBus: 0)
        
        engine.connect(playerNode, to:engine.mainMixerNode, format: audioFormat)
        engine.prepare()
        
        do {
            try engine.start()
        } catch {
            print("iOS: Engine start failed in initAudio()!")
            debugPrint(#line, error)
        }
    }
// Debugging purposes. Meant to test if AVAudioEngine even works with my current setup via a file.
//    public func playTestAudio() {
//        let file = AVAudioFile(forReading: <#T##URL#>)
//    }
    
    public func playAudio(audioData: Array<NSNumber>) {
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(audioData.count))

        print("iOS: audioData's count is \(audioData.count).")

        for (index, data) in audioData.enumerated() {
            audioBuffer!.floatChannelData![0][index] = data.floatValue
        }
        
        audioBuffer!.frameLength = UInt32(audioData.count)
        
        playerNode.play()
        playerNode.scheduleBuffer(audioBuffer!, at: nil, completionHandler: nil)
    }
    
    public func stopAudio() {
        engine.stop()
    }
}
