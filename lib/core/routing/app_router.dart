import 'package:go_router/go_router.dart';
import 'package:jetroquimica/core/routing/routes.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:jetroquimica/features/auth/view/login_screen.dart';
import 'package:jetroquimica/features/auth/view_model/login_view_model.dart';
import 'package:jetroquimica/features/user/view/user_list_screen.dart';
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
          return ChangeNotifierProvider<LoginViewModel>(
            create: (ctx) =>
                LoginViewModel(authRepository: ctx.read<AuthRepository>()),
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.userList,
        builder: (context, state) => const UserListScreen(),
      ),
    ],
  );
}
