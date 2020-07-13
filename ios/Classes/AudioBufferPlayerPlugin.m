#import "AudioBufferPlayerPlugin.h"
#if __has_include(<audio_buffer_player/audio_buffer_player-Swift.h>)
#import <audio_buffer_player/audio_buffer_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "audio_buffer_player-Swift.h"
#endif

@implementation AudioBufferPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioBufferPlayerPlugin registerWithRegistrar:registrar];
}
@end
