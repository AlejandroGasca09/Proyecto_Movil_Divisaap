import 'package:flutter/material.dart';
import 'package:wallet_divisas/widget/Transf.dart';

class Transferencia extends StatefulWidget {
  const Transferencia({super.key});

  @override
  State<Transferencia> createState() => _TransferenciaState();
}

class _TransferenciaState extends State<Transferencia> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();

  //indica si la transferencia esta en preceso
  bool _Carga = false;

  //hace la ransferencia validando los datos correctos
  void _hacerTransferencia() async {
    FocusScope.of(context).unfocus();

    //obtine el correo y lo valida a
    final correoDestino = _correoController.text.trim();

    //òbtiene y valida el correo al que va
    if (correoDestino.isEmpty || !correoDestino.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo válido')),
      );
      return;
    }

    //obtiene y valida que sea un moto correcto
    double? monto;
    try {
      monto = double.parse(_montoController.text.replaceAll(',', '.'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }

    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto debe ser mayor a cero')),
      );
      return;
    }

    //camia el estado mientras hace la transfer
    setState(() => _Carga = true);

    try {
      await transferirSaldo(correoDestino: correoDestino, monto: monto);

      //si se hizo la transferencia limpia los campos y si no muesrtra error
      //depurando el error de firebase y solo mostrando lo que va despues del 'Exception' del error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transferencia realizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _correoController.clear();
        _montoController.clear();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.split('Exception:').last.trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      //regresa al estado inicial
      if (mounted) {
        setState(() => _Carga = false);
      }
    }
  }

  @override
  //libera los controladores de la memoria
  void dispose() {
    _correoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencia'),
        centerTitle: true,
      ),

      //campos de correo y monto
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(
                labelText: 'Correo del destinatario',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto a transferir',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _hacerTransferencia(),
            ),
            const SizedBox(height: 24),

            //boton de la transferencia
            SizedBox(
              height: 50,
              child: _Carga
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _hacerTransferencia,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Transferir',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}