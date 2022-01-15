import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

const kAlbumId = "albumId";
const kAlbumType = "albumType";
const kSourceJsonKey = "sourceJson";
const kAlbumSourceJsonKey = "albumSourceJson";

class QsAudioTrack {
  final String uri;
  final String title;
  final Duration? duration;
  final String? key;
  final String? album;
  final String? artist;
  final String? artUri;
  final String? albumId;
  final String? albumType;
  final Map<String, dynamic>? extras;

  //???
  final String? sourceJson;
  final String? albumSourceJson;

  QsAudioTrack({
    required this.uri,
    required this.title,
    required this.album,
    required this.duration,
    this.key,
    this.artist,
    this.artUri,
    this.albumId,
    this.albumType,
    this.sourceJson,
    this.albumSourceJson,
    this.extras,
  });

  AudioSource toAudioSource() =>
      AudioSource.uri(Uri.parse(uri), tag: toMediaItem());

  MediaItem toMediaItem() => MediaItem(
        id: uri,
        title: title,
        album: album ?? '',
        duration: duration ?? Duration.zero,
        artist: artist,
        artUri: artUri != null ? Uri.parse(artUri!) : null,
        extras: {
          'key': key,
          'uri': uri,
          if (albumId != null) kAlbumId: albumId,
          if (albumType != null) kAlbumType: albumType,
          if (sourceJson != null) kSourceJsonKey: sourceJson,
          if (albumSourceJson != null) kAlbumSourceJsonKey: albumSourceJson,
          if (extras != null) ...extras!,
        },
      );

  static QsAudioTrack fromMediaItem(MediaItem item) => QsAudioTrack(
        uri: item.extras?['uri'],
        title: item.title,
        album: item.album,
        duration: item.duration,
        key: item.extras?['key'],
        artist: item.artist,
        artUri: item.artUri?.toString(),
        albumId: item.extras?[kAlbumId],
        albumType: item.extras?[kAlbumType],
        sourceJson: item.extras?[kSourceJsonKey],
        albumSourceJson: item.extras?[kAlbumSourceJsonKey],
        extras: item.extras,
      );
}
