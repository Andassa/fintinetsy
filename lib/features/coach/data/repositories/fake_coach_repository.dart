import '../../domain/entities/coach_entities.dart';
import '../../domain/repositories/coach_repository.dart';

class FakeCoachRepository implements CoachRepository {
  @override
  Future<CoachHubData> getHub() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const CoachHubData(
      totalConversations: '9,781',
      totalLabel: '245total',
      modelLabel: 'Gpt4.0',
      conversations: [
        CoachConversationPreview(
          id: 'c1',
          title: 'How to get bulk fast..',
          model: 'Gpt4.0',
          totalLabel: '456 Total',
          iconKey: 'restaurant',
          colorHex: '#FF7D33',
        ),
        CoachConversationPreview(
          id: 'c2',
          title: 'Should i Meditate?',
          model: 'Gpt4.0',
          totalLabel: '45 Total',
          iconKey: 'bolt',
          colorHex: '#2B65EC',
        ),
      ],
      proTitle: 'Go Pro, Now!',
      proBenefits: ['Weekend Cheat', 'Fast Growth'],
    );
  }

  @override
  Future<AiChatsPageData> getChats() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const AiChatsPageData(
      items: [
        AiChatListItem(
          id: 'a1',
          title: 'How to bulk faster?',
          subtitle: '8 new messages from Uplift.ai',
          iconKey: 'notifications',
          colorHex: '#FFFFFF',
          badge: '4+',
        ),
        AiChatListItem(
          id: 'a2',
          title: 'Optimal Fitness Sch...',
          subtitle: 'Uplift Score is 87',
          iconKey: 'score',
          colorHex: '#FF7A00',
        ),
        AiChatListItem(
          id: 'a3',
          title: 'How much water daily?',
          subtitle: 'You need to drink 1500ml left.',
          iconKey: 'water',
          colorHex: '#2A66F6',
        ),
        AiChatListItem(
          id: 'a4',
          title: 'Gaining muscle fast',
          subtitle: 'Upper Body Set Completed',
          iconKey: 'dumbbell',
          colorHex: '#88D317',
        ),
        AiChatListItem(
          id: 'a5',
          title: 'Nutrition Upgrade',
          subtitle: 'Take 87g of protein!',
          iconKey: 'apple',
          colorHex: '#A335F3',
        ),
        AiChatListItem(
          id: 'a6',
          title: 'Fitness Data Ready!',
          subtitle: "Here's fitness data for November",
          iconKey: 'data',
          colorHex: '#F14C4C',
        ),
      ],
    );
  }

  @override
  Future<AiChatThread> getThread() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const AiChatThread(
      botName: 'Uplift',
      status: 'Always active',
      timestamp: 'Wed 8:21 AM',
      messages: [
        ChatMessage(
          id: 'm1',
          kind: ChatBubbleKind.bot,
          text:
              "Hello, I'm Uplift! 👋 I'm your personal sport assistant. How can I help you?",
        ),
        ChatMessage(
          id: 'm2',
          kind: ChatBubbleKind.userSuggestion,
          text: 'Book me a visit in a gym',
        ),
        ChatMessage(
          id: 'm3',
          kind: ChatBubbleKind.userSuggestion,
          text: 'Show me other sports facilities around',
        ),
        ChatMessage(
          id: 'm4',
          kind: ChatBubbleKind.userSuggestion,
          text: 'Show me other options',
          selected: true,
        ),
        ChatMessage(
          id: 'm5',
          kind: ChatBubbleKind.bot,
          text: 'Ok, how about these?',
        ),
        ChatMessage(
          id: 'm6',
          kind: ChatBubbleKind.botCard,
          text: '',
          cardTitle: 'BodyWorks on Nadwiślańska 12 street',
          cardSubtitle: '250 meters • 30 zł/one entrance all day',
          tags: ['Gym', 'SPA', 'Pool'],
        ),
      ],
    );
  }
}
