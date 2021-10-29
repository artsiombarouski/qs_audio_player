import 'package:qs_audio_player/qs_audio_player.dart';

final testQueue1 = <AudioTrack>[
  AudioTrack(
    // This can be any unique id, but we use the audio URL for convenience.
    uri: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
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

final testQueue2 = <AudioTrack>[
  AudioTrack(
    uri:
        "https://firebasestorage.googleapis.com/v0/b/waves-stories-1.appspot.com/o/stories%2Fchickago-blus.mp3?alt=media&token=3aee8e0e-d9d2-41f9-be7f-b0eb73d233b2",
    title: "Test title",
    album: "Test album",
    duration: Duration.zero,
  ),
];
