import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const UserListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
