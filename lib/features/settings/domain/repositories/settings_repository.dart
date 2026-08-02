import '../entities/settings_entities.dart';

abstract class SettingsRepository {
  Future<SettingsPageData> getSettings();
  Future<NotificationsPageData> getNotifications();
}
