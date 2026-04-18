import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jetroquimica/core/exceptions/http_exception.dart';
import 'package:jetroquimica/core/result/result.dart';
import 'package:jetroquimica/core/routing/routes.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';
import 'package:jetroquimica/features/auth/view/login_screen.dart';
import 'package:jetroquimica/features/auth/view_model/login_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  provideDummy<Result<void>>(Result.ok(null));

  late MockAuthRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = MockAuthRepository();
    viewModel = LoginViewModel(authRepository: repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => ChangeNotifierProvider<LoginViewModel>.value(
            value: viewModel,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.userList,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('USER_LIST_PAGE'))),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders email, password and submit', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('tap submit passes trimmed email and raw password to VM', (
    tester,
  ) async {
    when(repository.login(any)).thenAnswer((_) async => Result.ok(null));

    await tester.pumpWidget(buildSubject());
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      '  test@test.com  ',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    verify(
      repository.login(
        const Credentials(email: 'test@test.com', password: '123456'),
      ),
    ).called(1);
  });

  testWidgets('shows spinner and disables fields while running', (
    tester,
  ) async {
    final completer = Completer<Result<void>>();
    when(repository.login(any)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'test@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);

    final emailField = tester.widget<TextField>(
      find.byKey(const Key('login_email_field')),
    );
    final passwordField = tester.widget<TextField>(
      find.byKey(const Key('login_password_field')),
    );
    expect(emailField.enabled, isFalse);
    expect(passwordField.enabled, isFalse);

    completer.complete(Result.ok(null));
    await tester.pumpAndSettle();
  });

  testWidgets('on error shows SnackBar with exception message', (tester) async {
    when(repository.login(any)).thenAnswer(
      (_) async => Result.error(
        const UnauthorizedException(message: 'Credenciais inválidas'),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'wrong@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Credenciais inválidas'), findsOneWidget);
    expect(find.text('USER_LIST_PAGE'), findsNothing);
  });

  testWidgets('on success navigates to userList', (tester) async {
    when(repository.login(any)).thenAnswer((_) async => Result.ok(null));

    await tester.pumpWidget(buildSubject());
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'test@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('USER_LIST_PAGE'), findsOneWidget);
  });
}
