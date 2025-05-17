import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Banco extends StatefulWidget {
  const Banco({super.key, required this.title});
  final String title;

  @override
  State<Banco> createState() => _BancoState();
}

class _BancoState extends State<Banco> {
  double saldo = 0.0;
  String tipo = '';
  final TextEditingController _cantidadRetiroController = TextEditingController();
  final TextEditingController _cantidadDepositoController = TextEditingController();
  double? cantidadRetirada;
  double? cantidadDepositada;

  //maneja la carga
  bool _Carga = true;

  @override
  void initState() {
    super.initState();
    _cargarSaldoDesdeFirestore();
  }

  //obetiene el saldo del firestore
  Future<void> _cargarSaldoDesdeFirestore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

    if (doc.exists && doc.data()!.containsKey('saldo')) {
      setState(() {
        saldo = (doc.data()!['saldo'] as num).toDouble();
        tipo = (doc.data()!['tipo'] as String);
        _Carga = false;
      });
    } else {
      //si no encuentra solo inicializa el interfaz
      setState(() {
        saldo = 0.0;
        _Carga = false;
      });
    }
  }

  //hace preacticamente las mismas acciones que depositarSaldo
  Future<void> retirarSaldo() async {
    final cantidad = double.tryParse(_cantidadRetiroController.text);

    //valida que los la cantidad sea correcta, que no sea 0
    //y no puedes retirar mas de lo que tienes
    if (cantidad == null || cantidad <= 0 || cantidad > saldo) {
      setState(() {
        cantidadRetirada = null;
      });
      return;
    }

    //obtiene el uid y la referencia al documento en la base de datos
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final usuario = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    //se hace un transaccion para actualizar el saldo
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(usuario);
      final saldoActual = (snapshot.get('saldo') as num).toDouble();

      if (cantidad > saldoActual) {
        throw Exception('Saldo insuficiente');
      }

      transaction.update(usuario, {'saldo': saldoActual - cantidad});
    });

    //se actualiza el nuevo saldo en la interfaz
    setState(() {
      saldo -= cantidad;
      cantidadRetirada = cantidad;
      _cantidadRetiroController.clear();
    });
  }

  //a exepcion del if todo lo demas es practicamente lo mismo de retirar saldo
  Future<void> depositarSaldo() async {
    //convierte los valores a double y despues los valida que sea mayor a 0
    final cantidad = double.tryParse(_cantidadDepositoController.text);
    if (cantidad == null || cantidad <= 0) {
      return;
    }

    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final usuario = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(usuario);
      final saldoActual = (snapshot.get('saldo') as num).toDouble();

      transaction.update(usuario, {'saldo': saldoActual + cantidad});
    });

    setState(() {
      saldo += cantidad;
      cantidadDepositada = cantidad;
      _cantidadDepositoController.clear();
    });
  }

  @override
  //los libera de la memoria
  void dispose() {
    _cantidadRetiroController.dispose();
    _cantidadDepositoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_Carga) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              //Mostrar saldo actual
              Text(
                'Saldo actual: \$${saldo.toString()} $tipo',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              //Campo para retiro
              TextField(
                controller: _cantidadRetiroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a retirar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: retirarSaldo,
                child: const Text('Retirar'),
              ),

              const SizedBox(height: 12),

              if (cantidadRetirada != null)
                Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    Text(
                      'Retirado: \$${cantidadRetirada!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                )
              else
                const Text(
                  'Cantidad no válida o insuficiente.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),

              const SizedBox(height: 24),

              //Campo para depósito
              TextField(
                controller: _cantidadDepositoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a depositar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: depositarSaldo,
                child: const Text('Depositar'),
              ),

              const SizedBox(height: 12),

              if (cantidadDepositada != null)
                Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    Text(
                      'Depositado: \$${cantidadDepositada!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}