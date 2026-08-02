import '../models/reset_method_model.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    return UserModel(
      id: 'usr_221b',
      name: 'Eren',
      email: email,
      avatarUrl: null,
    );
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }
    if (email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }
    return UserModel(
      id: 'usr_new_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
    );
  }

  Future<List<ResetMethodModel>> getResetMethods() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      ResetMethodModel(
        id: 'reset_email',
        type: 'email',
        title: 'Send via Email',
        description: 'Reset your password by email.',
        iconColorHex: '#FF7020',
        iconKey: 'email',
      ),
      ResetMethodModel(
        id: 'reset_2fa',
        type: 'twoFactor',
        title: 'Send via 2FA',
        description: 'Reset your password with two-factor auth.',
        iconColorHex: '#1E60FF',
        iconKey: 'lock',
      ),
      ResetMethodModel(
        id: 'reset_gauth',
        type: 'googleAuth',
        title: 'Send via Google Auth',
        description: 'Reset your password with Google Authenticator.',
        iconColorHex: '#8A2BE2',
        iconKey: 'gauth',
      ),
    ];
  }

  Future<Map<String, dynamic>> requestPasswordReset({
    required String methodId,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return {
      'email': email,
      'sentAt': DateTime.now().toIso8601String(),
      'canResend': true,
      'methodId': methodId,
    };
  }
}
