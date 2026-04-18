import 'package:go_router/go_router.dart';
import 'package:jetroquimica/core/routing/routes.dart';
import 'package:provider/provider.dart';

GoRouter createRouter({required AuthRepository authRepository}) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    refreshListenable: authRepository,

    redirect: (context, state) {
      final isLoggedIn = authRepository.isLoggedIn;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isGoingToLogin) {
        return AppRoutes.login;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => LoginViewmodel(authRepository: authRepository),
              ),
            ],
            child: const AuthLogin(),
          );
        },
      ),
    ],
  );
}
