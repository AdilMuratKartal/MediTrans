import 'dart:typed_data';

/// Web (Chrome / web-server) implementation with zero `dart:io` dependencies.
/// Relies on browser HTTP cache + service worker.
class PlatformMediaCache {
  Future<String?> getExistingFilePath(String fileName) async => null;

  Future<String?> saveFileBytes(String fileName, Uint8List bytes) async => null;

  Future<int> getCachedBytesSize() async => 0;

  Future<void> clearCache() async {}
}
