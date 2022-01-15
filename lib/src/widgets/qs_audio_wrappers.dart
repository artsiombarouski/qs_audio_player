import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qs_audio_player/qs_audio.dart';

abstract class QsAudioServiceWidgetWrapper<T> extends StatefulWidget {
  final ValueWidgetBuilder<T> builder;
  final QsAudioService? service;
  final Widget? child;

  const QsAudioServiceWidgetWrapper({
    Key? key,
    required this.builder,
    this.service,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => QsAudioServiceWidgetWrapperState<T>();

  QsAudioService get resolvedService => service ?? QsAudio.instance;

  ValueListenable<T> get listenable => getListenable(resolvedService);

  ValueListenable<T> getListenable(QsAudioService service);
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

class QsAudioStateWidget extends QsAudioServiceWidgetWrapper<QsAudioState> {
  const QsAudioStateWidget({
    Key? key,
    required ValueWidgetBuilder<QsAudioState> builder,
    QsAudioService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<QsAudioState> getListenable(QsAudioService service) =>
      service.currentState;
}

class QsAudioTrackWidget extends QsAudioServiceWidgetWrapper<QsAudioTrack?> {
  const QsAudioTrackWidget({
    Key? key,
    required ValueWidgetBuilder<QsAudioTrack?> builder,
    QsAudioService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<QsAudioTrack?> getListenable(QsAudioService service) =>
      service.currentTrack;
}

class QsAudioQueueWidget
    extends QsAudioServiceWidgetWrapper<List<QsAudioTrack>?> {
  const QsAudioQueueWidget({
    Key? key,
    required ValueWidgetBuilder<List<QsAudioTrack>?> builder,
    QsAudioService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<List<QsAudioTrack>?> getListenable(QsAudioService service) =>
      service.currentQueue;
}

class QsAudioPositionWidget
    extends QsAudioServiceWidgetWrapper<QsAudioPosition?> {
  const QsAudioPositionWidget({
    Key? key,
    required ValueWidgetBuilder<QsAudioPosition?> builder,
    QsAudioService? service,
    Widget? child,
  }) : super(key: key, builder: builder, service: service, child: child);

  @override
  ValueListenable<QsAudioPosition?> getListenable(QsAudioService service) =>
      service.currentPosition;
}
