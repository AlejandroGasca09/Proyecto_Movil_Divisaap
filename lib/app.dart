import 'package:flutter/material.dart';
import 'package:wallet_divisas/pantallas/login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wallet',

      //tema de la aplicacion
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(
            255, 0, 0, 1.0)),
        useMaterial3: true,
      ),

      //es la pantalla con la que inicia la aplicacion
      home: const Login(title: "Iniciar Sesión"),
    );
  }
}