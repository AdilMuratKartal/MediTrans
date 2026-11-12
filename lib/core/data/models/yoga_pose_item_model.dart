class YogaPoseItem {
  final int orderIndex; // 1..8
  final String id;
  final String sanskritName;
  final String turkishName;
  final String subtitleTr;
  final String levelBadgeTr;
  final int recommendedSeconds;
  final List<int> durationPresetsSec;
  final String illustrationAsset;
  final List<String> stepInstructionsTr;
  final List<String> benefitBadgesTr;

  const YogaPoseItem({
    required this.orderIndex,
    required this.id,
    required this.sanskritName,
    required this.turkishName,
    required this.subtitleTr,
    required this.levelBadgeTr,
    this.recommendedSeconds = 60,
    this.durationPresetsSec = const [10, 20, 30, 60, 90],
    required this.illustrationAsset,
    required this.stepInstructionsTr,
    required this.benefitBadgesTr,
  });
}

