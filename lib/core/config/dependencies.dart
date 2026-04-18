import 'package:jetroquimica/data/repositories/auth/auth_repository.dart';
import 'package:jetroquimica/data/repositories/auth/auth_repository_impl.dart';
import 'package:jetroquimica/data/services/auth/auth_service.dart';
import 'package:jetroquimica/data/services/auth/auth_service_mock.dart';
import 'package:jetroquimica/features/auth/auth_providers.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<SingleChildWidget>> getDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Troca futura de backend: substituir AuthServiceMock() por
  // AuthServiceHttp(dio). Nada além desta linha muda.
  final AuthService authService = AuthServiceMock();
  final AuthRepository authRepository = AuthRepositoryImpl(
    authService: authService,
  );

  return [
    Provider<SharedPreferences>.value(value: sharedPreferences),

    ///Services
    Provider<AuthService>.value(value: authService),

    ///Repositories
    ChangeNotifierProvider<AuthRepository>.value(value: authRepository),

    ///ViewModel
    ...authProviders(),
  ];
}
