class CoachConversationPreview {
  const CoachConversationPreview({
    required this.id,
    required this.title,
    required this.model,
    required this.totalLabel,
    required this.iconKey,
    required this.colorHex,
  });

  final String id;
  final String title;
  final String model;
  final String totalLabel;
  final String iconKey;
  final String colorHex;
}

class CoachHubData {
  const CoachHubData({
    required this.totalConversations,
    required this.totalLabel,
    required this.modelLabel,
    required this.conversations,
    required this.proTitle,
    required this.proBenefits,
  });

  final String totalConversations;
  final String totalLabel;
  final String modelLabel;
  final List<CoachConversationPreview> conversations;
  final String proTitle;
  final List<String> proBenefits;
}

class AiChatListItem {
  const AiChatListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.colorHex,
    this.badge,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final String colorHex;
  final String? badge;
}

class AiChatsPageData {
  const AiChatsPageData({required this.items});
  final List<AiChatListItem> items;
}

enum ChatBubbleKind { bot, userSuggestion, botCard }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.kind,
    required this.text,
    this.selected = false,
    this.cardTitle,
    this.cardSubtitle,
    this.tags,
  });

  final String id;
  final ChatBubbleKind kind;
  final String text;
  final bool selected;
  final String? cardTitle;
  final String? cardSubtitle;
  final List<String>? tags;
}

class AiChatThread {
  const AiChatThread({
    required this.botName,
    required this.status,
    required this.timestamp,
    required this.messages,
  });

  final String botName;
  final String status;
  final String timestamp;
  final List<ChatMessage> messages;
}
