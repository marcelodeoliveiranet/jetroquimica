import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jetroquimica/core/exceptions/http_exception.dart';
import 'package:jetroquimica/core/result/result.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';
import 'package:jetroquimica/features/auth/view_model/login_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_view_model_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  provideDummy<Result<void>>(Result.ok(null));

  const credentials = Credentials(email: 'test@test.com', password: '123456');

  late MockAuthRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = MockAuthRepository();
    viewModel = LoginViewModel(authRepository: repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('LoginViewModel.login', () {
    test('state starts idle (not running, not completed, not error)', () {
      expect(viewModel.login.running, isFalse);
      expect(viewModel.login.completed, isFalse);
      expect(viewModel.login.error, isFalse);
      expect(viewModel.login.result, isNull);
    });

    test('on success: completed=true, error=false, running=false', () async {
      when(
        repository.login(credentials),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.login.execute(credentials);

      expect(viewModel.login.running, isFalse);
      expect(viewModel.login.completed, isTrue);
      expect(viewModel.login.error, isFalse);
      verify(repository.login(credentials)).called(1);
    });

    test(
      'on failure: error=true, completed=false, carries exception',
      () async {
        const exception = UnauthorizedException(
          message: 'Credenciais inválidas',
        );
        when(
          repository.login(credentials),
        ).thenAnswer((_) async => Result.error(exception));

        await viewModel.login.execute(credentials);

        expect(viewModel.login.running, isFalse);
        expect(viewModel.login.completed, isFalse);
        expect(viewModel.login.error, isTrue);
        final failure = viewModel.login.result as Failure;
        expect(failure.error, same(exception));
      },
    );

    test('re-entrant execute is ignored while running', () async {
      final completer = Completer<Result<void>>();
      when(repository.login(credentials)).thenAnswer((_) => completer.future);

      final first = viewModel.login.execute(credentials);
      // Segunda chamada enquanto a primeira ainda não completou.
      final second = viewModel.login.execute(credentials);

      expect(viewModel.login.running, isTrue);

      completer.complete(Result.ok(null));
      await Future.wait([first, second]);

      verify(repository.login(credentials)).called(1);
      expect(viewModel.login.completed, isTrue);
    });
  });
}
