import 'package:qs_audio_player/src/just_audio_service.dart';
import 'package:qs_audio_player/src/qs_audio_service.dart';

export 'package:qs_audio_player/src/just_audio_service.dart';
export 'package:qs_audio_player/src/qs_audio_position.dart';
export 'package:qs_audio_player/src/qs_audio_provider.dart';
export 'package:qs_audio_player/src/qs_audio_service.dart';
export 'package:qs_audio_player/src/qs_audio_state.dart';
export 'package:qs_audio_player/src/qs_audio_track.dart';
export 'package:qs_audio_player/src/widgets/qs_audio_wrappers.dart';
export 'package:qs_audio_player/src/widgets/qs_seek_bar.dart';

class QsAudio {
  static late QsAudioService _instance;

  static QsAudioService get instance => _instance;

  static Future<void> init({
    required String channelId,
    String? channelName,
  }) async {
    _instance = QsAudioService(
      provider: JustAudioProvider(
        channelId: channelId,
        channelName: channelName ?? channelId,
      ),
    );
    return _instance.init();
  }
}
