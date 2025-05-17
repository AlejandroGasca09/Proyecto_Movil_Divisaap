import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet_divisas/pantallas/transfe.dart';
import 'package:wallet_divisas/pantallas/movimientos.dart';
import 'login.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key, required this.title});
  final String title;

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  //obtiene el uid del usuario
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Login(title: "Iniciar Sesión")),
              );
            },
          ),
        ],
      ),
      //los datos del usuario deacuerdo al firebase
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Text('No se encontraron datos del usuario');

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final saldo = data['saldo']?.toDouble() ?? 0.0;
          final nombre = data['nombre'] ?? 'Usuario';
          final tipo = data['tipo'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // nombre del usuario que accedio
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hola, $nombre',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Saldo que tienes cada uuario
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
                          '\$${saldo.toString()} $tipo',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // los botones para la transferencia y el historial de los movimientos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Transferencia()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.compare_arrows),
                          SizedBox(width: 8),
                          Text('Transferencia'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Movimientos()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text('Historial'),
                        ],
                      ),
                    ),
                  ],
                )

              ],
            ),
          );
        },
      ),
    );
  }
}