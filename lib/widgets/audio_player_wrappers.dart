import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qs_audio_player/audio_player_position.dart';
import 'package:qs_audio_player/audio_player_service.dart';
import 'package:qs_audio_player/audio_player_state.dart';
import 'package:qs_audio_player/audio_track.dart';

abstract class QsAudioServiceWidgetWrapper<T> extends StatefulWidget {
  final ValueWidgetBuilder<T> builder;
  final AudioPlayerService? service;
  final Widget? child;

  const QsAudioServiceWidgetWrapper({
    Key? key,
    required this.builder,
    this.service,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => QsAudioServiceWidgetWrapperState<T>();

  AudioPlayerService get resolvedService =>
      service ?? AudioPlayerService.instance;

  ValueListenable<T> get listenable => getListenable(resolvedService);

  ValueListenable<T> getListenable(AudioPlayerService service);
}

class QsAudioServiceWidgetWrapperState<T>
    extends State<QsAudioServiceWidgetWrapper<T>> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: widget.listenable,
      builder: widget.builder,
      child: widget.child,
    );
  }
}

class QsAudioStateWidget extends QsAudioServiceWidgetWrapper<AudioPlayerState> {
  const QsAudioStateWidget({
    Key? key,
    required ValueWidgetBuilder<AudioPlayerState> builder,
    AudioPlayerService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<AudioPlayerState> getListenable(AudioPlayerService service) =>
      service.currentState;
}

class QsAudioTrackWidget extends QsAudioServiceWidgetWrapper<AudioTrack?> {
  const QsAudioTrackWidget({
    Key? key,
    required ValueWidgetBuilder<AudioTrack?> builder,
    AudioPlayerService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<AudioTrack?> getListenable(AudioPlayerService service) =>
      service.currentTrack;
}

class QsAudioQueueWidget
    extends QsAudioServiceWidgetWrapper<List<AudioTrack>?> {
  const QsAudioQueueWidget({
    Key? key,
    required ValueWidgetBuilder<List<AudioTrack>?> builder,
    AudioPlayerService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<List<AudioTrack>?> getListenable(
          AudioPlayerService service) =>
      service.currentQueue;
}

class QsAudioPositionWidget
    extends QsAudioServiceWidgetWrapper<AudioPlayerPosition?> {
  const QsAudioPositionWidget({
    Key? key,
    required ValueWidgetBuilder<AudioPlayerPosition?> builder,
    AudioPlayerService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<AudioPlayerPosition?> getListenable(
          AudioPlayerService service) =>
      service.currentPosition;
}
