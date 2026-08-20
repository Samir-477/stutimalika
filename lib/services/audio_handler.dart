import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Wraps a single persistent [AudioPlayer] and broadcasts its state to the
/// OS media notification (the "now playing" bar shown on the lock screen /
/// notification shade, same as Spotify) — so playback survives navigating
/// away from the Reader screen or backgrounding the app.
///
/// [ReaderScreen] talks to the underlying [player] directly for everything
/// (position/duration streams, speed, loop, seek) exactly as it did with its
/// own local player; the only difference is this instance is app-scoped and
/// never disposed while the app is alive, and [loadStotra] additionally
/// updates the notification's title/artist.
class StutiAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();

  StutiAudioHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<Duration?> loadStotra({
    required String assetPath,
    required String title,
    required String composer,
  }) async {
    mediaItem.add(MediaItem(
      id: assetPath,
      title: title,
      artist: composer,
    ));
    return player.setAsset(assetPath);
  }

  void clearMediaItem() => mediaItem.add(null);

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
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
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    );
  }
}
