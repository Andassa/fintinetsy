import '../entities/auth_credentials.dart';
import '../entities/password_sent_result.dart';
import '../entities/reset_method_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(AuthCredentials credentials);

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<List<ResetMethodEntity>> getResetMethods();

  Future<PasswordSentResult> requestPasswordReset({
    required String methodId,
    required String email,
  });

  Future<PasswordSentResult> resendPassword({required String email});

  Future<void> signOut();

  Future<bool> hasValidSession();
}
