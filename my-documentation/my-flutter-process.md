# Guía completa: Crear pantalla de usuario en Flutter

## 📋 Tabla de contenidos
1. [Problema inicial](#problema-inicial)
2. [Solución: Crear nueva pantalla](#solución-crear-nueva-pantalla)
3. [Estructura del proyecto](#estructura-del-proyecto)
4. [Código completo](#código-completo)
5. [Errores comunes y soluciones](#errores-comunes-y-soluciones)
6. [Conceptos clave aprendidos](#conceptos-clave-aprendidos)

## Problema inicial

**Pregunta:** ¿Cómo crear una pantalla nueva para cuando se da click en el botón flotante (+) en una aplicación Flutter que maneja usuarios?

**Contexto:** Tenemos una pantalla `UserListScreen` que muestra una lista de usuarios en un `DataTable`, con un `FloatingActionButton` que inicialmente solo mostraba un `SnackBar` placeholder.

## Solución: Crear nueva pantalla

### 1. Crear la pantalla de creación de usuario

Necesitamos crear un nuevo widget `CreateUserScreen` que contenga:
- Un formulario con validaciones
- Campos para usuario, nombre y edad
- Manejo de estados (loading, error, success)
- Navegación de regreso con resultado

### 2. Modificar la pantalla principal

Actualizar `UserListScreen` para:
- Navegar a la nueva pantalla
- Recibir el resultado de la creación
- Actualizar la lista automáticamente

### 3. Actualizar el servicio

Agregar método `createUser` al `UserService` para realizar la petición HTTP.

## Estructura del proyecto

```
lib/
├── models/
│   └── user.dart
├── services/
│   └── user_service.dart
├── screens/
│   ├── user_list_screen.dart
│   └── create_user_screen.dart (NUEVO)
└── main.dart
```

## Código completo

### 📄 models/user.dart

```dart
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
    return {
      'id': id,
      'user': user,
      'nombre': nombre,
      'edad': edad
    };
  }
}
```

### 📄 screens/create_user_screen.dart

```dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final UserService userService = UserService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _nombreController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear el nuevo usuario
      final User newUser = User(
        id: 0, // El ID será asignado por el servidor
        user: _userController.text.trim(),
        nombre: _nombreController.text.trim(),
        edad: int.parse(_edadController.text.trim()),
      );

      await userService.createUser(newUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Regresar con resultado positivo
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un nombre de usuario';
                          }
                          if (value.trim().length < 3) {
                            return 'El usuario debe tener al menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el nombre';
                          }
                          if (value.trim().length < 2) {
                            return 'El nombre debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _edadController,
                        decoration: const InputDecoration(
                          labelText: 'Edad',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa la edad';
                          }
                          final edad = int.tryParse(value.trim());
                          if (edad == null) {
                            return 'Por favor ingresa un número válido';
                          }
                          if (edad < 1 || edad > 120) {
                            return 'La edad debe estar entre 1 y 120 años';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Crear Usuario',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 📄 screens/user_list_screen.dart (modificado)

```dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'create_user_screen.dart'; // NUEVO IMPORT

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

  // NUEVA FUNCIÓN para navegar a crear usuario
  Future<void> _navigateToCreateUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateUserScreen(),
      ),
    );
    
    // Si se creó un usuario, actualizar la lista
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
      body: FutureBuilder<List<User>>(
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

          return RefreshIndicator(
            onRefresh: () async {
              _refreshUsers();
            },
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Editar ${user.nombre}'),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: Text('¿Eliminar a ${user.nombre}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    await userService.deleteUser(user.id);
                                    _refreshUsers();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Usuario eliminado'),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateUser, // FUNCIÓN MODIFICADA
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 📄 services/user_service.dart (método adicional)

```dart
// Agregar este método a tu clase UserService existente

Future<User> createUser(User user) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users'), // Ajusta la URL según tu API
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(user.toJson()),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return User.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al crear usuario: ${response.statusCode}');
  }
}
```

## Errores comunes y soluciones

### ❌ Error: "The named parameter 'user' is required"

**Problema:** El método `createUser` en el servicio tenía una firma incorrecta.

**Firma incorrecta:**
```dart
Future<void> createUser(User newUser, {
  required String user,
  required String nombre,
  required int edad,
}) {
  // ...
}
```

**Firma correcta:**
```dart
Future<User> createUser(User user) async {
  // ...
}
```

**Explicación:** El método debe recibir únicamente un objeto `User`, no parámetros adicionales. El objeto `User` ya contiene toda la información necesaria.

### ❌ Error: Import no encontrado

**Problema:** No se puede importar `CreateUserScreen`.

**Solución:** Verificar que:
1. El archivo `create_user_screen.dart` esté en la carpeta `screens/`
2. El import sea correcto: `import 'create_user_screen.dart';`
3. La ruta relativa sea correcta según tu estructura de carpetas

## Conceptos clave aprendidos

### 1. **Navegación con resultado**
```dart
// Navegar y esperar resultado
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CreateUserScreen()),
);

// Regresar con resultado
Navigator.pop(context, true);
```

### 2. **Validación de formularios**
```dart
// GlobalKey para el formulario
final _formKey = GlobalKey<FormState>();

// Validar antes de procesar
if (!_formKey.currentState!.validate()) return;

// Validator en TextFormField
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }
  return null;
}
```

### 3. **Manejo de estados asíncronos**
```dart
bool _isLoading = false;

// Activar loading
setState(() {
  _isLoading = true;
});

// Desactivar loading
setState(() {
  _isLoading = false;
});

// UI condicional
child: _isLoading
    ? CircularProgressIndicator()
    : Text('Crear Usuario'),
```

### 4. **Manejo de errores**
```dart
try {
  await userService.createUser(newUser);
  // Éxito
} catch (e) {
  // Error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### 5. **Patrón mounted**
```dart
if (mounted) {
  // Solo ejecutar si el widget sigue montado
  ScaffoldMessenger.of(context).showSnackBar(/* ... */);
}
```

### 6. **Limpieza de recursos**
```dart
@override
void dispose() {
  _userController.dispose();
  _nombreController.dispose();
  _edadController.dispose();
  super.dispose();
}
```

### 7. **Constructores con parámetros nombrados**
```dart
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
}

// Uso
final user = User(
  id: 0,
  user: 'usuario123',
  nombre: 'Juan Pérez',
  edad: 25,
);
```

## 🎯 Flujo completo

1. **Usuario hace clic en (+)** → Se ejecuta `_navigateToCreateUser()`
2. **Navegación** → Se abre `CreateUserScreen`
3. **Usuario llena formulario** → Se validan los campos
4. **Usuario presiona "Crear"** → Se ejecuta `_createUser()`
5. **Creación exitosa** → Se muestra SnackBar y se regresa con `true`
6. **Regreso a lista** → Se detecta `result == true` y se actualiza la lista

## 📚 Recursos adicionales

- [Flutter Navigation](https://docs.flutter.dev/cookbook/navigation)
- [Form Validation](https://docs.flutter.dev/cookbook/forms/validation)
- [HTTP requests](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)

---

*Esta guía cubre la implementación completa de un sistema CRUD básico en Flutter, desde la creación de la interfaz hasta la integración con servicios web.*