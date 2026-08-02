import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_reset_methods_usecase.dart';
import '../../features/auth/domain/usecases/request_password_reset_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';

List<SingleChildWidget> buildAppProviders() {
  final authRepository = FakeAuthRepository();

  return [
    Provider<AuthRepository>.value(value: authRepository),
    Provider(create: (_) => SignInUseCase(authRepository)),
    Provider(create: (_) => SignUpUseCase(authRepository)),
    Provider(create: (_) => GetResetMethodsUseCase(authRepository)),
    Provider(create: (_) => RequestPasswordResetUseCase(authRepository)),
  ];
}
