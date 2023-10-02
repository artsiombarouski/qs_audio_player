import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qs_audio_player/src/qs_audio_position.dart';
import 'package:qs_audio_player/src/qs_audio_provider.dart';
import 'package:qs_audio_player/src/qs_audio_state.dart';
import 'package:qs_audio_player/src/qs_audio_track.dart';
import 'package:rxdart/rxdart.dart';

class JustAudioProvider with QsAudioProvider {
  /// Provider impls

  bool _isInitialized = false;

  late AudioPlayerHandler _handler;
  late StreamSubscription _queueSubscription;
  late StreamSubscription _trackSubscription;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;

  final String channelId;
  final String channelName;

  JustAudioProvider({
    required this.channelId,
    required this.channelName,
  });

  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _handler = await AudioService.init(
      builder: () => JustAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: channelId,
        androidNotificationChannelName: channelName,
        androidNotificationOngoing: false,
      ),
    );
    currentQueueStream.value =
        _handler.queue.value.map((e) => QsAudioTrack.fromMediaItem(e)).toList();
    _queueSubscription = _handler.queueState.listen((event) {});
    _queueSubscription = _handler.queue.listen((event) {
      currentQueueStream.value =
          event.map((e) => QsAudioTrack.fromMediaItem(e)).toList();
    });
    currentTrackStream.value = _handler.mediaItem.value != null
        ? QsAudioTrack.fromMediaItem(_handler.mediaItem.value!)
        : null;
    _trackSubscription = _handler.mediaItem.listen((event) {
      currentTrackStream.value =
          event != null ? QsAudioTrack.fromMediaItem(event) : null;
    });
    await _syncPlayerState();
    _playbackSubscription = _handler.playbackState.listen((event) {
      _syncPlayerState();
    });
    _durationSubscription = _handler.duration.listen((event) {
      _syncPlayerState();
    });
    _positionSubscription = AudioService.position.listen((event) {
      _syncPlayerState();
    });
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    await _queueSubscription.cancel();
    await _trackSubscription.cancel();
    await _durationSubscription.cancel();
    await _playbackSubscription.cancel();
    await _positionSubscription.cancel();
  }

  Future<void> _syncPlayerState() async {
    if (!_isInitialized) {
      return;
    }
    final playbackState = _handler.playbackState.value;
    final processingState = playbackState.processingState;
    late QsAudioState currentState;
    switch (processingState) {
      case AudioProcessingState.idle:
        currentState = QsAudioState.idle;
        break;
      case AudioProcessingState.error:
        currentState = QsAudioState.error;
        break;
      case AudioProcessingState.buffering:
        currentState = QsAudioState.buffering;
        break;
      case AudioProcessingState.ready:
        currentState =
            playbackState.playing ? QsAudioState.playing : QsAudioState.paused;
        break;
      case AudioProcessingState.completed:
        currentState = QsAudioState.completed;
        break;
      case AudioProcessingState.loading:
        currentState = QsAudioState.loading;
        break;
    }
    currentStateStream.value = currentState;
    var duration = _handler.duration.value;
    if (duration == null || duration == Duration.zero) {
      duration = _handler.mediaItem.value?.duration;
    }
    currentPositionStream.value = QsAudioPosition(
      duration: duration,
      bufferedPosition: playbackState.bufferedPosition,
      position: playbackState.position,
    );
  }

  @override
  Future<void> doSetSource(List<QsAudioTrack> tracks) async {
    await _handler.setSource(tracks.map((e) => e.toMediaItem()).toList());
  }

  @override
  Future<void> doChangeById(String trackId) async {
    _handler.skipToMediaItem(trackId);
  }

  @override
  Future<void> doPlay() async {
    await _handler.play();
  }

  @override
  Future<void> doPause() async {
    await _handler.pause();
  }

  @override
  Future<void> doFastForward(Duration time) async {
    await _handler.seek(time);
  }

  @override
  Future<void> doRewind(Duration rewind) async {
    await _handler.seek(-rewind);
  }

  @override
  Future<void> doSeekTo(Duration position) async {
    await _handler.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await _handler.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _handler.skipToPrevious();
  }

  @override
  Future<void> doStop() async {
    await _handler.stop();
  }
}

class QueueState {
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
      this.queue, this.queueIndex, this.shuffleIndices, this.repeatMode);

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;

  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;

  Future<void> moveQueueItem(int currentIndex, int newIndex);

  ValueStream<double> get volume;

  Future<void> setVolume(double volume);

  ValueStream<double> get speed;

  Future<void> skipToMediaItem(String itemId);

  ValueStream<Duration?> get duration;

  Future<void> setSource(List<MediaItem> queue);
}

