import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';

class HttpSettingsRepository implements SettingsRepository {
  HttpSettingsRepository(this._api);

  final ApiClient _api;

  @override
  Future<SettingsPageData> getSettings() async {
    try {
      final response = await _api.raw.get<Map<String, dynamic>>('/settings');
      final data = response.data!;
      final sections = (data['sections'] as List<dynamic>).map((raw) {
        final s = raw as Map<String, dynamic>;
        return SettingsSection(
          title: s['title'] as String,
          items: (s['items'] as List<dynamic>).map((item) {
            final i = item as Map<String, dynamic>;
            return SettingsItem(
              id: i['id'] as String,
              label: i['label'] as String,
              iconKey: i['icon_key'] as String,
              isToggle: i['is_toggle'] as bool? ?? false,
            );
          }).toList(),
        );
      }).toList();
      return SettingsPageData(sections: sections);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  @override
  Future<NotificationsPageData> getNotifications() async {
    try {
      final today = await _fetchScope('today');
      final past = await _fetchScope('past');
      return NotificationsPageData(today: today, past: past);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  Future<List<AppNotification>> _fetchScope(String scope) async {
    final response = await _api.raw.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'scope': scope, 'limit': 20},
    );
    final items =
        (response.data?['items'] as Map<String, dynamic>?)?['items']
            as List<dynamic>? ??
        [];
    return items.map((raw) {
      final n = raw as Map<String, dynamic>;
      return AppNotification(
        id: n['id'].toString(),
        title: n['title'] as String,
        subtitle: n['subtitle'] as String,
        iconKey: n['icon_key'] as String,
        colorHex: n['color_hex'] as String,
        trailing: _mapTrailing(n['trailing'] as String?),
        badge: n['badge'] as String?,
        progress: (n['progress'] as num?)?.toDouble(),
      );
    }).toList();
  }

  NotificationTrailing _mapTrailing(String? raw) {
    switch (raw) {
      case 'badge':
        return NotificationTrailing.badge;
      case 'progress':
        return NotificationTrailing.progress;
      case 'check':
        return NotificationTrailing.check;
      default:
        return NotificationTrailing.none;
    }
  }
}
