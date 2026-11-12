import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'local_store.dart';

/// Manages Firebase Spark Free-Tier Authentication (`firebase_auth`) and
/// Cloud Firestore (`cloud_firestore`) Relational Multi-Collection Outbox Synchronization.
///
/// Top-Level Relational Collections (all linked via `userId` -> `users/{userId}`):
/// - `users` (`users/{userId}`)
/// - `weekly_habits` (`weekly_habits/{userId}`)
/// - `last_played_tracks` (`last_played_tracks/{userId}`)
/// - `mood_charts` (`mood_charts/{userId}`)
/// - `mood_logs` (`mood_logs/{userId}_{dateKey}`)
/// - `session_history` (`session_history/{userId}_{sessionId}`)
/// - `user_favorites` (`user_favorites/{userId}_{itemId}`)
class CloudSyncService extends ChangeNotifier {
  static const String colUsers = 'users';
  static const String colWeeklyHabits = 'weekly_habits';
  static const String colLastPlayedTracks = 'last_played_tracks';
  static const String colMoodCharts = 'mood_charts';
  static const String colMoodLogs = 'mood_logs';
  static const String colSessionHistory = 'session_history';
  static const String colUserFavorites = 'user_favorites';

  final LocalStore localStore;

  bool _firebaseReady = false;
  bool _isSignedIn = false;
  bool _hasEnteredApp = false;
  bool _isSyncing = false;
  String _authLabel = 'Yerel Çevrimdışı Mod';
  String? _userEmail;
  DateTime? _lastSyncedAt;

  CloudSyncService({required this.localStore}) {
    localStore.onSyncRequested = () {
      flushOutboxToFirestore();
    };
  }

