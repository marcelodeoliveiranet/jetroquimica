import 'package:flutter/material.dart';
import 'package:jetroquimica/core/config/dependencies.dart';
import 'package:jetroquimica/core/routing/app_router.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await getDependencies();
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(authRepository: context.read<AuthRepository>());

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Jetro Química',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}
