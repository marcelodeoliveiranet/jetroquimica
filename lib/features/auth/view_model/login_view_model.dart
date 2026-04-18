import 'package:flutter/foundation.dart';
import 'package:jetroquimica/core/command/command.dart';
import 'package:jetroquimica/core/result/result.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    login = Command1<void, Credentials>(_login);
  }

  final AuthRepository _authRepository;

  late final Command1<void, Credentials> login;

  Future<Result<void>> _login(Credentials credentials) =>
      _authRepository.login(credentials);

  @override
  void dispose() {
    login.dispose();
    super.dispose();
  }
}
