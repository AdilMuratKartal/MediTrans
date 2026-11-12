import 'package:flutter/material.dart';
import '../../core/data/models.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';
import 'frequency_player_screen.dart';

/// Hz Frequencies & Angel Numbers Catalog (`hz_frekanslar_ve_meditasyon_tonlar`)
/// Displays Solfeggio frequencies (`7.83`, `44`, `174..963 Hz`) and Angel Sequences (`111..999`)
/// with their own background visual preview (`FrequencyStyleBackdrop`) and instant playback.
class FrequenciesScreen extends StatefulWidget {
  const FrequenciesScreen({super.key});

  @override
  State<FrequenciesScreen> createState() => _FrequenciesScreenState();
}

class _FrequenciesScreenState extends State<FrequenciesScreen> {
  String _selectedTab =
      'Tümü'; // 'Tümü', 'Solfeggio Hz', 'Melek Sayıları', 'Favoriler'

  List<FrequencyTrack> _filteredList(Set<String> favs) {
    final all = SeedCatalog.frequencies;
    if (_selectedTab == 'Solfeggio Hz') {
      return all.where((f) => !f.isAngelSequence).toList();
    }
    if (_selectedTab == 'Melek Sayıları') {
      return all.where((f) => f.isAngelSequence).toList();
    }
    if (_selectedTab == 'Favoriler') {
      return all.where((f) => favs.contains(f.id)).toList();
    }
    return all;
  }

  void _openPlayer(FrequencyTrack track, {bool fullScreen = false}) {
    final idx = SeedCatalog.frequencies.indexWhere((f) => f.id == track.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FrequencyPlayerScreen(
          initialIndex: idx < 0 ? 0 : idx,
          startFullScreenResonance: fullScreen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    const tabs = ['Tümü', 'Solfeggio Hz', 'Melek Sayıları', 'Favoriler'];

    return ListenableBuilder(
      listenable: Listenable.merge([scope.audio, scope.localStore]),
      builder: (context, _) {
        final items = _filteredList(scope.localStore.favoriteIds);
        return Scaffold(
          body: AuraBackground(
            imageAsset: 'assets/images/backgrounds/meditation_portal_bg.jpg',
            overlayOpacity: 0.82,
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        const Expanded(
                          child: Text(
                            'Hz Frekansları & Tonlar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tam Ekran Rezonans Oynatıcıyı Aç',
                          onPressed: () {
                            final activeIdx = SeedCatalog.frequencies
                                .indexWhere(
                                  (f) => f.id == scope.audio.currentTrack.id,
                                );
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FrequencyPlayerScreen(
                                  initialIndex: activeIdx < 0 ? 5 : activeIdx,
                                  startFullScreenResonance: true,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.waves_rounded,
                            color: AuraColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        for (final tab in tabs)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(tab),
                              selected: _selectedTab == tab,
                              selectedColor: AuraColors.primary,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.76,
                              ),
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == tab
                                    ? Colors.white
                                    : AuraColors.onSurface,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedTab = tab),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isPlayingThis =
                            scope.audio.currentTrack.id == item.id &&
                            scope.audio.isPlaying;
                        final isFav = scope.localStore.isFavorite(item.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: AuraGlassCard(
                            padding: const EdgeInsets.all(14),
                            onTap: () => _openPlayer(item),
                            child: Row(
                              children: [
                                // Frequency visual slice preview
                                SizedBox(
                                  width: 78,
                                  height: 78,
                                  child: FrequencyStyleBackdrop(
                                    styleIndex: item.styleIndex,
                                    borderRadius: 20,
                                    animateMotion: false,
                                    child: Center(
                                      child: Text(
                                        item.codeLabel,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.codeLabel} • ${item.titleTr}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AuraColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.chakraOrThemeTr,
                                        style: const TextStyle(
                                          fontFamily: 'Segoe UI',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AuraColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.descriptionTr,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Segoe UI',
                                          fontSize: 12,
                                          color: AuraColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      tooltip: 'Favori',
                                      onPressed: () => scope.localStore
                                          .toggleFavorite(item.id),
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        size: 20,
                                        color: isFav
                                            ? const Color(0xFFD86C8C)
                                            : AuraColors.outline,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: isPlayingThis
                                          ? 'Duraklat'
                                          : 'Hemen Çal',
                                      onPressed: () {
                                        if (isPlayingThis) {
                                          scope.audio.pause();
                                        } else {
                                          scope.audio.playTrack(
                                            SeedCatalog.fromFrequency(item),
                                            playlist: SeedCatalog.frequencies
                                                .map(SeedCatalog.fromFrequency)
                                                .toList(),
                                            autoPlay: true,
                                          );
                                        }
                                      },
                                      icon: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isPlayingThis
                                              ? AuraColors.primary
                                              : AuraColors.primaryFixed,
                                        ),
                                        child: Icon(
                                          isPlayingThis
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 20,
                                          color: isPlayingThis
                                              ? Colors.white
                                              : AuraColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
