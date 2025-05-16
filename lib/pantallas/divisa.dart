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

  // Funcion que convierte de moneda a moneda sin API (Aprox)
  void convertir() {
    if (monedaOrigen == null || monedaDestino == null || _montoController.text.isEmpty) return;

    double monto = double.tryParse(_montoController.text) ?? 0;

    Map<String, double> tasas = {
      'USD_EUR': 0.91,
      'EUR_USD': 1.10,
      'USD_JPY': 154.30,
      'JPY_USD': 0.0065,
      'USD_GBP': 0.80,
      'GBP_USD': 1.25,
      'EUR_JPY': 170.20,
      'JPY_EUR': 0.0059,
      'USD_AUD': 1.52,
      'AUD_USD': 0.66,
      'USD_CAD': 1.36,
      'CAD_USD': 0.74,
      'USD_HKD': 7.83,
      'HKD_USD': 0.13,
      'USD_CHF': 0.91,
      'CHF_USD': 1.10,
      'USD_MXN': 21.80,
      'MXN_USD': 0.059,
      'USD_KRW': 1370.00,
      'KRW_USD': 0.00073,
      'USD_PLN': 4.00,
      'PLN_USD': 0.25,
      'EUR_GBP': 0.88,
      'GBP_EUR': 1.14,
      'EUR_AUD': 1.67,
      'AUD_EUR': 0.60,
      'EUR_CAD': 1.49,
      'CAD_EUR': 0.67,
      'EUR_HKD': 8.55,
      'HKD_EUR': 0.12,
      'EUR_CHF': 0.98,
      'CHF_EUR': 1.02,
      'EUR_MXN': 18.40,
      'MXN_EUR': 0.054,
      'EUR_KRW': 1500.00,
      'KRW_EUR': 0.00066,
      'EUR_PLN': 4.30,
      'PLN_EUR': 0.23,
    };

    String clave = '${monedaOrigen!.code}_${monedaDestino!.code}';

    if (tasas.containsKey(clave)) {
      resultado = monto * tasas[clave]!;
    } else {
      resultado = monto;
    }

    setState(() {});
  }

  // Funcion que permite al usuario seleccionar moneda origen y moneda destino
  void seleccionarMoneda(bool esOrigen) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      currencyFilter: <String>['EUR', 'GBP', 'USD', 'AUD', 'CAD', 'JPY', 'HKD', 'CHF','MXN','KRW','PLN'],
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