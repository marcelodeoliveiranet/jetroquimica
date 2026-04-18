import 'package:jetroquimica/core/exceptions/app_exception.dart';
import 'package:jetroquimica/core/result/result.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:jetroquimica/data/services/auth/auth_service.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  bool _isLoggedIn = false;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  Future<Result<void>> login(Credentials credentials) async {
    try {
      await _authService.signIn(credentials);
      _isLoggedIn = true;
      notifyListeners();
      return Result.ok(null);
    } on AppException catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }
}
