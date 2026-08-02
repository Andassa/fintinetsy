import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/coach_entities.dart';
import '../../domain/repositories/coach_repository.dart';

class HttpCoachRepository implements CoachRepository {
  HttpCoachRepository(this._api);

  final ApiClient _api;
  String? _cachedChatId;

  @override
  Future<CoachHubData> getHub() async {
    try {
      final response =
          await _api.raw.get<Map<String, dynamic>>('/coach/hub');
      final data = response.data!;
      final conversations = (data['conversations'] as List<dynamic>).map((raw) {
        final c = raw as Map<String, dynamic>;
        return CoachConversationPreview(
          id: c['id'].toString(),
          title: c['title'] as String,
          model: c['model'] as String,
          totalLabel: c['total_label'] as String,
          iconKey: c['icon_key'] as String,
          colorHex: c['color_hex'] as String,
        );
      }).toList();
      if (conversations.isNotEmpty) {
        _cachedChatId = conversations.first.id;
      }
      return CoachHubData(
        totalConversations: data['total_conversations'] as String,
        totalLabel: data['total_label'] as String,
        modelLabel: data['model_label'] as String,
        conversations: conversations,
        proTitle: data['pro_title'] as String,
        proBenefits: (data['pro_benefits'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<AiChatsPageData> getChats() async {
    try {
      final response = await _api.raw.get<Map<String, dynamic>>(
        '/coach/chats',
        queryParameters: {'tab': 'ai', 'limit': 20},
      );
      final items =
          (response.data?['items'] as List<dynamic>?) ?? [];
      final mapped = items.map((raw) {
        final c = raw as Map<String, dynamic>;
        return AiChatListItem(
          id: c['id'].toString(),
          title: c['title'] as String,
          subtitle: c['subtitle'] as String,
          iconKey: c['icon_key'] as String,
          colorHex: c['color_hex'] as String,
          badge: c['badge'] as String?,
        );
      }).toList();
      if (mapped.isNotEmpty) {
        _cachedChatId = mapped.first.id;
      }
      return AiChatsPageData(items: mapped);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<AiChatThread> getThread() async {
    try {
      final chatId = _cachedChatId ?? await _resolveChatId();
      final response = await _api.raw.get<Map<String, dynamic>>(
        '/coach/chats/$chatId/messages',
        queryParameters: {'limit': 50},
      );
      final data = response.data!;
      final page = data['messages'] as Map<String, dynamic>;
      final items = (page['items'] as List<dynamic>?) ?? [];
      return AiChatThread(
        botName: data['bot_name'] as String,
        status: data['status'] as String,
        timestamp: data['timestamp'] as String,
        messages: items.map((raw) {
          final m = raw as Map<String, dynamic>;
          return ChatMessage(
            id: m['id'].toString(),
            kind: _mapKind(m['kind'] as String?),
            text: m['text'] as String? ?? '',
            selected: m['selected'] as bool? ?? false,
            cardTitle: m['card_title'] as String?,
            cardSubtitle: m['card_subtitle'] as String?,
            tags: (m['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
          );
        }).toList(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<String> _resolveChatId() async {
    final chats = await getChats();
    if (chats.items.isEmpty) {
      throw ApiException('No coach chats available');
    }
    _cachedChatId = chats.items.first.id;
    return _cachedChatId!;
  }

  ChatBubbleKind _mapKind(String? raw) {
    switch (raw) {
      case 'user_suggestion':
        return ChatBubbleKind.userSuggestion;
      case 'bot_card':
        return ChatBubbleKind.botCard;
      case 'user':
        return ChatBubbleKind.userSuggestion;
      default:
        return ChatBubbleKind.bot;
    }
  }

  Exception _map(DioException e) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException.fromDio(e);
  }
}
