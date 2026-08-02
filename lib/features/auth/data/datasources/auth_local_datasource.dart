import '../models/reset_method_model.dart';
import '../models/user_model.dart';

/// Local mock data — realistic payloads a REST API would return.
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
      throw Exception("ERROR: Password Don't Match!");
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
        description: 'Seamlessly reset your password via email address.',
        iconColorHex: '#FF7020',
        iconKey: 'email',
      ),
      ResetMethodModel(
        id: 'reset_2fa',
        type: 'twoFactor',
        title: 'Send via 2FA',
        description: 'Seamlessly reset your password via 2 Factors.',
        iconColorHex: '#1E60FF',
        iconKey: 'lock',
      ),
      ResetMethodModel(
        id: 'reset_gauth',
        type: 'googleAuth',
        title: 'Send via Google Auth',
        description: 'Seamlessly reset your password via gAuth.',
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
