enum MoodValence {
  mutlu('mutlu', '😊', 'Mutlu', 5),
  sakin('sakin', '😌', 'Sakin', 4),
  notr('notr', '😐', 'Nötr', 3),
  endisel('endisel', '😟', 'Endişeli', 2),
  uzgun('uzgun', '😔', 'Üzgün', 2),
  yorgun('yorgun', '😴', 'Yorgun', 2),
  stresli('stresli', '😣', 'Stresli', 1);

  final String code;
  final String emoji;
  final String labelTr;
  final int score;
  const MoodValence(this.code, this.emoji, this.labelTr, this.score);

  static MoodValence fromCode(String code) {
    return MoodValence.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MoodValence.sakin,
    );
  }
}

