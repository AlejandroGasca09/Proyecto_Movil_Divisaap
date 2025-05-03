import 'package:flutter/material.dart';
import 'package:wallet_divisas/pantallas/registro.dart';
import 'package:wallet_divisas/pantallas/banquito.dart';
import 'package:wallet_divisas/pantallas/divisa.dart';
import 'package:wallet_divisas/pantallas/inicioDiv.dart';
import 'package:wallet_divisas/pantallas/ubicacion.dart';

class Navegador extends StatefulWidget{
  const Navegador({super.key});
  @override
  State<Navegador> createState() => _NavegadorState();

}
class _NavegadorState extends State<Navegador>{
  Widget? _cuerpo;
  List<Widget> _pantallas = [];
  int _p=0;

  void _cambiaPantalla(int v){
    setState(() {
      _p = v;
      _cuerpo = _pantallas[_p];
    });
  }


  @override
  void initState(){
    super.initState();
    _pantallas.add(const Inicio(title: "wallet-dio"));
    _pantallas.add(const Banco(title: "Calcula"));
    _pantallas.add(const Divisa(title: "Persistencia de datos"));
    //_pantallas.add(const Ubicacion(title: "Hola a todos!!!!"));
    _cuerpo = _pantallas[_p];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cuerpo,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _p,
        onTap: (value) => _cambiaPantalla(value),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label: "Inicio", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Divisa", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Banco", icon: Icon(Icons.handshake_outlined)),
          BottomNavigationBarItem(label: "Principal", icon: Icon(Icons.accessibility_sharp)),
        ],
      )
    );
  }
}