import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

///Cached data
///
///put data in cache, get data from cache, remove
///
///data from cache empty cache etc.
class CacheService extends ChangeNotifier {
  DefaultCacheManager _cacheManager = DefaultCacheManager();
  File profileImage;

  CacheService() {
    _initialize();
  }

  /// initialize cache
  ///
  /// load cached profile image.
  Future<void> _initialize() async {
    // load profile image
    profileImage = await getFileFromCache("profile");
    // notify listners to re-render if image exists
    if (profileImage != null) notifyListeners();
  }

  /// load file from cache with given key
  Future<File> getFileFromCache(String key, {String url}) async {
    FileInfo f = await _cacheManager.getFileFromCache(
      key,
    );
    return f?.file;
  }

  /// replace cached profile image when profile image is changed
  Future<void> changeProfileImage({File file, String url}) async {
    if (url.startsWith("http")) {
      profileImage = file;
      // remove file
      await removeFileFromCache("profile");
      // put new file in cache
      await _cacheManager.putFile(url, file.readAsBytesSync(), key: "profile");
      // notify listners to re-render with updated image.
      notifyListeners();
    }
  }

  /// download and cache profile image from url.
  Future<void> downloadAndCacheFile(String url) async {
    if (url.startsWith("http")) {
      FileInfo f = await _cacheManager.downloadFile(url, key: "profile");
      if (f != null) {
        profileImage = f.file;
        notifyListeners();
      }
    }
  }

  /// remove file from cache
  Future<void> removeFileFromCache(String key) async {
    await _cacheManager.removeFile(key);
  }

  /// clear whole cache.
  Future<void> emptyCache() async {
    profileImage = null;
    await _cacheManager.emptyCache();
  }
}
