import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Native (macOS, Windows, iOS, Android) disk cache implementation.
class PlatformMediaCache {
  Future<String?> getExistingFilePath(String fileName) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory(
        '${dir.path}${Platform.pathSeparator}media_cache',
      );
      final file = File('${cacheDir.path}${Platform.pathSeparator}$fileName');
      if (await file.exists() && await file.length() > 0) {
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> saveFileBytes(String fileName, Uint8List bytes) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory(
        '${dir.path}${Platform.pathSeparator}media_cache',
      );
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      final file = File('${cacheDir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<int> getCachedBytesSize() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory(
        '${dir.path}${Platform.pathSeparator}media_cache',
      );
      if (!await cacheDir.exists()) return 0;
      var total = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearCache() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory(
        '${dir.path}${Platform.pathSeparator}media_cache',
      );
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
