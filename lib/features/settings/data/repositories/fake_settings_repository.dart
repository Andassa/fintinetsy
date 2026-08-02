import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  @override
  Future<SettingsPageData> getSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const SettingsPageData(
      sections: [
        SettingsSection(
          title: 'General',
          items: [
            SettingsItem(
              id: 'notification',
              label: 'Notification',
              iconKey: 'notifications',
            ),
            SettingsItem(
              id: 'personal',
              label: 'Personal Information',
              iconKey: 'person',
            ),
            SettingsItem(
              id: 'coach',
              label: 'Coach Contact',
              iconKey: 'phone',
            ),
            SettingsItem(
              id: 'dark_mode',
              label: 'Dark Mode',
              iconKey: 'flag',
              isToggle: true,
            ),
            SettingsItem(
              id: 'devices',
              label: 'Linked Devices',
              iconKey: 'watch',
            ),
          ],
        ),
        SettingsSection(
          title: 'Security & Privacy',
          items: [
            SettingsItem(
              id: 'security',
              label: 'Main Security',
              iconKey: 'lock',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<NotificationsPageData> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    const items = [
      AppNotification(
        id: 'n1',
        title: 'Unread AI Chatbot Messages',
        subtitle: '8 new messages from Uplift.ai',
        iconKey: 'notifications',
        colorHex: '#FFFFFF',
        trailing: NotificationTrailing.badge,
        badge: '4+',
      ),
      AppNotification(
        id: 'n2',
        title: 'Score Increased',
        subtitle: 'Uplift Score is 87',
        iconKey: 'score',
        colorHex: '#FF7A28',
        trailing: NotificationTrailing.badge,
        badge: '8+',
      ),
      AppNotification(
        id: 'n3',
        title: 'Drink More Water',
        subtitle: 'You need to drink 1500ml left.',
        iconKey: 'water',
        colorHex: '#2A66F6',
        trailing: NotificationTrailing.progress,
        progress: 0.35,
      ),
      AppNotification(
        id: 'n4',
        title: 'Workout Complete',
        subtitle: 'Upper Body Set Completed',
        iconKey: 'dumbbell',
        colorHex: '#88D317',
        trailing: NotificationTrailing.check,
      ),
      AppNotification(
        id: 'n5',
        title: 'Nutrition Upgrade',
        subtitle: 'Take 87g of protein!',
        iconKey: 'apple',
        colorHex: '#A335F3',
      ),
      AppNotification(
        id: 'n6',
        title: 'Fitness Data Ready!',
        subtitle: "Here's fitness data for November",
        iconKey: 'data',
        colorHex: '#F14C4C',
      ),
    ];
    return const NotificationsPageData(today: items, past: items);
  }
}
