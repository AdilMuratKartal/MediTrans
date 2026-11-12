import 'package:flutter/material.dart';
import '../audio/global_audio_controller.dart';
import '../config/app_env.dart';
import '../data/cloud_sync_service.dart';
import '../data/local_store.dart';
import '../data/media_storage_gateway.dart';
import '../platform/notification_gateway.dart';

/// Top-level Dependency Injection scope providing reactive services across all screens.
class AppScope extends InheritedWidget {
  final AppEnvConfig env;
  final LocalStore localStore;
  final MediaStorageGateway mediaGateway;
  final CloudSyncService cloudSync;
  final NotificationGateway notifications;
  final GlobalAudioController audio;
  final ValueChanged<int> onSwitchTab;

  const AppScope({
    super.key,
    required this.env,
    required this.localStore,
    required this.mediaGateway,
    required this.cloudSync,
    required this.notifications,
    required this.audio,
    required this.onSwitchTab,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return localStore != oldWidget.localStore ||
        audio != oldWidget.audio ||
        cloudSync != oldWidget.cloudSync ||
        notifications != oldWidget.notifications;
  }
}
