import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_env.dart';
import '../platform/media_cache.dart';

class ResolvedMediaSource {
  final bool isLocalAsset;
  final bool isLocalFile;
  final bool isRemoteUrl;
  final String path; // Asset key, file path, or remote URL

  const ResolvedMediaSource.asset(String assetPath)
    : isLocalAsset = true,
      isLocalFile = false,
      isRemoteUrl = false,
      path = assetPath;

  const ResolvedMediaSource.file(String filePath)
    : isLocalAsset = false,
      isLocalFile = true,
      isRemoteUrl = false,
      path = filePath;

  const ResolvedMediaSource.url(String url)
    : isLocalAsset = false,
      isLocalFile = false,
      isRemoteUrl = true,
      path = url;
}

/// Resolves audio and visual assets across bundled assets, native disk cache,
/// and Supabase Storage (`meditation-audio` free-tier bucket).
class MediaStorageGateway extends ChangeNotifier {
  final AppEnvConfig env;
  final PlatformMediaCache _diskCache = PlatformMediaCache();

  bool _supabaseInitialized = false;
  int _cachedBytes = 0;

  MediaStorageGateway({required this.env});

  bool get isSupabaseReady => _supabaseInitialized;
  int get cachedBytes => _cachedBytes;

  Future<void> initialize() async {
    if (env.hasSupabaseConfig) {
      try {
        final cleanUrl = env.supabaseUrl
            .trim()
            .replaceAll(RegExp(r'/rest/v1/?$'), '')
            .replaceAll(RegExp(r'/+$'), '');
        await Supabase.initialize(
          url: cleanUrl,
          // ignore: deprecated_member_use
          anonKey: env.supabasePublishableKey.trim(),
        );
        _supabaseInitialized = true;
      } catch (_) {
        _supabaseInitialized = false;
      }
    }
    await refreshCacheSize();
  }

  /// Resolves a playable source.
  /// 1. If a bundled local asset exists in `assets/audio/...`, returns it immediately
  ///    for zero-latency offline playback while keeping Supabase Storage ready.
  /// 2. If `preferCloudStream` is enabled and Supabase is configured, resolves from
  ///    `meditation-audio` bucket and caches on native disk.
  Future<ResolvedMediaSource> resolveAudio({
    required String localAssetPath,
    required String remoteStoragePath,
    bool preferCloudStream = false,
  }) async {
    final normalizedAsset = localAssetPath.startsWith('assets/')
        ? localAssetPath.substring('assets/'.length)
        : localAssetPath;

    if (!preferCloudStream || !_supabaseInitialized) {
      return ResolvedMediaSource.asset(normalizedAsset);
    }

    final safeFileName = remoteStoragePath.replaceAll('/', '_');
    if (!kIsWeb) {
      final cachedFile = await _diskCache.getExistingFilePath(safeFileName);
      if (cachedFile != null) {
        return ResolvedMediaSource.file(cachedFile);
      }
    }

    try {
      final publicUrl = Supabase.instance.client.storage
          .from('meditation-audio')
          .getPublicUrl(remoteStoragePath);

      if (!kIsWeb) {
        final response = await http
            .get(Uri.parse(publicUrl))
            .timeout(const Duration(seconds: 6));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final saved = await _diskCache.saveFileBytes(
            safeFileName,
            response.bodyBytes,
          );
          await refreshCacheSize();
          if (saved != null) {
            return ResolvedMediaSource.file(saved);
          }
        }
      } else {
        return ResolvedMediaSource.url(publicUrl);
      }
    } catch (_) {}

    return ResolvedMediaSource.asset(normalizedAsset);
  }

  Future<void> refreshCacheSize() async {
    _cachedBytes = await _diskCache.getCachedBytesSize();
    notifyListeners();
  }

  Future<void> clearAllCachedMedia() async {
    await _diskCache.clearCache();
    await refreshCacheSize();
  }
}
