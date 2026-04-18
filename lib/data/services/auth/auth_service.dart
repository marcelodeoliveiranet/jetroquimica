import 'package:jetroquimica/domain/models/auth/credentials.dart';

/// Porta de saída para autenticação. Implementações concretas conversam com o
/// backend (ou mock) e lançam [AppException] em caso de falha. A troca de
/// backend acontece somente trocando a implementação injetada no DI.
abstract class AuthService {
  Future<void> signIn(Credentials credentials);
}
