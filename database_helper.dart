import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

/// Centraliza a abertura do banco SQLite e as operações de leitura e escrita.
class DatabaseHelper {
  // Uma única instância evita abrir conexões diferentes para cada tela.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // O construtor privado impede que outras classes criem helpers adicionais.
  DatabaseHelper._init();

  /// Devolve a conexão existente ou abre o banco na primeira solicitação.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  /// Monta o caminho do arquivo e configura sua criação na primeira abertura.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Cria a tabela users quando o arquivo do banco ainda não tem esquema.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  /// Insere os campos do usuário e retorna o identificador gerado pelo SQLite.
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  /// Lê os registros mais recentes primeiro e converte cada linha em User.
  Future<List<User>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users', orderBy: 'id DESC');
    return result.map((json) => User.fromMap(json)).toList();
  }

  /// Atualiza somente a linha cujo id corresponde ao usuário recebido.
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Exclui a linha identificada pelo id e retorna quantas linhas foram removidas.
  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fecha a conexão atual do banco.
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}