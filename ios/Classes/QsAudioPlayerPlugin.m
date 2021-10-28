#import "QsAudioPlayerPlugin.h"
#if __has_include(<qs_audio_player/qs_audio_player-Swift.h>)
#import <qs_audio_player/qs_audio_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qs_audio_player-Swift.h"
#endif

@implementation QsAudioPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQsAudioPlayerPlugin registerWithRegistrar:registrar];
}
@end
