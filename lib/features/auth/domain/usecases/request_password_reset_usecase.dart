import '../entities/password_sent_result.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<PasswordSentResult> call({
    required String methodId,
    required String email,
  }) =>
      _repository.requestPasswordReset(methodId: methodId, email: email);
}
