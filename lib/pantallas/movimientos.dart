import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Movimientos extends StatefulWidget {
  const Movimientos({super.key});

  @override
  State<Movimientos> createState() => _MovimientosState();
}

class _MovimientosState extends State<Movimientos> with SingleTickerProviderStateMixin {
  //controla las pestannas enviardos y recibidos y el otro obtiene el uid
  late TabController _tabController;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  //libera el controlador tab de la memoria
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Enviados'),
            Tab(text: 'Recibidos'),
          ],
        ),
      ),
      //pestañas de las transferencias
      body: TabBarView(
        controller: _tabController,
        children: [
          //enviadas
          _buildTransferencias(enviadas: true),

          //recibidas
          _buildTransferencias(enviadas: false),
        ],
      ),
    );
  }

  //construccion de la lista de los mivimientos de las transferencias en base a firebase
  Widget _buildTransferencias({required bool enviadas}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transferencias')
          .where(enviadas ? 'de' : 'para', isEqualTo: uid)
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar el historial: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No hay transferencias ${enviadas ? 'enviadas' : 'recibidas'}'),
          );
        }

        final transferencias = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transferencias.length,
          itemBuilder: (context, index) {
            final doc = transferencias[index].data() as Map<String, dynamic>;

            //que campos va a mostrar si son enviadas o recibidas
            final String contactoLabel = enviadas ? 'Para: ' : 'De: ';
            final String contactoId = enviadas ? doc['correoPara'] ?? 'Desconocido' : doc['de'] ?? 'Desconocido';
            final double monto = (doc['monto'] ?? 0).toDouble();

            //maneja el formato de las fechas con la dependencia intl
            final Timestamp? fechaTimestamp = doc['fecha'] as Timestamp?;
            final String fechaFormateada = fechaTimestamp != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(fechaTimestamp.toDate())
                : 'Pendiente';

            //Obtiene el correo si solo tenemos el UID, intentara ontener el correo
            if (!enviadas && contactoId != 'Desconocido' && !contactoId.contains('@')) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('usuarios').doc(contactoId).get(),
                builder: (context, userSnapshot) {
                  String correoRemitente = 'Cargando...';

                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                      correoRemitente = userData?['email'] ?? 'Desconocido';
                    } else {
                      correoRemitente = 'Usuario no encontrado';
                    }
                  }

                  return _buildTransferenciaItem(
                    contacto: contactoLabel + correoRemitente,
                    fecha: fechaFormateada,
                    monto: monto,
                    esEnviado: enviadas,
                  );
                },
              );
            }

            return _buildTransferenciaItem(
              contacto: contactoLabel + contactoId,
              fecha: fechaFormateada,
              monto: monto,
              esEnviado: enviadas,
            );
          },
        );
      },
    );
  }

  //se hace un item para la lista de los movimientos
  Widget _buildTransferenciaItem({
    required String contacto,
    required String fecha,
    required double monto,
    required bool esEnviado,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        //la informacion, visualizacion iconos  y si es enviada o recibida
        leading: Icon(
          esEnviado ? Icons.arrow_upward : Icons.arrow_downward,
          color: esEnviado ? Colors.red : Colors.green,
        ),
        title: Text(contacto),
        subtitle: Text(fecha),
        trailing: Text(
          '${esEnviado ? "-" : "+"} \$${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esEnviado ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}