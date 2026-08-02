import 'user_entity.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
  });

  final UserEntity user;
  final String accessToken;
}
