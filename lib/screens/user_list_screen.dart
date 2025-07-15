import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'create_user.dart'; // Importar la nueva pantalla

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> futureUsers;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    futureUsers = userService.fetchUsers();
  }

  void _refreshUsers() {
    setState(() {
      futureUsers = userService.fetchUsers();
    });
  }

  Future<void> _navigateToCreateUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateUserScreen()),
    );

    if (result == true) {
      _refreshUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshUsers();
          // Esperamos a que se complete la actualización
          await futureUsers;
        },
        child: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshUsers,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final usuarios = snapshot.data ?? [];

            if (usuarios.isEmpty) {
              return const Center(child: Text('No hay usuarios disponibles'));
            }

            return SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Esto es importante
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Edad')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: usuarios.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(Text(user.user)),
                        DataCell(Text(user.nombre)),
                        DataCell(Text(user.edad.toString())),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Editar ${user.nombre}'),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar'),
                                      content: Text(
                                        '¿Eliminar a ${user.nombre}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await userService.deleteUser(user.id);
                                      _refreshUsers();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Usuario eliminado'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
