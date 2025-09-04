import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/todos/provider/todo_provider.dart';
import 'core/navigation/auth_wrapper.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo Reminder App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
