class QsAudioPosition {
  final Duration? duration;
  final Duration position;
  final Duration bufferedPosition;

  QsAudioPosition({
    this.duration,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
  });

  bool get isReady => duration != null;
}
