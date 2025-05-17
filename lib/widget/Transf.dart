import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//funcion que para realizar las transferecias
Future<void> transferirSaldo({
  required String correoDestino,
  required double monto,
}) async {
  //obtine el uid del usuario de la cuenta actual
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final usuarios = FirebaseFirestore.instance.collection('usuarios');

  try {
    //Verificara que el correo destino exista en la firestore
    final querySnapshot = await usuarios.where('email', isEqualTo: correoDestino).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("Usuario con ese correo no existe");
    }

    //obtine el id del usuario destio de la base de datos
    final docDestinoId = querySnapshot.docs.first.id;

    //no se pueden transferir a si mismos
    if (docDestinoId == uid) {
      throw Exception("No puedes transferir a tu propia cuenta");
    }

    //transaccion de firebase, asegura la integridad en caso de error
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRemitenteRef = usuarios.doc(uid);
      final docDestinoRef = usuarios.doc(docDestinoId);

      //Se obtienen los 2 documentos de quien envia y recibe
      final docRemitenteSnap = await transaction.get(docRemitenteRef);
      final docDestinoSnap = await transaction.get(docDestinoRef);

      //verifica que ambas usuarios exista
      if (!docRemitenteSnap.exists) {
        throw Exception("Tu perfil de usuario no existe");
      }

      if (!docDestinoSnap.exists) {
        throw Exception("El perfil del destinatario no existe");
      }

      //convierte los valores a double para evitar problemas de tipo de datos
      final double saldoRemitente = (docRemitenteSnap.data()?['saldo'] ?? 0).toDouble();
      final double saldoDestino = (docDestinoSnap.data()?['saldo'] ?? 0).toDouble();

      if (saldoRemitente < monto) {
        throw Exception("Saldo insuficiente");
      }

      // Se actualizan los nuevos saldos en firestore
      transaction.update(docRemitenteRef, {
        'saldo': saldoRemitente - monto,
      });

      transaction.update(docDestinoRef, {
        'saldo': saldoDestino + monto,
      });

      //registra las transferencias pal historial
      final transferenciasRef = FirebaseFirestore.instance.collection('transferencias').doc();
      transaction.set(transferenciasRef, {
        'de': uid,
        'para': docDestinoId,
        'correoPara': correoDestino,
        'monto': monto,
        'fecha': FieldValue.serverTimestamp(),
      });
    });

    print("Transferencia exitosa");
  } catch (e) {
    print("Error al transferir: $e");
    throw Exception("Error al transferir: $e");
  }
}