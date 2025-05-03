import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key, required this.title});
  final String title;

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _cantidadRetiroController = TextEditingController();
  final TextEditingController _cantidadDepositoController = TextEditingController();
  double? cantidadRetirada;
  double? cantidadDepositada;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _cantidadRetiroController.dispose();
    _cantidadDepositoController.dispose();
    super.dispose();
  }

  Future<void> retirarSaldo(double saldoActual) async {
    final cantidad = double.tryParse(_cantidadRetiroController.text);
    if (cantidad != null && cantidad <= saldoActual) {
      final nuevoSaldo = saldoActual - cantidad;
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'saldo': nuevoSaldo,
      });
      setState(() {
        cantidadRetirada = cantidad;
        _cantidadRetiroController.clear();
      });
    } else {
      setState(() {
        cantidadRetirada = null;
      });
    }
  }

  Future<void> depositarSaldo(double saldoActual) async {
    final cantidad = double.tryParse(_cantidadDepositoController.text);
    if (cantidad != null) {
      final nuevoSaldo = saldoActual + cantidad;
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'saldo': nuevoSaldo,
      });
      setState(() {
        cantidadDepositada = cantidad;
        _cantidadDepositoController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Text('No se encontraron datos del usuario');

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final saldo = data['saldo']?.toDouble() ?? 0.0;
          final nombre = data['nombre'] ?? 'Usuario';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // nombre del usuario logeado
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hola, $nombre',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Saldo que tiene el usuario
                Card(
                  color: Colors.blue.shade50,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo actual:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '\$${saldo.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
