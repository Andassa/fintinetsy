import '../entities/reset_method_entity.dart';
import '../repositories/auth_repository.dart';

class GetResetMethodsUseCase {
  const GetResetMethodsUseCase(this._repository);

  final AuthRepository _repository;

  Future<List<ResetMethodEntity>> call() => _repository.getResetMethods();
}
