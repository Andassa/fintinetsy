import 'package:hive_flutter/hive_flutter.dart';

class EtagCache {
  EtagCache(this._box) : _memory = null;

  EtagCache.memory()
      : _box = null,
        _memory = <String, String>{};

  final Box<String>? _box;
  final Map<String, String>? _memory;

  static const boxName = 'etag_cache';

  static Future<EtagCache> open() async {
    final box = await Hive.openBox<String>(boxName);
    return EtagCache(box);
  }

  String? etagFor(String path) {
    final key = 'etag:$path';
    return _memory != null ? _memory[key] : _box!.get(key);
  }

  String? bodyFor(String path) {
    final key = 'body:$path';
    return _memory != null ? _memory[key] : _box!.get(key);
  }

  Future<void> save({
    required String path,
    required String etag,
    required String body,
  }) async {
    if (_memory != null) {
      _memory['etag:$path'] = etag;
      _memory['body:$path'] = body;
      return;
    }
    await _box!.put('etag:$path', etag);
    await _box.put('body:$path', body);
  }

  Future<void> clear() async {
    if (_memory != null) {
      _memory.clear();
      return;
    }
    await _box!.clear();
  }
}
