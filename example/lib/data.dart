import 'package:qs_audio_player/qs_audio_player.dart';

final testQueue1 = <AudioTrack>[
  AudioTrack(
    // This can be any unique id, but we use the audio URL for convenience.
    id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
    uri: "https://waves-cms.s3.amazonaws.com/chapter1_7a0d5b7397.mp3",
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    // duration: Duration(milliseconds: 5739820),
    duration: Duration.zero,
    artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg")
        .toString(),
  ),
  AudioTrack(
    id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
    uri: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
    album: "Science Friday",
    title: "From Cat Rheology To Operatic Incompetence",
    artist: "Science Friday and WNYC Studios",
    duration: Duration.zero,
    // duration: Duration(milliseconds: 2856950),
    artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg")
        .toString(),
  ),
];
