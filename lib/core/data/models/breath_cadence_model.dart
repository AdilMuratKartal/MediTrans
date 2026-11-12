class BreathCadence {
  final String id;
  final String titleTr;
  final String subtitleTr;
  final int inhaleSec;
  final int holdSec;
  final int exhaleSec;
  final List<int> durationMinutesOptions;
  final String localAudioAsset;
  final String remoteStoragePath;
  final String backgroundAsset;

  const BreathCadence({
    required this.id,
    required this.titleTr,
    required this.subtitleTr,
    required this.inhaleSec,
    required this.holdSec,
    required this.exhaleSec,
    this.durationMinutesOptions = const [5, 10, 15],
    required this.localAudioAsset,
    required this.remoteStoragePath,
    required this.backgroundAsset,
  });

  int get cycleSeconds => inhaleSec + holdSec + exhaleSec;
}

