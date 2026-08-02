import 'package:hive_flutter/hive_flutter.dart';

/// Offline cache keyed by path, stores body + ETag for revalidation.
class EtagCache {
  EtagCache(this._box);

  final Box<String> _box;

  static const boxName = 'etag_cache';

  static Future<EtagCache> open() async {
    final box = await Hive.openBox<String>(boxName);
    return EtagCache(box);
  }

  String? etagFor(String path) => _box.get('etag:$path');

  String? bodyFor(String path) => _box.get('body:$path');

  Future<void> save({
    required String path,
    required String etag,
    required String body,
  }) async {
    await _box.put('etag:$path', etag);
    await _box.put('body:$path', body);
  }

  Future<void> clear() => _box.clear();
}
