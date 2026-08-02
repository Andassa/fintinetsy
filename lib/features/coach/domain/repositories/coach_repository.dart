import '../entities/coach_entities.dart';

abstract class CoachRepository {
  Future<CoachHubData> getHub();
  Future<AiChatsPageData> getChats();
  Future<AiChatThread> getThread();
}
