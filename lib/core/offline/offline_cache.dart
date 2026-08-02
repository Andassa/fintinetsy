import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Local offline store backed by **Hive**.
///
/// Persists JSON payloads keyed by API path so the app can:
/// 1. Serve cached GET responses when the device is offline
/// 2. Revalidate with ETags (`If-None-Match` / HTTP 304)
class OfflineCache {
  OfflineCache(this._box) : _memory = null;

  OfflineCache.memory()
      : _box = null,
        _memory = <String, String>{};

  final Box<String>? _box;
  final Map<String, String>? _memory;

  static const boxName = 'uplift_offline_cache';

  static Future<OfflineCache> open() async {
    final box = await Hive.openBox<String>(boxName);
    return OfflineCache(box);
  }

  bool get isHiveBacked => _box != null;

  String? etagFor(String path) => _read('etag:$path');

  String? bodyFor(String path) => _read('body:$path');

  bool hasBody(String path) {
    final body = bodyFor(path);
    return body != null && body.isNotEmpty;
  }

  Map<String, dynamic>? jsonFor(String path) {
    final raw = bodyFor(path);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> saveResponse({
    required String path,
    required String body,
    String? etag,
  }) async {
    await _write('body:$path', body);
    await _write('etag:$path', etag ?? 'local');
    await _write('saved_at:$path', DateTime.now().toUtc().toIso8601String());
  }

  /// Convenience for feature repositories that cache domain JSON offline.
  Future<void> putJson(String key, Map<String, dynamic> json) async {
    await saveResponse(path: key, body: jsonEncode(json), etag: 'entity');
  }

  Future<void> clear() async {
    if (_memory != null) {
      _memory.clear();
      return;
    }
    await _box!.clear();
  }

  String? _read(String key) {
    return _memory != null ? _memory[key] : _box!.get(key);
  }

  Future<void> _write(String key, String value) async {
    if (_memory != null) {
      _memory[key] = value;
      return;
    }
    await _box!.put(key, value);
  }
}

/// Backward-compatible alias used by older call sites / docs.
typedef EtagCache = OfflineCache;
