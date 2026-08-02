class SettingsItem {
  const SettingsItem({
    required this.id,
    required this.label,
    required this.iconKey,
    this.isToggle = false,
  });

  final String id;
  final String label;
  final String iconKey;
  final bool isToggle;
}

class SettingsSection {
  const SettingsSection({required this.title, required this.items});
  final String title;
  final List<SettingsItem> items;
}

class SettingsPageData {
  const SettingsPageData({required this.sections});
  final List<SettingsSection> sections;
}

enum NotificationTrailing { none, badge, progress, check }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.colorHex,
    this.trailing = NotificationTrailing.none,
    this.badge,
    this.progress,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final String colorHex;
  final NotificationTrailing trailing;
  final String? badge;
  final double? progress;
}

class NotificationsPageData {
  const NotificationsPageData({
    required this.today,
    required this.past,
  });
  final List<AppNotification> today;
  final List<AppNotification> past;
}
