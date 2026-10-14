import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../Providers/user-provider.dart';

/// Formulário reutilizado para cadastrar um usuário ou editar um existente.
class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  // A chave permite validar todos os campos do formulário de uma só vez.
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isSaving = false;

  // A presença de um usuário indica edição; sua ausência indica cadastro.
  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    // Preenche os campos ao editar e deixa-os vazios ao cadastrar.
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    // Libera os controladores quando a tela deixa de existir.
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Valida os campos, envia os dados ao Provider e retorna à tela anterior.
  Future<void> _saveForm() async {
    // Só continua quando todos os validadores dos campos aprovarem os dados.
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final provider = Provider.of<UserProvider>(context, listen: false);

      setState(() => _isSaving = true);
      try {
        if (isEditing) {
          // Mantém o id original e troca apenas nome e e-mail.
          final updatedUser = widget.user!.copyWith(name: name, email: email);
          await provider.updateUser(updatedUser);
        } else {
          // No cadastro, o banco atribuirá o id automaticamente.
          await provider.addUser(name, email);
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error, stackTrace) {
        debugPrint('Não foi possível salvar o usuário: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível salvar. Tente novamente.'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar usuário' : 'Novo usuário'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      isEditing
                          ? Icons.manage_accounts
                          : Icons.person_add_alt_1,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEditing ? 'Atualize os dados' : 'Vamos começar',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEditing ? 'Altere as informações do usuário abaixo.' : 'Preencha os campos para adicionar alguém à equipe.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        hintText: 'Ex.: Maria Silva',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      // Impede salvar o formulário sem um nome.
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'nome@exemplo.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      // Exige e-mail não vazio com ao menos o caractere @.
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o e-mail';
                        }
                        if (!value.contains('@')) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveForm,
                        icon: Icon(
                          _isSaving
                              ? Icons.hourglass_top
                              : isEditing
                              ? Icons.check
                              : Icons.save_outlined,
                        ),
                        label: Text(
                          _isSaving
                              ? 'Salvando...'
                              : isEditing
                              ? 'Salvar alterações'
                              : 'Salvar usuário',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
