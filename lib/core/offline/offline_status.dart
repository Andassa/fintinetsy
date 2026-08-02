import 'package:flutter/material.dart';

/// Tracks whether the last network read was served from the Hive offline cache.
class OfflineStatus extends ChangeNotifier {
  bool _servingFromCache = false;
  String? _message;

  bool get servingFromCache => _servingFromCache;
  String? get message => _message;

  void markOnline() {
    if (!_servingFromCache && _message == null) return;
    _servingFromCache = false;
    _message = null;
    notifyListeners();
  }

  void markFromCache([String? message]) {
    _servingFromCache = true;
    _message = message ??
        'You are offline. Showing cached data from Hive.';
    notifyListeners();
  }
}

/// Thin banner shown when [OfflineStatus.servingFromCache] is true.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.status});

  final OfflineStatus status;

  @override
  Widget build(BuildContext context) {
    if (!status.servingFromCache) return const SizedBox.shrink();
    return Material(
      color: const Color(0xFFFFF3E0),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, size: 18, color: Color(0xFFE65100)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status.message ?? 'Offline mode',
                  style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
