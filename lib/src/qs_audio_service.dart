import 'package:flutter/widgets.dart';
import 'package:qs_audio_player/src/qs_audio_position.dart';
import 'package:qs_audio_player/src/qs_audio_provider.dart';
import 'package:qs_audio_player/src/qs_audio_state.dart';
import 'package:qs_audio_player/src/qs_audio_track.dart';

class QsAudioService {
  final ValueNotifier<List<QsAudioTrack>?> currentQueue = ValueNotifier(null);
  final ValueNotifier<QsAudioTrack?> currentTrack = ValueNotifier(null);
  final ValueNotifier<QsAudioState> currentState = ValueNotifier(
    QsAudioState.idle,
  );
  final ValueNotifier<QsAudioPosition?> currentPosition = ValueNotifier(null);

  final QsAudioProvider provider;

  QsAudioService({required this.provider});

  Future<void> init() async {
    await provider.init();
    currentTrack.value = provider.currentTrackStream.valueOrNull;
    provider.currentTrackStream.listen((value) {
      currentTrack.value = value;
    });
    currentQueue.value = provider.currentQueueStream.valueOrNull;
    provider.currentQueueStream.listen((value) {
      currentQueue.value = value;
    });
    currentState.value = provider.currentStateStream.value;
    provider.currentStateStream.listen((value) {
      currentState.value = value;
    });
    currentPosition.value = provider.currentPositionStream.valueOrNull;
    provider.currentPositionStream.listen((value) {
      currentPosition.value = value;
    });
  }

  Future<void> setSource(
    List<QsAudioTrack> tracks, {
    bool start = true,
    String? initialTrackId,
  }) async {
    await provider.init();
    if (provider.currentStateStream.value != QsAudioState.idle) {
      await pause();
    }
    await provider.doSetSource(tracks);
    if (initialTrackId != null) {
      await changeByTrackId(initialTrackId);
    }
    // else if (tracks.isNotEmpty) {
    //   await changeByTrack(tracks[0]);
    // } else {
    //   await stop();
    // }
    if (start) {
      await play();
    }
  }

  Future<void> play() async {
    await provider.doPlay();
  }

  Future<void> pause() async {
    await provider.doPause();
  }

  Future<void> toggle() async {
    if (currentState.value == QsAudioState.playing) {
      await provider.doPause();
    } else if (currentState.value == QsAudioState.paused) {
      await provider.doPlay();
    } else if (currentState.value == QsAudioState.completed) {
      if (currentTrack.value != null) {
        await provider.doChangeById(currentTrack.value!.uri);
      }
    }
  }

  Future<void> seekTo(Duration position) async {
    await provider.doSeekTo(position);
  }

  Future<void> fastForward(Duration time) async {
    await provider.doFastForward(time);
  }

  Future<void> rewind(Duration time) async {
    await provider.doRewind(time);
  }

  Future<void> changeByTrack(QsAudioTrack track) async {
    await changeByTrackId(track.uri);
  }

  Future<void> changeByTrackId(String id) async {
    await provider.doChangeById(id);
  }

  Future<void> skipToNext() async {
    await provider.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await provider.skipToPrevious();
  }

  Future<void> stop() async {
    await provider.doStop();
  }
}
