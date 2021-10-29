import 'package:qs_audio_player/audio_player_position.dart';
import 'package:qs_audio_player/audio_player_state.dart';
import 'package:qs_audio_player/audio_track.dart';
import 'package:rxdart/rxdart.dart';

mixin AudioPlayerProvider {
  final currentTrackStream = BehaviorSubject<AudioTrack?>(sync: true);
  final currentQueueStream = BehaviorSubject<List<AudioTrack>?>();
  final currentStateStream = BehaviorSubject<AudioPlayerState>.seeded(
    AudioPlayerState.Idle,
  );
  final currentPositionStream = BehaviorSubject<AudioPlayerPosition>();

  Future<void> init();

  Future<void> doSetSource(List<AudioTrack> tracks);

  Future<void> doPlay();

  Future<void> doPause();

  Future<void> doStop();

  Future<void> doSeekTo(Duration position);

  Future<void> doFastForward(Duration time);

  Future<void> doRewind(Duration rewind);

  Future<void> doChangeById(String trackId);

  Future<void> dispose() async {
    await currentTrackStream.close();
    await currentQueueStream.close();
    await currentStateStream.close();
    await currentPositionStream.close();
  }
}
