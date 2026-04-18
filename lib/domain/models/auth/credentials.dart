/// Credenciais de autenticação fornecidas pelo usuário na tela de login.
class Credentials {
  const Credentials({required this.email, required this.password});

  final String email;
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Credentials &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => Object.hash(email, password);
}
