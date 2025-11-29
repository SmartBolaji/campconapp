import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CustomCacheManager extends CacheManager {
  static const Duration stalePeriod = Duration(days: 3);
  static const int maxImages = 300;
  static const String key = "dressfli_image_cache";

  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    _instance ??= _createInstance();
    return _instance!;
  }

  CustomCacheManager._()
      : super(Config(
          key,
          stalePeriod: stalePeriod,
          maxNrOfCacheObjects: maxImages,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileSystem: IOFileSystem(key),
        ));

  static CustomCacheManager _createInstance() {
    try {
      return CustomCacheManager._();
    } catch (e) {
      debugPrint('Error initializing cache manager: $e');
      _recoverFromCorruptCache();
      return CustomCacheManager._();
    }
  }

  static Future<void> _recoverFromCorruptCache() async {
    try {
      final cacheDir = Directory(
          '${(await getTemporaryDirectory()).path}/dressfli_image_cache');
      if (await cacheDir.exists()) {
        final cacheFile = File('${cacheDir.path}/cache.json');
        if (await cacheFile.exists()) {
          await cacheFile.delete();
          debugPrint('Deleted corrupt cache file');
        }
      }
    } catch (e) {
      debugPrint('Error recovering from corrupt cache: $e');
    }
  }

  Future<void> resetCache() async {
    try {
      await emptyCache();
      _instance = null;
      debugPrint('Cache reset completed');
    } catch (e) {
      debugPrint('Error resetting cache: $e');
    }
  }

  Future<void> clearOldCache() async {
    final cacheObjects = await getObjectsOlderThan(
      DateTime.now().subtract(stalePeriod),
    );
    await Future.wait(
      cacheObjects.map((object) => removeFile(object.url)),
    );
  }

  Future<List<CacheObject>> getObjectsOlderThan(DateTime dateTime) async {
    try {
      final cacheInfoRepository = store as JsonCacheInfoRepository;
      final allObjects = await cacheInfoRepository.getAllObjects();
      return allObjects
          .where((object) => object.validTill.isBefore(dateTime))
          .toList();
    } catch (e) {
      debugPrint('Error getting old cache objects: $e');
      return [];
    }
  }
}

// Video Cache Manager - Separate cache for videos
class VideoCacheManager extends CacheManager {
  static const Duration stalePeriod = Duration(days: 7); // Longer for videos
  static const int maxVideos = 50; // Fewer videos due to size
  static const String key = "dressfli_video_cache";

  static VideoCacheManager? _instance;

  factory VideoCacheManager() {
    _instance ??= VideoCacheManager._();
    return _instance!;
  }

  VideoCacheManager._()
      : super(Config(
          key,
          stalePeriod: stalePeriod,
          maxNrOfCacheObjects: maxVideos,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileSystem: IOFileSystem(key),
        ));

  // Preload video method
  Future<File?> getCachedVideo(String url) async {
    try {
      final fileInfo = await getFileFromCache(url);
      if (fileInfo != null) {
        debugPrint('Video found in cache: $url');
        return fileInfo.file;
      }

      debugPrint('Video not in cache, downloading: $url');
      final file = await downloadFile(url);
      return file.file;
    } catch (e) {
      debugPrint('Error getting cached video: $e');
      return null;
    }
  }

  // Check if video is cached
  Future<bool> isVideoCached(String url) async {
    try {
      final fileInfo = await getFileFromCache(url);
      return fileInfo != null;
    } catch (e) {
      return false;
    }
  }
}

extension CachePreload on CustomCacheManager {
  Future<void> preloadImages(List<String> urls) async {
    if (urls.isEmpty) return;

    try {
      final List<String> urlsToDownload = [];

      for (final url in urls) {
        final fileInfo = await getFileFromCache(url);
        if (fileInfo == null) {
          urlsToDownload.add(url);
        }
      }

      if (urlsToDownload.isEmpty) return;

      debugPrint('Preloading ${urlsToDownload.length} images');

      if (urlsToDownload.length > 2) {
        await Future.wait(
          urlsToDownload.take(2).map((url) => downloadFile(url)),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await Future.wait(
          urlsToDownload.skip(2).map((url) => downloadFile(url)),
        );
      } else {
        await Future.wait(
          urlsToDownload.map((url) => downloadFile(url)),
        );
      }
    } catch (e) {
      debugPrint('Error preloading images: $e');
    }
  }
}
