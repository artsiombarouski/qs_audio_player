import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

const kAlbumId = "albumId";
const kAlbumType = "albumType";
const kSourceJsonKey = "sourceJson";
const kAlbumSourceJsonKey = "albumSourceJson";

class AudioTrack {
  final String id;
  final String uri;
  final String title;
  final Duration? duration;
  final String? album;
  final String? artist;
  final String? artUri;
  final String? albumId;
  final String? albumType;
  final Map<String, dynamic>? extras;

  //???
  final String? sourceJson;
  final String? albumSourceJson;

  AudioTrack({
    required this.id,
    required this.uri,
    required this.title,
    required this.album,
    required this.duration,
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
        id: id,
        title: title,
        album: album ?? '',
        duration: duration ?? Duration.zero,
        artist: artist,
        artUri: artUri != null ? Uri.parse(artUri!) : null,
        extras: {
          'uri': uri,
          if (albumId != null) kAlbumId: albumId,
          if (albumType != null) kAlbumType: albumType,
          if (sourceJson != null) kSourceJsonKey: sourceJson,
          if (albumSourceJson != null) kAlbumSourceJsonKey: albumSourceJson,
          if (extras != null) ...extras!,
        },
      );

  static AudioTrack fromMediaItem(MediaItem item) => AudioTrack(
        id: item.id,
        uri: item.extras?['uri'],
        title: item.title,
        album: item.album,
        duration: item.duration,
        artist: item.artist,
        artUri: item.artUri?.toString(),
        albumId: item.extras?[kAlbumId],
        albumType: item.extras?[kAlbumType],
        sourceJson: item.extras?[kSourceJsonKey],
        albumSourceJson: item.extras?[kAlbumSourceJsonKey],
        extras: item.extras,
      );
}
