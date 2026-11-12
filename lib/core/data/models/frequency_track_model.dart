class FrequencyTrack {
  final String id;
  final String codeLabel; // '432 Hz', '7.83 Hz', '528 Hz', '999'
  final double frequencyValue;
  final bool isAngelSequence;
  final String titleTr;
  final String chakraOrThemeTr;
  final String descriptionTr;
  final String backgroundAsset;
  final int styleIndex; // 0..8 for visual slice & color theme
  final String localAudioAsset;
  final String remoteAudioStoragePath;
  final int defaultDurationSeconds;

  const FrequencyTrack({
    required this.id,
    required this.codeLabel,
    required this.frequencyValue,
    this.isAngelSequence = false,
    required this.titleTr,
    required this.chakraOrThemeTr,
    required this.descriptionTr,
    required this.backgroundAsset,
    required this.styleIndex,
    required this.localAudioAsset,
    required this.remoteAudioStoragePath,
    this.defaultDurationSeconds = 900,
  });
}

