/// Representa os dados de um usuário usados pela interface e pelo banco.
class User {
  // O id é nulo antes da inserção; o SQLite o gera ao salvar o registro.
  final int? id;
  final String name;
  final String email;

  User({
    this.id,
    required this.name,
    required this.email,
  });

  /// Converte o objeto em pares coluna/valor aceitos pelas operações SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  /// Reconstrói um usuário a partir das colunas retornadas por uma consulta.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  /// Cria outra instância, mantendo os valores atuais dos campos não informados.
  User copyWith({int? id, String? name, String? email}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}