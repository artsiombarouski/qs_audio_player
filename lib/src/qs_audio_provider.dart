import 'package:qs_audio_player/src/qs_audio_position.dart';
import 'package:qs_audio_player/src/qs_audio_state.dart';
import 'package:qs_audio_player/src/qs_audio_track.dart';
import 'package:rxdart/rxdart.dart';

mixin QsAudioProvider {
  final currentTrackStream = BehaviorSubject<QsAudioTrack?>(sync: true);
  final currentQueueStream = BehaviorSubject<List<QsAudioTrack>?>();
  final currentStateStream = BehaviorSubject<QsAudioState>.seeded(
    QsAudioState.idle,
  );
  final currentPositionStream = BehaviorSubject<QsAudioPosition>();

  Future<void> init();

  Future<void> doSetSource(List<QsAudioTrack> tracks);

  Future<void> doPlay();

  Future<void> doPause();

  Future<void> doStop();

  Future<void> doSeekTo(Duration position);

  Future<void> doFastForward(Duration time);

  Future<void> doRewind(Duration rewind);

  Future<void> doChangeById(String trackId);

  Future<void> skipToNext();

  Future<void> skipToPrevious();

  Future<void> dispose() async {
    await currentTrackStream.close();
    await currentQueueStream.close();
    await currentStateStream.close();
    await currentPositionStream.close();
  }
}
