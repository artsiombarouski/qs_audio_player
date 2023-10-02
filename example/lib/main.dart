import 'package:flutter/material.dart';
import 'package:qs_audio_player/qs_audio.dart';
import 'package:qs_audio_player_example/data.dart';

Future<void> main() async {
  await QsAudio.init(
    channelId: 'qs_audio_service_example',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QS Audio Player example'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  QsAudio.instance.setSource(testQueue1);
                },
                child: Text("Set queue"),
              ),
              TextButton(
                onPressed: () {
                  QsAudio.instance.setSource(testQueue2);
                },
                child: Text("Set queue 2"),
              ),
              QsAudioStateWidget(
                builder:
                    (BuildContext context, QsAudioState value, Widget? child) {
                  return Text("state: $value");
                },
              ),
              QsAudioStateWidget(
                builder: (context, state, child) {
                  bool isPlaying = state == QsAudioState.playing ||
                      state == QsAudioState.paused;
                  return IgnorePointer(
                    ignoring: !isPlaying,
                    child: Opacity(
                      opacity: isPlaying ? 1.0 : 0.3,
                      child: TextButton.icon(
                        onPressed: () {
                          QsAudio.instance.toggle();
                        },
                        icon: Icon(state == QsAudioState.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        label: Text("$state"),
                      ),
                    ),
                  );
                },
              ),
              QsAudioTrackWidget(
                builder: (context, value, child) {
                  return Text(value?.title ?? '---');
                },
              ),
              QsAudioPositionWidget(
                builder: (BuildContext context, QsAudioPosition? value,
                    Widget? child) {
                  if (value == null || value.isReady == false) {
                    return Container();
                  }
                  return QsSeekBar(
                    duration: value.duration!,
                    position: value.position,
                    bufferedPosition: value.bufferedPosition,
                    onChangeEnd: QsAudio.instance.seekTo,
                  );
                },
              ),
              QsAudioQueueWidget(
                builder: (context, value, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (value != null)
                        ...value.map(
                          (e) => InkWell(
                            onTap: () {
                              QsAudio.instance.changeByTrack(e);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Row(
                                children: [
                                  Text("${e.title}"),
                                  Expanded(child: Text("${e.album}")),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
