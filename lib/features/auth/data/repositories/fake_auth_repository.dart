import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/password_sent_result.dart';
import '../../domain/entities/reset_method_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthLocalDataSource? local})
      : _local = local ?? AuthLocalDataSource();

  final AuthLocalDataSource _local;

  @override
  Future<UserEntity> signIn(AuthCredentials credentials) async {
    final model = await _local.signIn(
      email: credentials.email,
      password: credentials.password,
    );
    return model.toEntity();
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final model = await _local.signUp(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    return model.toEntity();
  }

  @override
  Future<List<ResetMethodEntity>> getResetMethods() async {
    final models = await _local.getResetMethods();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PasswordSentResult> requestPasswordReset({
    required String methodId,
    required String email,
  }) async {
    final json = await _local.requestPasswordReset(
      methodId: methodId,
      email: email,
    );
    return PasswordSentResult(
      email: json['email'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      canResend: json['canResend'] as bool,
    );
  }

  @override
  Future<PasswordSentResult> resendPassword({required String email}) {
    return requestPasswordReset(methodId: 'reset_email', email: email);
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> hasValidSession() async => false;
}
