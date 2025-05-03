import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';

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
      body: CurrencyConverterPage(), // Integra la pantalla principal
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  Currency? monedaOrigen;
  Currency? monedaDestino;
  double? resultado;
  final TextEditingController _montoController = TextEditingController();

  // Tasa de ejemplo: 1 USD = 0.85 EUR
  final double tasaEjemplo = 0.85;

  void convertir() {
    if (monedaOrigen == null || monedaDestino == null || _montoController.text.isEmpty) return;

    double monto = double.tryParse(_montoController.text) ?? 0;

    // Conversión de ejemplo
    if (monedaOrigen!.code == 'USD' && monedaDestino!.code == 'EUR') {
      resultado = monto * tasaEjemplo;
    } else if (monedaOrigen!.code == 'EUR' && monedaDestino!.code == 'USD') {
      resultado = monto / tasaEjemplo;
    } else {
      // Tasa fija 1:1 para el resto por simplicidad
      resultado = monto;
    }

    setState(() {});
  }

  void seleccionarMoneda(bool esOrigen) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
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