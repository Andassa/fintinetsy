/// Empty remote datasource stub — swap for Dio/http later.
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  });

  Future<List<Map<String, dynamic>>> getResetMethods();

  Future<Map<String, dynamic>> requestPasswordReset({
    required String methodId,
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError('Wire REST /auth/sign-in here');
  }

  @override
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) {
    throw UnimplementedError('Wire REST /auth/sign-up here');
  }

  @override
  Future<List<Map<String, dynamic>>> getResetMethods() {
    throw UnimplementedError('Wire REST /auth/reset-methods here');
  }

  @override
  Future<Map<String, dynamic>> requestPasswordReset({
    required String methodId,
    required String email,
  }) {
    throw UnimplementedError('Wire REST /auth/password-reset here');
  }
}
