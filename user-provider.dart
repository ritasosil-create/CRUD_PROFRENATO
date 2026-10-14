import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

/// Mantém os usuários em memória e avisa a interface quando os dados mudam.
class UserProvider with ChangeNotifier {
  // A lista atual é usada pela tela; o indicador controla o estado de espera.
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters expõem o estado sem permitir que outras classes alterem os campos.
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Busca os registros salvos e notifica a interface antes e depois da busca.
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // A camada de banco converte as linhas SQLite em objetos User.
      _users = await DatabaseHelper.instance.getUsers();
    } catch (error, stackTrace) {
      debugPrint('Não foi possível carregar os usuários: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage =
          'Não foi possível carregar os usuários. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria um usuário, grava-o e atualiza a lista exibida.
  Future<void> addUser(String name, String email) async {
    final newUser = User(name: name, email: email);
    await DatabaseHelper.instance.insertUser(newUser);
    await loadUsers();
  }

  /// Salva as alterações de um usuário existente e recarrega a lista.
  Future<void> updateUser(User user) async {
    await DatabaseHelper.instance.updateUser(user);
    await loadUsers();
  }

  /// Remove o usuário pelo identificador e atualiza a lista.
  Future<void> deleteUser(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    await loadUsers();
  }
}