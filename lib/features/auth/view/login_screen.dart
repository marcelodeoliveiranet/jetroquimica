import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jetroquimica/core/result/result.dart';
import 'package:jetroquimica/core/routing/routes.dart';
import 'package:jetroquimica/domain/models/auth/credentials.dart';
import 'package:jetroquimica/features/auth/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LoginViewModel>();
    if (_viewModel != vm) {
      _viewModel?.login.removeListener(_onLoginResult);
      _viewModel = vm;
      _viewModel!.login.addListener(_onLoginResult);
    }
  }

  @override
  void dispose() {
    _viewModel?.login.removeListener(_onLoginResult);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginResult() {
    final command = _viewModel!.login;

    if (command.completed) {
      command.clearResult();
      if (!mounted) return;
      context.go(AppRoutes.userList);
      return;
    }

    if (command.error) {
      final failure = command.result as Failure;
      final message = failure.error.toString();
      command.clearResult();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _submit() {
    _viewModel!.login.execute(
      Credentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: vm.login,
            builder: (context, _) {
              final running = vm.login.running;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    key: const Key('login_email_field'),
                    controller: _emailController,
                    enabled: !running,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('login_password_field'),
                    controller: _passwordController,
                    enabled: !running,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      key: const Key('login_submit_button'),
                      onPressed: running ? null : _submit,
                      child: running
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Entrar'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
