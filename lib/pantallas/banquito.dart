import 'package:flutter/material.dart';

class Banco extends StatefulWidget {
  const Banco({super.key, required this.title});
  final String title;

  @override
  State<Banco> createState() => _BancoState();
}

class _BancoState extends State<Banco> {
  double saldo = 10000;
  final TextEditingController _cantidadRetiroController = TextEditingController();
  final TextEditingController _cantidadDepositoController = TextEditingController();
  double? cantidadRetirada;
  double? cantidadDepositada;

  @override
  void dispose() {
    _cantidadRetiroController.dispose(); // Limpia el controlador cuando el widget se elimina
    super.dispose();
  }

  void retirarSaldo() {
    setState(() {
      final cantidad = double.tryParse(_cantidadRetiroController.text); // Convierte el texto a double
      if (cantidad != null && cantidad <= saldo) {
        saldo -= cantidad;
        cantidadRetirada = cantidad;
        _cantidadRetiroController.clear();
      } else {
        cantidadRetirada = null; // Manejo de error
      }
    });
  }

  void depositarSaldo(){
    setState(() {
      final cantidad = double.tryParse(_cantidadDepositoController.text);
      if(cantidad != null){
        saldo += cantidad;
        cantidadDepositada = cantidad;
        _cantidadDepositoController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Muestra el saldo actual
              Text(
                'Saldo actual: \$${saldo.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Campo para ingresar la cantidad a retirar
              TextField(
                controller: _cantidadRetiroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ingrese la cantidad a retirar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Botón para retirar dinero
              ElevatedButton(
                onPressed: retirarSaldo,
                child: const Text('Retirar'),
              ),

              const SizedBox(height: 20),

              // Muestra la cantidad retirada, si es válida
              if (cantidadRetirada != null)
                Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Cantidad retirada con exito: \$${cantidadRetirada!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                )
              else
                Column(
                  children: const [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Por favor ingrese una cantidad válida o menor al saldo disponible.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Campo para ingresar la cantidad a depositar
              TextField(
                controller: _cantidadDepositoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ingrese la cantidad a Depositar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Botón para retirar dinero
              ElevatedButton(
                onPressed: depositarSaldo,
                child: const Text('Depositar'),
              ),

              const SizedBox(height: 20),

              if (cantidadDepositada != null)...[
                Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Depósito exitoso',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              Text(
                'Cantidad depositada: \$${cantidadDepositada!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
            ]
          ),
        ),
      ),
    );
  }
}