enum QsAudioState {
  /// The player has not loaded.
  idle,

  /// The player is loading.
  loading,

  /// The player is buffering audio and unable to play.
  buffering,

  /// The player is playing
  playing,

  /// The player is paused
  paused,

  /// The player has reached the end of the audio.
  completed,

  /// The player received error
  error,
}
