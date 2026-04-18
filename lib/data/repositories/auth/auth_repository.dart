import 'package:flutter/foundation.dart';
import 'package:jetroquimica/core/result/result.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';

/// Repositório de autenticação.
///
/// Estende [ChangeNotifier] porque o `go_router` usa esta instância como
/// `refreshListenable` para reagir a mudanças no estado de login e disparar
/// o `redirect` novamente.
abstract class AuthRepository extends ChangeNotifier {
  /// `true` quando há uma sessão ativa.
  bool get isLoggedIn;

  /// Tenta autenticar com [credentials]. Sucesso devolve [Ok];
  /// qualquer falha devolve [Failure] contendo um `AppException`.
  Future<Result<void>> login(Credentials credentials);

  /// Encerra a sessão atual.
  Future<void> logout();
}
