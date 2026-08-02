import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class SignInWithGoogleOAuthUseCase {
  SignInWithGoogleOAuthUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String idToken,
    String? email,
    String? name,
  }) {
    return _repository.signInWithGoogleOAuth(
      idToken: idToken,
      email: email,
      name: name,
    );
  }
}
