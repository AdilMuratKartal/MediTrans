import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/universal_player_bar.dart';
import '../../core/data/models.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Sleep Stories Reader & Sticky Compact Audio Player (`uyku_hikayeleri_sabit_kompakt_oynat_c`)
/// Loads the full Turkish narrative from `assets/stories/hikaye_1.txt` and `hikaye_2.txt`,
/// places the story title above the player controls, and syncs audio (`hikaye_1.mp3`, `hikaye_2.mp3`).
class SleepStoriesScreen extends StatefulWidget {
  final int initialStoryIndex;

  const SleepStoriesScreen({super.key, this.initialStoryIndex = 0});

  @override
  State<SleepStoriesScreen> createState() => _SleepStoriesScreenState();
}

class _SleepStoriesScreenState extends State<SleepStoriesScreen> {
  late int _selectedIndex;
  String _storyBodyText = 'Hikaye metni yükleniyor...';
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialStoryIndex.clamp(
      0,
      SeedCatalog.storyTracks.length - 1,
    );
    _loadStoryText(_selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _activateStory(_selectedIndex);
    });
  }

  SleepMediaTrack get _current => SeedCatalog.storyTracks[_selectedIndex];

  Future<void> _loadStoryText(int index) async {
    final assetPath = SeedCatalog.storyTracks[index].storyTextAsset;
    if (assetPath == null) return;
    try {
      final loaded = await rootBundle.loadString(assetPath);
      if (mounted) {
        setState(() => _storyBodyText = loaded.trim());
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _storyBodyText =
              'Ay ışığının gümüşi parıltısı sessiz ormanın yaprakları arasından süzülürken, derin ve dingin bir nefes alarak gecenin huzuruna bırakın kendinizi...',
        );
      }
    }
  }

  void _activateStory(int index) {
    final scope = AppScope.of(context);
    setState(() => _selectedIndex = index);
    _loadStoryText(index);
    final item = SeedCatalog.storyTracks[index];
    scope.audio.playTrack(
      SeedCatalog.fromSleepTrack(item),
      playlist: SeedCatalog.storyTracks
          .map(SeedCatalog.fromSleepTrack)
          .toList(),
      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final story = _current;

    return Scaffold(
      backgroundColor: AuraColors.nightBg,
      body: AuraBackground(
        imageAsset: story.backgroundAsset,
        isNightMode: true,
        overlayOpacity: 0.78,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with Font Size controls
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AuraColors.nightText,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Uyku Hikayeleri',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightText,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Yazı Boyutunu Küçült',
                      onPressed: () => setState(
                        () => _fontSize = (_fontSize - 2).clamp(14.0, 26.0),
                      ),
                      icon: const Icon(
                        Icons.text_decrease_rounded,
                        color: AuraColors.nightMuted,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Yazı Boyutunu Büyüt',
                      onPressed: () => setState(
                        () => _fontSize = (_fontSize + 2).clamp(14.0, 26.0),
                      ),
                      icon: const Icon(
                        Icons.text_increase_rounded,
                        color: AuraColors.nightAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Story Switcher Chips (Hikaye 1 / Hikaye 2)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    for (
                      var i = 0;
                      i < SeedCatalog.storyTracks.length;
                      i++
                    ) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            'Hikaye ${i + 1}: ${SeedCatalog.storyTracks[i].titleTr}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: _selectedIndex == i,
                          selectedColor: AuraColors.nightAccent.withValues(
                            alpha: 0.25,
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: _selectedIndex == i
                                ? AuraColors.nightAccent
                                : Colors.transparent,
                          ),
                          labelStyle: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == i
                                ? AuraColors.nightText
                                : AuraColors.nightMuted,
                          ),
                          onSelected: (_) => _activateStory(i),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Scrollable Narrative Reader
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                  child: AuraGlassCard(
                    isNightMode: true,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            story.backgroundAsset,
                            height: 155,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'SESLİ UYKU MASALI & TAM METİN',
                          style: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: AuraColors.nightAccent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story.titleTr,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AuraColors.nightText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _storyBodyText,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: _fontSize,
                            height: 1.75,
                            color: AuraColors.nightText.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Bottom Compact Player with Story Title positioned above controls
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 6),
                      child: Text(
                        'Şu An Okunan & Çalan: ${story.titleTr}',
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightAccent,
                        ),
                      ),
                    ),
                    UniversalPlayerBar(
                      audio: scope.audio,
                      localStore: scope.localStore,
                      isNightMode: true,
                      showHeaderInfo: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
