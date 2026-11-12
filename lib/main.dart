import 'package:flutter/material.dart';
import 'core/audio/global_audio_controller.dart';
import 'core/config/app_env.dart';
import 'core/data/cloud_sync_service.dart';
import 'core/data/local_store.dart';
import 'core/data/media_storage_gateway.dart';
import 'core/di/app_scope.dart';
import 'core/platform/notification_gateway.dart';
import 'core/theme/aura_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/aura_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnvConfig.fromEnvironment();
  final localStore = LocalStore();
  final mediaGateway = MediaStorageGateway(env: env);
  final cloudSync = CloudSyncService(localStore: localStore);
  final notifications = NotificationGateway();

  await localStore.initialize();
  await mediaGateway.initialize();
  await cloudSync.initialize();
  await notifications.initialize(
    enabled: localStore.profile.notificationsEnabled,
    reminderTime: localStore.profile.dailyReminderTime,
    webVapidKey: env.fcmWebVapidKey,
  );

  final audioController = GlobalAudioController(
    localStore: localStore,
    mediaGateway: mediaGateway,
  );

  runApp(
    MediTransApp(
      env: env,
      localStore: localStore,
      mediaGateway: mediaGateway,
      cloudSync: cloudSync,
      notifications: notifications,
      audio: audioController,
      requireAuthGate: true,
    ),
  );
}

class MediTransApp extends StatefulWidget {
  final AppEnvConfig? env;
  final LocalStore? localStore;
  final MediaStorageGateway? mediaGateway;
  final CloudSyncService? cloudSync;
  final NotificationGateway? notifications;
  final GlobalAudioController? audio;
  final bool requireAuthGate;

  const MediTransApp({
    super.key,
    this.env,
    this.localStore,
    this.mediaGateway,
    this.cloudSync,
    this.notifications,
    this.audio,
    this.requireAuthGate = false,
  });

  @override
  State<MediTransApp> createState() => _MediTransAppState();
}

class _MediTransAppState extends State<MediTransApp> {
  late final AppEnvConfig _env;
  late final LocalStore _localStore;
  late final MediaStorageGateway _mediaGateway;
  late final CloudSyncService _cloudSync;
  late final NotificationGateway _notifications;
  late final GlobalAudioController _audio;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? AppEnvConfig.fromEnvironment();
    _localStore = widget.localStore ?? LocalStore();
    _mediaGateway = widget.mediaGateway ?? MediaStorageGateway(env: _env);
    _cloudSync = widget.cloudSync ?? CloudSyncService(localStore: _localStore);
    _notifications = widget.notifications ?? NotificationGateway();
    _audio =
        widget.audio ??
        GlobalAudioController(
          localStore: _localStore,
          mediaGateway: _mediaGateway,
        );

    if (widget.localStore == null) {
      _localStore.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      env: _env,
      localStore: _localStore,
      mediaGateway: _mediaGateway,
      cloudSync: _cloudSync,
      notifications: _notifications,
      audio: _audio,
      onSwitchTab: (_) {},
      child: MaterialApp(
        title: 'MediTrans — Aura Mind',
        debugShowCheckedModeBanner: false,
        theme: AuraTheme.lightTheme(),
        home: ListenableBuilder(
          listenable: _cloudSync,
          builder: (context, _) {
            if (widget.requireAuthGate && !_cloudSync.hasEnteredApp) {
              return const LoginScreen();
            }
            return const AuraShell();
          },
        ),
      ),
    );
  }
}