class JustAudioHandler extends BaseAudioHandler
    with SeekHandler
    implements AudioPlayerHandler {
  final BehaviorSubject<List<MediaItem>> _recentSubject =
      BehaviorSubject.seeded(<MediaItem>[]);

  @override
  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<Duration?> duration = BehaviorSubject.seeded(null);

  final _player = AudioPlayer();
  var _playlist = ConcatenatingAudioSource(children: []);

  JustAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // For Android 11, record the most recent item so it can be resumed.
    mediaItem
        .whereType<MediaItem>()
        .listen((item) => _recentSubject.add([item]));
    _player.durationStream.listen((event) {
      duration.value = event;
      if (event != null &&
          mediaItem.value != null &&
          (mediaItem.value?.duration == null ||
              mediaItem.value?.duration == Duration.zero)) {
        mediaItem.value = mediaItem.value!.copyWith(duration: event);
      }
    });
    // Broadcast media item changes.
    Rx.combineLatest4<int?, List<MediaItem>, bool, List<int>?, MediaItem?>(
        _player.currentIndexStream,
        queue,
        _player.shuffleModeEnabledStream,
        _player.shuffleIndicesStream,
        (index, queue, shuffleModeEnabled, shuffleIndices) {
      final queueIndex =
          getQueueIndex(index, shuffleModeEnabled, shuffleIndices);
      return (queueIndex != null && queueIndex < queue.length)
          ? queue[queueIndex]
          : null;
    }).whereType<MediaItem>().distinct().listen(mediaItem.add);
    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen(_broadcastState);
    _player.shuffleModeEnabledStream
        .listen((enabled) => _broadcastState(_player.playbackEvent));
    // In this example, the service stops when reaching the end.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
        _player.seek(Duration.zero, index: 0);
      }
    });
    // Broadcast the current queue.
    _effectiveSequence
        .map((sequence) =>
            sequence.map((source) => _mediaItemExpando[source]!).toList())
        .pipe(queue);
    // Load the playlist.
    _playlist.addAll(queue.value.map(_itemToSource).toList());
    await _player.setAudioSource(_playlist);
  }

  Future<void> close() async {
    speed.close();
    volume.close();
    duration.close();
    _recentSubject.close();
  }

  /// A stream of the current effective sequence from just_audio.
  Stream<List<IndexedAudioSource>> get _effectiveSequence => Rx.combineLatest3<
              List<IndexedAudioSource>?,
              List<int>?,
              bool,
              List<IndexedAudioSource>?>(_player.sequenceStream,
          _player.shuffleIndicesStream, _player.shuffleModeEnabledStream,
          (sequence, shuffleIndices, shuffleModeEnabled) {
        if (sequence == null) return [];
        if (!shuffleModeEnabled) return sequence;
        if (shuffleIndices == null) return null;
        if (shuffleIndices.length != sequence.length) return null;
        return shuffleIndices.map((i) => sequence[i]).toList();
      }).whereType<List<IndexedAudioSource>>();

  /// Computes the effective queue index taking shuffle mode into account.
  int? getQueueIndex(
      int? currentIndex, bool shuffleModeEnabled, List<int>? shuffleIndices) {
    final effectiveIndices = _player.effectiveIndices ?? [];
    final shuffleIndicesInv = List.filled(effectiveIndices.length, 0);
    for (var i = 0; i < effectiveIndices.length; i++) {
      shuffleIndicesInv[effectiveIndices[i]] = i;
    }
    return (shuffleModeEnabled &&
            ((currentIndex ?? 0) < shuffleIndicesInv.length))
        ? shuffleIndicesInv[currentIndex ?? 0]
        : currentIndex;
  }

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  @override
  Stream<QueueState> get queueState =>
      Rx.combineLatest3<List<MediaItem>, PlaybackState, List<int>, QueueState>(
          queue,
          playbackState,
          _player.shuffleIndicesStream.whereType<List<int>>(),
          (queue, playbackState, shuffleIndices) => QueueState(
                queue,
                playbackState.queueIndex,
                playbackState.shuffleMode == AudioServiceShuffleMode.all
                    ? shuffleIndices
                    : null,
                playbackState.repeatMode,
              )).where((state) =>
          state.shuffleIndices == null ||
          state.queue.length == state.shuffleIndices!.length);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed.add(speed);
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume.add(volume);
    await _player.setVolume(volume);
  }

  final _mediaItemExpando = Expando<MediaItem>();

  AudioSource _itemToSource(MediaItem mediaItem) {
    final audioSource = AudioSource.uri(Uri.parse(mediaItem.id));
    _mediaItemExpando[audioSource] = mediaItem;
    return audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) =>
      mediaItems.map(_itemToSource).toList();

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    return queue.value;
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    return Stream.value(queue.value)
        .map((_) => <String, dynamic>{})
        .shareValue();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(_itemsToSources(mediaItems));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _playlist.insert(index, _itemToSource(mediaItem));
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _playlist.addAll(_itemsToSources(queue));
  }

  @override
  Future<void> setSource(List<MediaItem> queue) async {
    final newSource =
        ConcatenatingAudioSource(children: _itemsToSources(queue));
    _playlist = newSource;
    await _player.setAudioSource(_playlist);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    _mediaItemExpando[_player.sequence![index]] = mediaItem;
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> moveQueueItem(int currentIndex, int newIndex) async {
    await _playlist.move(currentIndex, newIndex);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.children.length) return;
    // This jumps to the beginning of the queue item at [index].
    _player.seek(Duration.zero,
        index: _player.shuffleModeEnabled
            ? _player.shuffleIndices![index]
            : index);
  }

  @override
  Future<void> skipToMediaItem(String itemId) async {
    final index = queue.value.indexWhere((e) => e.id == itemId);
    if (index < 0) return;
    return skipToQueueItem(index);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    super.stop();
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = getQueueIndex(
          event.currentIndex,
          _player.shuffleModeEnabled,
          _player.shuffleIndices,
        ) ??
        0;
    final hasPrevious = queueIndex > 0;
    final hasNext = queueIndex < (queue.value.length - 1);
    playbackState.add(playbackState.value.copyWith(
      controls: [
        if (hasPrevious) MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        if (hasNext) MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }
}
