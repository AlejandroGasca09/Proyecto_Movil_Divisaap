import 'package:flutter/material.dart';
import 'package:wallet_divisas/pantallas/login.dart';
import 'navegador.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(
            255, 0, 0, 1.0)),
        useMaterial3: true,
      ),
      home: const Login(title: "Iniciar Sesión"),
    );
  }
}