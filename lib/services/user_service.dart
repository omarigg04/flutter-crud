import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  // final String baseUrl = 'http://192.168.1.117:3000'; // Para emulador Android
  // final String baseUrl = 'http://localhost:3000'; // Para emulador iOS o navegador

  //para usar en mi deploy de backend en render:
  final String baseUrl = 'https://nestjs-crud-7t8x.onrender.com'; // Cambia por tu URL real


  // Si usas celular físico, cambia a: 'http://192.168.X.X:3000'

  // Metodo para obtener la lista de usuarios
  // Retorna una lista de objetos User
  // Utiliza Future<List<User>> para manejar la carga asíncrona
  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios/all'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para crear un nuevo usuario
  // Recibe el nombre, edad y usuario del nuevo usuario
  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios'), // Cambia por tu URL real
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear usuario: ${response.statusCode}');
    }
  }

  // Método para eliminar un usuario por ID
  // Recibe el ID del usuario a eliminar
  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/usuarios/$id'));

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  // Método para actualizar un usuario
  // Recibe un objeto User con los datos actualizados
  // Asegúrate de que el ID del usuario esté incluido en el objeto User
  Future<void> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }
}
