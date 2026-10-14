import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/user-provider.dart';
import '../models/user_model.dart';
import 'user_form_screen.dart';

/// Mostra os usuários cadastrados e oferece ações para criar, editar e excluir.
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Captura o Provider antes de adiar a leitura para depois da construção.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Future.microtask(userProvider.loadUsers);
  }

  /// Pede confirmação antes de remover um usuário da base de dados.
  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        title: const Text('Excluir usuário?'),
        content: Text('O cadastro de $name será removido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Solicita a exclusão ao estado compartilhado e fecha a confirmação.
              Provider.of<UserProvider>(context, listen: false).deleteUser(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.people_alt_outlined),
            SizedBox(width: 12),
            Text('Usuários'),
          ],
        ),
      ),
      // Consumer reconstrói o conteúdo quando a lista ou o estado de carga muda.
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          // Enquanto o banco responde, apresenta um indicador de progresso.
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => provider.loadUsers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Uma lista vazia significa que ainda não há usuários cadastrados.
          if (provider.users.isEmpty) {
            return _EmptyUsersState(onAddUser: () => _openUserForm(context));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sua equipe',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gerencie os cadastros de usuários.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '${provider.users.length} '
                        '${provider.users.length == 1 ? 'usuário' : 'usuários'}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: provider.users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    // Cada cartão apresenta os dados e ações de um usuário.
                    final user = provider.users[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(user.email),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar usuário',
                              icon: const Icon(Icons.edit_outlined),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () =>
                                  _openUserForm(context, user: user),
                            ),
                            IconButton(
                              tooltip: 'Excluir usuário',
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red.shade700,
                              onPressed: () =>
                                  _confirmDelete(context, user.id!, user.name),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openUserForm(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo usuário'),
      ),
    );
  }

  void _openUserForm(BuildContext context, {User? user}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
    );
  }
}

class _EmptyUsersState extends StatelessWidget {
  const _EmptyUsersState({required this.onAddUser});

  final VoidCallback onAddUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: const Icon(Icons.people_outline, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum usuário por aqui',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre o primeiro usuário para começar a organizar sua equipe.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddUser,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Cadastrar usuário'),
            ),
          ],
        ),
      ),
    );
  }
}