  bool get isFirebaseReady => _firebaseReady;
  bool get isSignedIn => _isSignedIn;
  bool get hasEnteredApp => _isSignedIn || _hasEnteredApp;
  bool get isSyncing => _isSyncing;
  String get authLabel => _authLabel;
  String? get userEmail => _userEmail;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  String _resolveTargetUid() {
    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) {
        return authUid;
      }
    } catch (_) {}
    final profileUid = localStore.profile.uid;
    if (profileUid.isNotEmpty && profileUid != 'local_user') {
      return profileUid;
    }
    final rawEmail = _userEmail ?? localStore.profile.email;
    if (rawEmail != null && rawEmail.trim().isNotEmpty) {
      return 'user_${rawEmail.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}';
    }
    return 'default_meditrans_user';
  }

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseReady = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _isSignedIn = true;
        _hasEnteredApp = true;
        _userEmail = user.email ?? 'anonim@meditrans.app';
        _authLabel = user.isAnonymous
            ? 'Firebase Anonim Oturum Aktif'
            : 'Firebase Bulut Hesabı (${_userEmail!})';
      } else {
        _authLabel = 'Firebase Hazır • Giriş Bekleniyor';
      }
      debugPrint(
        '[Firebase Auth] Başarıyla bağlandı (${DefaultFirebaseOptions.currentPlatform.projectId}). Aktif kullanıcı: ${user?.email ?? "yok"}',
      );

      // Açılışta: Yerelde veri varsa yerelden devam et; eksikse gerçekten Firestore'dan çekmeyi dene.
      // Çekemezse uygulama çökmesin, yerel verilerle devam etsin.
      await pullFromFirestoreIfNeeded(preferRemote: false);
    } catch (e, st) {
      debugPrint('[Firebase Auth] Firebase başlatma hatası: $e\n$st');
      _firebaseReady = false;
      _authLabel = 'Yerel Depolama Modu (Çevrimdışı)';
    }
    notifyListeners();
  }

  /// Açılışta veya oturum açıldığında yerel verileri kontrol eder.
  /// Yerelde son dinlenen parça veya duygu grafiği verisi yoksa (veya `preferRemote` true ise)
  /// gerçekten Cloud Firestore'daki ayrı ilişkisel koleksiyonlardan (`users`, `weekly_habits`,
  /// `last_played_tracks`, `mood_charts`, `mood_logs`, `user_favorites`) `userId` ile çekmeye çalışır.
  /// Hata alırsa (internet yoksa, yetki kapalıysa vb.) kesinlikle çökmez, yerel verilerle devam eder.
  Future<void> pullFromFirestoreIfNeeded({bool preferRemote = false}) async {
    if (!_firebaseReady) return;

    final hasLocalTrack = localStore.hasLocalLastPlayedData;
    final hasLocalMoods = localStore.hasLocalMoodData;

    if (hasLocalTrack && hasLocalMoods && !preferRemote) {
      debugPrint(
        '[Firestore Sync] Yerel veriler mevcut (Son dinlenen: "${localStore.lastPlayedTrack.title}" [${localStore.lastPlayedTrack.categoryLabelTr}], Duygu grafiği yüklü). Yerel verilerle devam ediliyor.',
      );
      if (localStore.outbox.isNotEmpty) {
        await flushOutboxToFirestore();
      }
      return;
    }

    final targetUid = _resolveTargetUid();
    debugPrint(
      '[Firestore Sync] İlişkisel koleksiyonlardan veri çekilmeye çalışılıyor (userId=$targetUid -> users, weekly_habits, last_played_tracks, mood_charts, mood_logs)...',
    );

    try {
      final db = FirebaseFirestore.instance;

      // 1. `users/{userId}`
      final userSnap = await db
          .collection(colUsers)
          .doc(targetUid)
          .get()
          .timeout(const Duration(seconds: 5));
      final userDocData = userSnap.exists && userSnap.data() != null
          ? Map<String, dynamic>.from(userSnap.data()!)
          : null;

      // 2. `weekly_habits/{userId}`
      final habitsSnap = await db
          .collection(colWeeklyHabits)
          .doc(targetUid)
          .get()
          .timeout(const Duration(seconds: 5));
      final weeklyHabitsDocData = habitsSnap.exists && habitsSnap.data() != null
          ? Map<String, dynamic>.from(habitsSnap.data()!)
          : null;

      // 3. `last_played_tracks/{userId}`
      final lastPlayedSnap = await db
          .collection(colLastPlayedTracks)
          .doc(targetUid)
          .get()
          .timeout(const Duration(seconds: 5));
      final lastPlayedDocData =
          lastPlayedSnap.exists && lastPlayedSnap.data() != null
          ? Map<String, dynamic>.from(lastPlayedSnap.data()!)
          : null;

      // 4. `mood_charts/{userId}`
      final moodChartSnap = await db
          .collection(colMoodCharts)
          .doc(targetUid)
          .get()
          .timeout(const Duration(seconds: 5));
      final moodChartDocData =
          moodChartSnap.exists && moodChartSnap.data() != null
          ? Map<String, dynamic>.from(moodChartSnap.data()!)
          : null;

      // 5. `mood_logs` where `userId == targetUid`
      final moodLogsSnap = await db
          .collection(colMoodLogs)
          .where('userId', isEqualTo: targetUid)
          .get()
          .timeout(const Duration(seconds: 5));
      final moodLogDocs = moodLogsSnap.docs
          .map((d) => Map<String, dynamic>.from(d.data()))
          .toList();

      // 6. `user_favorites` where `userId == targetUid`
      final favsSnap = await db
          .collection(colUserFavorites)
          .where('userId', isEqualTo: targetUid)
          .get()
          .timeout(const Duration(seconds: 5));
      final favoriteDocs = favsSnap.docs
          .map((d) => Map<String, dynamic>.from(d.data()))
          .toList();

      final hasAnyRemote =
          userDocData != null ||
          weeklyHabitsDocData != null ||
          lastPlayedDocData != null ||
          moodChartDocData != null ||
          moodLogDocs.isNotEmpty ||
          favoriteDocs.isNotEmpty;

      if (hasAnyRemote) {
        await localStore.hydrateFromFirestore(
          userDocData: userDocData,
          weeklyHabitsDocData: weeklyHabitsDocData,
          lastPlayedDocData: lastPlayedDocData,
          moodChartDocData: moodChartDocData,
          moodLogDocs: moodLogDocs,
          favoriteDocs: favoriteDocs,
          preferRemote: preferRemote,
        );
        _lastSyncedAt = DateTime.now();
        debugPrint(
          '[Firestore Sync] İlişkisel koleksiyon verileri (userId=$targetUid) başarıyla yerel depoya aktarıldı '
          '(lastPlayed: ${lastPlayedDocData != null}, moodChart: ${moodChartDocData != null}, moodLogs: ${moodLogDocs.length}, habits: ${weeklyHabitsDocData != null}).',
        );
      } else {
        debugPrint(
          '[Firestore Sync] Firestore koleksiyonlarında userId=$targetUid için kayıt bulunamadı, mevcut yerel veriler koleksiyonlara kaydediliyor...',
        );
        await flushOutboxToFirestore(forceFullSnapshot: true);
      }
    } catch (e) {
      debugPrint(
        '[Firestore Sync] Firestore koleksiyonlarından veri çekilemedi ($e). Uygulama yerel verilerle kesintisiz devam ediyor.',
      );
    }
  }

  Future<String> signInWithEmailOrAnonymous({
    String? email,
    String? password,
  }) async {
    _isSyncing = true;
    notifyListeners();

    // 1. Firebase başlatılmamışsa tekrar dene
    if (!_firebaseReady || Firebase.apps.isEmpty) {
      debugPrint('[Firebase Auth] Firebase henüz hazır değil, tekrar başlatılıyor...');
      await initialize();
    }

    // 2. Firebase hazırsa gerçek sorgu at
    if (_firebaseReady) {
      try {
        if (email != null &&
            email.trim().isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          final cleanEmail = email.trim();
          debugPrint('[Firebase Auth] Firebase sunucusuna sorgu gönderiliyor: $cleanEmail');

          UserCredential? cred;
          try {
            cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: cleanEmail,
              password: password,
            );
            debugPrint('[Firebase Auth] Giriş başarılı! UID: ${cred.user?.uid}');
          } on FirebaseAuthException catch (authErr) {
            debugPrint(
              '[Firebase Auth] signIn sorgu yanıtı: ${authErr.code} - ${authErr.message}',
            );

            if (authErr.code == 'wrong-password') {
              _isSyncing = false;
              notifyListeners();
              return 'Firebase: Şifre hatalı! Lütfen şifrenizi kontrol edin.';
            } else if (authErr.code == 'invalid-email') {
              _isSyncing = false;
              notifyListeners();
              return 'Firebase: Geçersiz e-posta adresi formatı.';
            } else if (authErr.code == 'operation-not-allowed') {
              _isSyncing = false;
              notifyListeners();
              return 'Firebase Hatası: Firebase Console > Authentication bölümünde Email/Password sağlayıcısı aktif değil!';
            } else if (authErr.code == 'keychain-error') {
              _isSyncing = false;
              notifyListeners();
              return 'macOS Anahtar Zinciri (Keychain) erişimi güncellendi. Lütfen uygulamayı durdurup tekrar çalıştırın.';
            } else if (authErr.code == 'user-not-found') {
              debugPrint('[Firebase Auth] Kullanıcı bulunamadı, otomatik kayıt oluşturuluyor...');
              cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: cleanEmail,
                password: password,
              );
              debugPrint('[Firebase Auth] Kayıt ve giriş başarılı! UID: ${cred.user?.uid}');
            } else if (authErr.code == 'invalid-credential') {
              // Firebase Auth v10+, hem şifre hatası hem de olmayan hesap için invalid-credential dönebilir
              try {
                debugPrint('[Firebase Auth] invalid-credential alındı, hesap yok mu diye kontrol ediliyor...');
                cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: cleanEmail,
                  password: password,
                );
                debugPrint('[Firebase Auth] Yeni hesap açılarak oturum başlatıldı! UID: ${cred.user?.uid}');
              } on FirebaseAuthException catch (createErr) {
                debugPrint('[Firebase Auth] createUser yanıtı: ${createErr.code}');
                if (createErr.code == 'email-already-in-use') {
                  _isSyncing = false;
                  notifyListeners();
                  return 'Firebase: Bu e-posta ($cleanEmail) Firebase\'de kayıtlı ancak girdiğiniz şifre hatalı!';
                } else if (createErr.code == 'weak-password') {
                  _isSyncing = false;
                  notifyListeners();
                  return 'Firebase: Şifre en az 6 karakter olmalıdır.';
                } else {
                  _isSyncing = false;
                  notifyListeners();
                  return 'Firebase: Girdiğiniz kimlik bilgisi doğrulanamadı (${createErr.message ?? createErr.code}).';
                }
              }
            } else {
              _isSyncing = false;
              notifyListeners();
              return 'Firebase Doğrulama Hatası (${authErr.code}): ${authErr.message}';
            }
          }

          if (cred.user != null) {
            final authUid = cred.user!.uid;
            _isSignedIn = true;
            _hasEnteredApp = true;
            _userEmail = cred.user?.email ?? cleanEmail;
            _authLabel = 'Firebase Bulut Hesabı ($_userEmail)';
            _lastSyncedAt = DateTime.now();

            await localStore.updateProfile(
              localStore.profile.copyWith(uid: authUid, email: _userEmail),
            );
            await pullFromFirestoreIfNeeded(preferRemote: false);
            await flushOutboxToFirestore(forceFullSnapshot: true);

            _isSyncing = false;
            notifyListeners();
            return 'Firebase sunucusuna bağlanıldı ve başarıyla giriş yapıldı! ($_userEmail)';
          }
        } else {
          // Anonim giriş
          debugPrint('[Firebase Auth] Anonim giriş sorgusu gönderiliyor...');
          final cred = await FirebaseAuth.instance.signInAnonymously();
          final authUid = cred.user?.uid ?? _resolveTargetUid();
          _isSignedIn = cred.user != null;
          _hasEnteredApp = true;
          _userEmail = 'anonim@meditrans.app';
          _authLabel = 'Firebase Anonim Bulut Hesabı';
          _lastSyncedAt = DateTime.now();

          await localStore.updateProfile(
            localStore.profile.copyWith(uid: authUid, email: _userEmail),
          );
          await pullFromFirestoreIfNeeded(preferRemote: false);
          await flushOutboxToFirestore(forceFullSnapshot: true);
          _isSyncing = false;
          notifyListeners();
          return 'Firebase anonim bulut oturumu açıldı.';
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('[Firebase Auth] Genel Auth hatası: ${e.code} - ${e.message}');
        _isSyncing = false;
        notifyListeners();
        return 'Firebase Hatası (${e.code}): ${e.message}';
      } catch (e) {
        debugPrint('[Firebase Auth] Ağ veya servis hatası: $e');
        // Firebase sunucusuna ulaşılamadıysa yerel moda geç
      }
    }

    // 3. Fallback: Firebase Console kapalıysa veya internet yoksa yerel mod
    debugPrint('[Firebase Auth] Firebase sunucusuna ulaşılamadı. Yerel çevrimdışı moda geçiliyor.');
    _isSignedIn = true;
    _hasEnteredApp = true;
    _userEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim()
        : (localStore.profile.email ?? 'adil.murat@meditrans.app');
    _authLabel = 'Yerel Hesap Aktif ($_userEmail)';
    _lastSyncedAt = DateTime.now();

    await localStore.updateProfile(
      localStore.profile.copyWith(email: _userEmail),
    );
    _isSyncing = false;
    notifyListeners();
    return 'Firebase sunucusuna ulaşılamadığı için yerel hesap açıldı ($_userEmail).';
  }

  /// Yeni Hesap Oluşturma (`RegisterScreen`) — Firebase Auth `createUserWithEmailAndPassword`
  Future<String> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _isSyncing = true;
    notifyListeners();

    final cleanName = displayName.trim().isEmpty
        ? 'Aura Gezgini'
        : displayName.trim();
    final cleanEmail = email.trim();

    if (!_firebaseReady || Firebase.apps.isEmpty) {
      await initialize();
    }

    if (_firebaseReady) {
      try {
        debugPrint(
          '[Firebase Auth] Yeni hesap oluşturuluyor: $cleanEmail ($cleanName)',
        );
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        try {
          await cred.user?.updateDisplayName(cleanName);
        } catch (_) {}

        final authUid = cred.user?.uid ?? _resolveTargetUid();
        _isSignedIn = true;
        _hasEnteredApp = true;
        _userEmail = cleanEmail;
        _authLabel = 'Firebase Bulut Hesabı ($cleanEmail)';
        _lastSyncedAt = DateTime.now();

        await localStore.updateProfile(
          localStore.profile.copyWith(
            uid: authUid,
            displayName: cleanName,
            email: cleanEmail,
          ),
        );
        await flushOutboxToFirestore(forceFullSnapshot: true);

        _isSyncing = false;
        notifyListeners();
        return 'Hesabınız başarıyla oluşturuldu! Hoş geldin, $cleanName ✨';
      } on FirebaseAuthException catch (e) {
        _isSyncing = false;
        notifyListeners();
        if (e.code == 'email-already-in-use') {
          return 'Firebase: Bu e-posta ($cleanEmail) zaten kayıtlı. Giriş Yap ekranından oturum açabilirsiniz.';
        } else if (e.code == 'invalid-email') {
          return 'Firebase: Geçersiz e-posta adresi formatı.';
        } else if (e.code == 'weak-password') {
          return 'Firebase: Şifre en az 6 karakter olmalıdır.';
        }
        return 'Firebase Kayıt Hatası (${e.code}): ${e.message}';
      } catch (e) {
        debugPrint('[Firebase Auth] Kayıt sırasında ağ hatası: $e');
      }
    }

    // Çevrimdışı / yerel yedek kayıt
    _isSignedIn = true;
    _hasEnteredApp = true;
    _userEmail = cleanEmail;
    _authLabel = 'Yerel Hesap Aktif ($cleanEmail)';
    await localStore.updateProfile(
      localStore.profile.copyWith(displayName: cleanName, email: cleanEmail),
    );
    _isSyncing = false;
    notifyListeners();
    return 'Yerel profil oluşturuldu: Hoş geldin, $cleanName!';
  }

  /// Şifremi Unuttum (`ForgotPasswordScreen`) — Firebase Auth `sendPasswordResetEmail`
  Future<String> sendPasswordReset({required String email}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return 'Lütfen şifre sıfırlama bağlantısı için e-posta adresinizi girin.';
    }

    _isSyncing = true;
    notifyListeners();

    if (!_firebaseReady || Firebase.apps.isEmpty) {
      await initialize();
    }

    if (_firebaseReady) {
      try {
        debugPrint(
          '[Firebase Auth] Şifre sıfırlama e-postası gönderiliyor: $cleanEmail',
        );
        await FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);
        _isSyncing = false;
        notifyListeners();
        return 'Şifre sıfırlama bağlantısı "$cleanEmail" adresine gönderildi! E-posta kutunuzu (ve spam klasörünü) kontrol edin.';
      } on FirebaseAuthException catch (e) {
        _isSyncing = false;
        notifyListeners();
        if (e.code == 'user-not-found') {
          return 'Firebase: "$cleanEmail" adresiyle kayıtlı bir kullanıcı bulunamadı.';
        } else if (e.code == 'invalid-email') {
          return 'Firebase: Geçersiz e-posta adresi formatı.';
        }
        return 'Firebase Hatası (${e.code}): ${e.message}';
      } catch (e) {
        _isSyncing = false;
        notifyListeners();
        return 'Bağlantı hatası: Şifre sıfırlama isteği gönderilemedi ($e).';
      }
    }

    _isSyncing = false;
    notifyListeners();
    return 'Çevrimdışı modda şifre sıfırlama e-postası gönderilemez. İnternet bağlantınızı kontrol edin.';
  }

  /// Giriş yapmadan (Anonim / Misafir olarak) doğrudan uygulamaya girer.
  /// İsteğe bağlı olarak Firebase Anonymous Auth açar veya tamamen yerel modda başlatır.
  Future<String> enterAppWithoutLogin({bool tryFirebaseAnonymous = false}) async {
    if (tryFirebaseAnonymous && _firebaseReady) {
      try {
        final msg = await signInWithEmailOrAnonymous();
        _hasEnteredApp = true;
        notifyListeners();
        return msg;
      } catch (_) {}
    }

    _hasEnteredApp = true;
    _authLabel = 'Anonim / Girişsiz Mod (Yerel Depo Aktif)';
    debugPrint(
      '[Auth] Kullanıcı giriş yapmadan (anonim/yerel mod) doğrudan uygulamaya girdi.',
    );
    notifyListeners();
    return 'Giriş yapmadan anonim/yerel modda devam ediliyor.';
  }

  Future<void> signOut() async {
    try {
      if (_firebaseReady) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {}
    _isSignedIn = false;
    _hasEnteredApp = false;
    _userEmail = null;
    _authLabel = 'Misafir • Yerel Depolama';
    notifyListeners();
  }

  Future<String> flushOutboxToFirestore({bool forceFullSnapshot = false}) async {
    final pending = localStore.outbox;
    if (pending.isEmpty && !forceFullSnapshot) {
      _lastSyncedAt = DateTime.now();
      notifyListeners();
      return 'Tüm veriler güncel.';
    }

    if (_isSyncing && !forceFullSnapshot) {
      return 'Senkronizasyon devam ediyor...';
    }

    _isSyncing = true;
    notifyListeners();

    final flushedIds = <int>[];
    if (_firebaseReady) {
      try {
        final targetUid = _resolveTargetUid();
        final resolvedEmail = _userEmail ?? localStore.profile.email;
        final nowIso = DateTime.now().toIso8601String();
        final db = FirebaseFirestore.instance;
        final batch = db.batch();

        // 1. `users/{userId}` — Kullanıcı ana profil koleksiyonu
        final userDoc = db.collection(colUsers).doc(targetUid);
        batch.set(
          userDoc,
          {
            ...localStore.profile.toJson(overrideUserId: targetUid),
            'uid': targetUid,
            'userId': targetUid,
            'email': resolvedEmail,
            'updatedAt': nowIso,
          },
          SetOptions(merge: true),
        );

        // 2. `weekly_habits/{userId}` — İlişkisel Haftalık Alışkanlıklar koleksiyonu (`userId` bağlantılı)
        final habitsDoc = db.collection(colWeeklyHabits).doc(targetUid);
        batch.set(
          habitsDoc,
          {
            ...localStore.profile.toWeeklyHabitsPayload(
              overrideUserId: targetUid,
            ),
            'userId': targetUid,
            'userEmail': resolvedEmail,
            'updatedAt': nowIso,
          },
          SetOptions(merge: true),
        );

        // 3. `last_played_tracks/{userId}` — İlişkisel Son Dinlenen İçerik & Metadata koleksiyonu (`userId` bağlantılı)
        final lastPlayedDoc = db.collection(colLastPlayedTracks).doc(targetUid);
        batch.set(
          lastPlayedDoc,
          {
            ...localStore.lastPlayedTrack.toJson(overrideUserId: targetUid),
            'id': 'last_played_$targetUid',
            'userId': targetUid,
            'userEmail': resolvedEmail,
            'updatedAt': nowIso,
          },
          SetOptions(merge: true),
        );

        // 4. `mood_charts/{userId}` — İlişkisel 7 Günlük Duygu Grafiği koleksiyonu (`userId` bağlantılı)
        final moodChartDoc = db.collection(colMoodCharts).doc(targetUid);
        batch.set(
          moodChartDoc,
          {
            'id': 'chart_$targetUid',
            'userId': targetUid,
            'userEmail': resolvedEmail,
            'weeklyMoodChart': localStore.getWeeklyMoodChartPayload(
              overrideUserId: targetUid,
            ),
            'updatedAt': nowIso,
          },
          SetOptions(merge: true),
        );

        // Tam anlık görüntü istenmişse haftanın 7 gününü `mood_logs` koleksiyonuna da yaz
        if (forceFullSnapshot) {
          for (final moodEntry in localStore.getCurrentWeekMoods()) {
            final docId = '${targetUid}_${moodEntry.dateKey}';
            batch.set(
              db.collection(colMoodLogs).doc(docId),
              {
                ...moodEntry.toJson(overrideUserId: targetUid),
                'id': docId,
                'userId': targetUid,
                'userEmail': resolvedEmail,
              },
              SetOptions(merge: true),
            );
          }
          for (final favId in localStore.favoriteIds) {
            final docId = '${targetUid}_$favId';
            batch.set(
              db.collection(colUserFavorites).doc(docId),
              {
                'id': docId,
                'userId': targetUid,
                'userEmail': resolvedEmail,
                'itemId': favId,
                'updatedAt': nowIso,
              },
              SetOptions(merge: true),
            );
          }
        }

        // 5. Outbox kuyruğundaki bireysel işlemleri ilgili üst düzey koleksiyonlara dağıt
        for (final item in pending.take(25)) {
          if (item.entityType == 'profile') {
            batch.set(
              userDoc,
              {
                ...item.payload,
                'uid': targetUid,
                'userId': targetUid,
                'email': resolvedEmail,
                'updatedAt': nowIso,
              },
              SetOptions(merge: true),
            );
          } else if (item.entityType == 'weekly_habits') {
            batch.set(
              habitsDoc,
              {
                ...item.payload,
                'id': 'habits_$targetUid',
                'userId': targetUid,
                'userEmail': resolvedEmail,
                'updatedAt': nowIso,
              },
              SetOptions(merge: true),
            );
          } else if (item.entityType == 'last_played') {
            batch.set(
              lastPlayedDoc,
              {
                ...item.payload,
                'id': 'last_played_$targetUid',
                'userId': targetUid,
                'userEmail': resolvedEmail,
                'updatedAt': nowIso,
              },
              SetOptions(merge: true),
            );
          } else if (item.entityType == 'mood_chart') {
            batch.set(
              moodChartDoc,
              {
                'id': 'chart_$targetUid',
                'userId': targetUid,
                'userEmail': resolvedEmail,
                'weeklyMoodChart': localStore.getWeeklyMoodChartPayload(
                  overrideUserId: targetUid,
                ),
                'updatedAt': nowIso,
              },
              SetOptions(merge: true),
            );
          } else if (item.entityType == 'mood') {
            final dateKey =
                item.payload['dateKey']?.toString() ?? item.entityId;
            final docId = '${targetUid}_$dateKey';
            batch.set(
              db.collection(colMoodLogs).doc(docId),
              {
                ...item.payload,
                'id': docId,
                'userId': targetUid,
                'userEmail': resolvedEmail,
              },
              SetOptions(merge: true),
            );
          } else if (item.entityType == 'session') {
            final docId = '${targetUid}_${item.entityId}';
            batch.set(
              db.collection(colSessionHistory).doc(docId),
              {
                ...item.payload,
                'id': docId,
                'userId': targetUid,
                'userEmail': resolvedEmail,
              },
              SetOptions(merge: true),
            );
          } else if (item.entityType == 'favorite') {
            final itemId = item.payload['itemId']?.toString() ?? item.entityId;
            final docId = '${targetUid}_$itemId';
            final favRef = db.collection(colUserFavorites).doc(docId);
            if (item.operation == 'DELETE') {
              batch.delete(favRef);
            } else {
              batch.set(
                favRef,
                {
                  ...item.payload,
                  'id': docId,
                  'userId': targetUid,
                  'userEmail': resolvedEmail,
                  'itemId': itemId,
                },
                SetOptions(merge: true),
              );
            }
          }
          flushedIds.add(item.id);
        }

        await batch.commit().timeout(const Duration(seconds: 5));
        await localStore.markOutboxItemsFlushed(flushedIds);
        _lastSyncedAt = DateTime.now();
        _isSyncing = false;
        notifyListeners();
        debugPrint(
          '[Firestore Sync] BAŞARILI! İlişkisel koleksiyonlar güncellendi (userId=$targetUid):\n'
          '  • users/$targetUid\n'
          '  • weekly_habits/$targetUid (${localStore.profile.habitsTr.length} alışkanlık)\n'
          '  • last_played_tracks/$targetUid ("${localStore.lastPlayedTrack.title}" - ${localStore.lastPlayedTrack.categoryLabelTr})\n'
          '  • mood_charts/$targetUid (7 günlük duygu grafiği)\n'
          '  • mood_logs (${targetUid}_YYYY-MM-DD)',
        );
        return '${flushedIds.isEmpty ? 4 : flushedIds.length} ilişkisel koleksiyon kaydı Firestore bulutuna senkronize edildi.';
      } catch (e) {
        flushedIds.clear();
        final currentUser = FirebaseAuth.instance.currentUser;
        final authHint = currentUser == null
            ? 'Henüz Firebase Auth oturumu açılmadı (Aktif kullanıcı: yok). Profil sekmesinden giriş yapın veya Firestore Rules izinlerini kontrol edin.'
            : 'Firebase Console > Firestore Database > Rules sekmesinde yazma izni kapalı olabilir (Aktif UID: ${currentUser.uid}).';
        debugPrint(
          '[Firestore Sync] Firestore yazma hatası ($e). $authHint\n'
          '[LocalStore] Merak etmeyin: Tüm verileriniz (Son dinlenen: "${localStore.lastPlayedTrack.title}", Weekly Habits, Duygu grafiği ve notlarınız) yerel depoya kaydedildi! Kuyrukta bekleyen: ${pending.length} kayıt.',
        );
      }
    }

    _lastSyncedAt = DateTime.now();
    _isSyncing = false;
    notifyListeners();
    return 'Veriler yerel depoya kaydedildi (${pending.length} kayıt bulut kuyruğunda bekliyor).';
  }
}
