import 'package:provider/single_child_widget.dart';

/// Providers de escopo de feature para o módulo de autenticação.
///
/// O `LoginViewModel` é registrado no `GoRoute.builder` porque pertence a uma
/// única rota (escopo mais estreito). Esta função existe para acomodar
/// ViewModels/serviços de auth compartilhados entre várias rotas no futuro.
List<SingleChildWidget> authProviders() => const <SingleChildWidget>[];
