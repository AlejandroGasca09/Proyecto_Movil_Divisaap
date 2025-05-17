import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Divisa extends StatefulWidget {
  const Divisa({super.key, required this.title});
  final String title;

  @override
  State<Divisa> createState() => _DivisaState();
}

class _DivisaState extends State<Divisa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const convertidor(),
    );
  }
}

//conversion de divisas
class convertidor extends StatefulWidget {
  const convertidor({super.key});

  @override
  _convertidorState createState() => _convertidorState();
}

//todos los elementos de la pantalla
class _convertidorState extends State<convertidor> {
  Currency? monedaOrigen;
  Currency? monedaDestino;
  double? resultado;
  double saldoActual = 0.0;
  String tipoMoneda = '';
  final TextEditingController _montoController = TextEditingController();

  //tasas de cambio
  final Map<String, double> tasas = {
    'USD_EUR': 0.91, 'EUR_USD': 1.10, 'USD_JPY': 154.30, 'JPY_USD': 0.0065,
    'USD_GBP': 0.80, 'GBP_USD': 1.25, 'EUR_JPY': 170.20, 'JPY_EUR': 0.0059,
    'USD_AUD': 1.52, 'AUD_USD': 0.66, 'USD_CAD': 1.36, 'CAD_USD': 0.74,
    'USD_HKD': 7.83, 'HKD_USD': 0.13, 'USD_CHF': 0.91, 'CHF_USD': 1.10,
    'USD_MXN': 21.80, 'MXN_USD': 0.059, 'EUR_MXN': 18.40, 'MXN_EUR': 0.054,
    'EUR_GBP': 0.88, 'GBP_EUR': 1.14, 'EUR_AUD': 1.67, 'AUD_EUR': 0.60,
    'EUR_CAD': 1.49, 'CAD_EUR': 0.67, 'EUR_HKD': 8.55, 'HKD_EUR': 0.12,
    'EUR_CHF': 0.98, 'CHF_EUR': 1.02, 'EUR_KRW': 1500.00, 'KRW_EUR': 0.00066,
    'EUR_PLN': 4.30, 'PLN_EUR': 0.23,
  };

  @override
  void initState() {
    super.initState();
    obtenerSaldoActual();
  }

  //obteniene el salde del firestore
  Future<void> obtenerSaldoActual() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          saldoActual = (data['saldo'] as num).toDouble();
          tipoMoneda = data['tipo'] ?? '';
          _montoController.text = saldoActual.toString();
        });
      }
    }
  }

  //convierte el saldo en la divisa de tu eleccion
  void convertir() async {
    if (monedaOrigen == null || monedaDestino == null || _montoController.text.isEmpty) return;

    double monto = double.tryParse(_montoController.text) ?? 0;

    //El moto deve ser igual al saldo actual
    if (monto > saldoActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes convertir más que tu saldo actual')),
      );
      return;
    } else if (monto < saldoActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes convertir el total de tu saldo')),
      );
      return;
    }

    //calcula la conversion
    String clave = '${monedaOrigen!.code}_${monedaDestino!.code}';
    if (tasas.containsKey(clave)) {
      resultado = monto * tasas[clave]!;
    } else {
      resultado = monto;
    }

    //actializa el saldo
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'saldo': resultado,
        'tipo': monedaDestino!.code,
      });

      setState(() {
        saldoActual = resultado!;
        tipoMoneda = monedaDestino!.code;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversión realizada con éxito')),
      );
    }
  }

  //las monedas a elegir gracias a la dependencia currency_picker
  void seleccionarMoneda(bool esOrigen) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      currencyFilter: <String>[
        'EUR', 'GBP', 'USD', 'AUD', 'CAD', 'JPY', 'HKD',
        'CHF', 'MXN', 'KRW', 'PLN'
      ],
      onSelect: (Currency currency) {
        setState(() {
          if (esOrigen) {
            monedaOrigen = currency;
          } else {
            monedaDestino = currency;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Saldo actual: \$${saldoActual.toString()} ${tipoMoneda.toUpperCase()}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _montoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto a convertir',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => seleccionarMoneda(true),
                  child: Text(monedaOrigen == null
                      ? 'Moneda Origen'
                      : '${monedaOrigen!.flag} ${monedaOrigen!.code}'),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.swap_horiz),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => seleccionarMoneda(false),
                  child: Text(monedaDestino == null
                      ? 'Moneda Destino'
                      : '${monedaDestino!.flag} ${monedaDestino!.code}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: convertir,
            child: const Text('Convertir'),
          ),
          const SizedBox(height: 20),
          if (resultado != null)
            Text(
              'Resultado: ${resultado!.toStringAsFixed(2)} ${monedaDestino?.code ?? ''}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}