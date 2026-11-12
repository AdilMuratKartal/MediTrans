import 'session_category_model.dart';

class SleepMediaTrack {
  final String id;
  final SessionCategory category;
  final String titleTr;
  final String subtitleTr;
  final String backgroundAsset;
  final String localAudioAsset;
  final String remoteStoragePath;
  final String? storyTextAsset;
  final int durationSeconds;

  const SleepMediaTrack({
    required this.id,
    required this.category,
    required this.titleTr,
    required this.subtitleTr,
    required this.backgroundAsset,
    required this.localAudioAsset,
    required this.remoteStoragePath,
    this.storyTextAsset,
    required this.durationSeconds,
  });
}

