import 'package:qs_audio_player/audio_player_service.dart';
import 'package:qs_audio_player/just_audio_service.dart';

export 'package:qs_audio_player/audio_player_position.dart';
export 'package:qs_audio_player/audio_player_provider.dart';
export 'package:qs_audio_player/audio_player_service.dart';
export 'package:qs_audio_player/audio_player_state.dart';
export 'package:qs_audio_player/audio_track.dart';
export 'package:qs_audio_player/just_audio_service.dart';
export 'package:qs_audio_player/widgets/audio_player_wrappers.dart';
export 'package:qs_audio_player/widgets/qs_seek_bar.dart';

class QsAudio {
  static late AudioPlayerService _instance;

  static AudioPlayerService get instance => _instance;

  static Future<void> init({
    required String channelId,
    String? channelName,
  }) async {
    _instance = AudioPlayerService(
      provider: JustAudioProvider(
        channelId: channelId,
        channelName: channelId,
      ),
    );
    return _instance.init();
  }
}
