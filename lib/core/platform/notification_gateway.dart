import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationLogItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  const NotificationLogItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationLogItem copyWith({bool? isRead}) {
    return NotificationLogItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Cross-platform Notification Gateway (`flutter_local_notifications` + `firebase_messaging`)
/// working on macOS, Windows, Chrome, and web-server.
class NotificationGateway extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _dailyReminderEnabled = true;
  String _reminderTime = '21:30';
  String? _fcmTokenStatus;

  final List<NotificationLogItem> _notifications = [
    NotificationLogItem(
      id: 'notif_welcome',
      title: 'Ethereal Aura Mind Tapınağına Hoş Geldin ✨',
      body:
          'Bugünkü duygu durumunu kaydet ve 432 Hz Evrensel Uyum ile frekansını dengele.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    NotificationLogItem(
      id: 'notif_evening',
      title: 'Akşam Gevşeme Ritüeli (21:30)',
      body:
          'Uyku öncesi 4-7-8 Nefes Egzersizi veya Ay Işığında Gizli Orman hikayesi seni bekliyor.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  bool get dailyReminderEnabled => _dailyReminderEnabled;
  String get reminderTime => _reminderTime;
  String get fcmTokenStatus =>
      _fcmTokenStatus ??
      (kIsWeb ? 'Web Bildirim Kanalı Aktif' : 'Yerel Zamanlayıcı Aktif');
  List<NotificationLogItem> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize({
    required bool enabled,
    required String reminderTime,
    String? webVapidKey,
  }) async {
    _dailyReminderEnabled = enabled;
    _reminderTime = reminderTime;
    try {
      tz.initializeTimeZones();
    } catch (_) {}

    if (!kIsWeb) {
      try {
        const androidSettings = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        const darwinSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        const linuxSettings = LinuxInitializationSettings(
          defaultActionName: 'Aç',
        );
        const initSettings = InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
          linux: linuxSettings,
        );
        await _localNotifications.initialize(initSettings);
        _initialized = true;
      } catch (_) {
        _initialized = false;
      }
    }

    // Attempt Firebase Messaging foreground listener if Firebase is initialized
    try {
      if (webVapidKey != null && webVapidKey.trim().isNotEmpty) {
        // Request permission and register Web Push VAPID key non-blockingly
        FirebaseMessaging.instance
            .requestPermission()
            .then(
              (_) => FirebaseMessaging.instance.getToken(
                vapidKey: webVapidKey.trim(),
              ),
            )
            .then((token) {
              if (token != null && token.isNotEmpty) {
                _fcmTokenStatus = 'FCM Web Push & Yerel Bildirim Aktif';
                notifyListeners();
              }
            })
            .catchError((_) {});
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notif = message.notification;
        if (notif != null) {
          addInAppNotification(
            title: notif.title ?? 'MediTrans Hatırlatıcı',
            body: notif.body ?? 'Farkındalık molası zamanı.',
          );
        }
      });
      _fcmTokenStatus = (webVapidKey != null && webVapidKey.trim().isNotEmpty)
          ? 'FCM VAPID & Yerel Bildirim Hazır'
          : 'FCM & Yerel Bildirim Hazır';
    } catch (_) {
      _fcmTokenStatus = kIsWeb
          ? 'Tarayıcı & Uygulama İçi Bildirim Aktif'
          : 'Yerel Bildirim Motoru Aktif';
    }
    notifyListeners();
  }

  Future<void> updateSchedule({
    required bool enabled,
    required String timeHm,
  }) async {
    _dailyReminderEnabled = enabled;
    _reminderTime = timeHm;

    if (!kIsWeb && _initialized) {
      try {
        await _localNotifications.cancel(1001);
        if (enabled) {
          final parts = timeHm.split(':');
          final hour = int.tryParse(parts.first) ?? 21;
          final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 30) : 30;
          final now = tz.TZDateTime.now(tz.local);
          var scheduled = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
          if (scheduled.isBefore(now)) {
            scheduled = scheduled.add(const Duration(days: 1));
          }
          await _localNotifications.zonedSchedule(
            1001,
            'MediTrans • Akşam Dinginliği',
            'Bugün nasıl hissettiğini kaydet ve uyku frekansına geç.',
            scheduled,
            const NotificationDetails(
              iOS: DarwinNotificationDetails(),
              macOS: DarwinNotificationDetails(),
              android: AndroidNotificationDetails(
                'meditrans_daily',
                'Günlük Farkındalık Hatırlatıcıları',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
      } catch (_) {}
    }

    addInAppNotification(
      title: enabled
          ? 'Günlük Hatırlatıcı Güncellendi ($timeHm)'
          : 'Günlük Hatırlatıcı Duraklatıldı',
      body: enabled
          ? 'Her gün saat $timeHm için duygu ve uyku hatırlatıcısı kuruldu.'
          : 'Bildirim zamanlayıcısı isteğiniz üzerine kapatıldı.',
    );
    notifyListeners();
  }

  Future<void> triggerInstantTestNotification() async {
    const title = 'Anlık Farkındalık Çağrısı 🧘';
    const body =
        'Omuzlarını gevşet, çeneni rahat bırak ve şimdi 4 saniye derin bir nefes al.';

    if (!kIsWeb && _initialized) {
      try {
        await _localNotifications.show(
          2002,
          title,
          body,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(),
            macOS: DarwinNotificationDetails(),
            android: AndroidNotificationDetails(
              'meditrans_instant',
              'Anlık Bildirimler',
            ),
          ),
        );
      } catch (_) {}
    }

    addInAppNotification(title: title, body: body);
  }

  void addInAppNotification({required String title, required String body}) {
    _notifications.insert(
      0,
      NotificationLogItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
}
