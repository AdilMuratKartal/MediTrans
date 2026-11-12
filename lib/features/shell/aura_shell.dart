import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';
import '../frequencies/frequency_player_screen.dart';
import '../home_mood/home_screen.dart';
import '../meditation/meditation_portal_screen.dart';
import '../profile/profile_screen.dart';

/// Main 3-Tab Sanctuary Shell (`Ana Sayfa`, `Meditasyon`, `Profil`)
/// with Notification Center modal & floating glassmorphic navigation bar.
class AuraShell extends StatefulWidget {
  final int initialTabIndex;

  const AuraShell({super.key, this.initialTabIndex = 0});

  @override
  State<AuraShell> createState() => _AuraShellState();
}

class _AuraShellState extends State<AuraShell> {
  late int _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTabIndex;
  }

  void switchTab(int index) {
    setState(() => _activeTab = index.clamp(0, 2));
  }

  void _openNotificationsSheet(BuildContext context, AppScope scope) {
    scope.notifications.markAllRead();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: scope.notifications,
          builder: (context, _) {
            final items = scope.notifications.notifications;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AuraColors.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bildirimler & Hatırlatıcılar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.onSurface,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AuraColors.primaryFixed,
                          foregroundColor: AuraColors.primary,
                        ),
                        onPressed: () => scope.notifications
                            .triggerInstantTestNotification(),
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          size: 16,
                        ),
                        label: const Text('Anlık Test'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Günlük 21:30 Farkındalık Hatırlatıcısı'),
                    subtitle: Text(scope.notifications.fcmTokenStatus),
                    value: scope.notifications.dailyReminderEnabled,
                    onChanged: (val) {
                      scope.notifications.updateSchedule(
                        enabled: val,
                        timeHm: scope.notifications.reminderTime,
                      );
                    },
                  ),
                  const Divider(),
                  for (final n in items.take(4))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AuraColors.primaryFixed,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AuraColors.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        n.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        n.body,
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentScope = AppScope.of(context);
    return AppScope(
      env: parentScope.env,
      localStore: parentScope.localStore,
      mediaGateway: parentScope.mediaGateway,
      cloudSync: parentScope.cloudSync,
      notifications: parentScope.notifications,
      audio: parentScope.audio,
      onSwitchTab: switchTab,
      child: Builder(
        builder: (innerContext) {
          final scope = AppScope.of(innerContext);
          return Scaffold(
            body: Stack(
              children: [
                IndexedStack(
                  index: _activeTab,
                  children: [
                    HomeMoodScreen(
                      onOpenNotifications: () =>
                          _openNotificationsSheet(innerContext, scope),
                    ),
                    MeditationPortalScreen(
                      onOpenNotifications: () =>
                          _openNotificationsSheet(innerContext, scope),
                    ),
                    const ProfileScreen(),
                  ],
                ),

                // Persistent Mini-Player on Meditation & Profile tabs when audio is active
                if (_activeTab != 0)
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 94,
                    child: ListenableBuilder(
                      listenable: scope.audio,
                      builder: (context, _) {
                        if (!scope.audio.isPlaying) {
                          return const SizedBox.shrink();
                        }
                        final track = scope.audio.currentTrack;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const FrequencyPlayerScreen(
                                  initialIndex: 5,
                                ),
                              ),
                            );
                          },
                          child: AuraGlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            borderRadius: 99,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.graphic_eq_rounded,
                                  color: AuraColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AuraColors.onSurface,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: scope.audio.togglePlayPause,
                                  icon: Icon(
                                    scope.audio.isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                    color: AuraColors.primary,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Floating Frosted Bottom Navigation Bar (`Ana Sayfa`, `Meditasyon`, `Profil`)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AuraColors.primary.withValues(alpha: 0.12),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NavTabItem(
                              icon: Icons.home_rounded,
                              label: 'Ana Sayfa',
                              selected: _activeTab == 0,
                              onTap: () => switchTab(0),
                            ),
                            _NavTabItem(
                              icon: Icons.self_improvement_rounded,
                              label: 'Meditasyon',
                              selected: _activeTab == 1,
                              onTap: () => switchTab(1),
                            ),
                            _NavTabItem(
                              icon: Icons.person_outline_rounded,
                              label: 'Profil',
                              selected: _activeTab == 2,
                              onTap: () => switchTab(2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AuraColors.primaryFixed : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? AuraColors.primary
                  : AuraColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AuraColors.primary
                    : AuraColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
