class User {
  final int id;
  final String user;
  final String nombre;
  final int edad;

  User({
    required this.id,
    required this.user,
    required this.nombre,
    required this.edad,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      user: json['user'],
      nombre: json['nombre'],
      edad: json['edad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user': user, 'nombre': nombre, 'edad': edad};
  }
}
