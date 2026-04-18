import 'package:flutter/material.dart';

/// Placeholder. Destino da navegação após login bem-sucedido.
/// A feature real de listagem de usuários será implementada em outro PR.
class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: const Center(child: Text('Lista de usuários (em construção)')),
    );
  }
}
