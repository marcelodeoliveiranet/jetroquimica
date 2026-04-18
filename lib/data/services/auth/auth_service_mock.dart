import 'package:jetroquimica/core/exceptions/http_exception.dart';
import 'package:jetroquimica/data/services/auth/auth_service.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';

/// Implementação fake enquanto o backend real não existe.
///
/// Aceita apenas `test@test.com` / `123456`. Qualquer outra combinação lança
/// [UnauthorizedException]. Simula latência de rede com um pequeno delay.
class AuthServiceMock implements AuthService {
  static const _validEmail = 'test@test.com';
  static const _validPassword = '123456';
  static const _latency = Duration(milliseconds: 500);

  @override
  Future<void> signIn(Credentials credentials) async {
    await Future.delayed(_latency);

    if (credentials.email != _validEmail ||
        credentials.password != _validPassword) {
      throw const UnauthorizedException(message: 'Credenciais inválidas');
    }
  }
}
