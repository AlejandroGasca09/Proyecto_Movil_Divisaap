/*
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key});

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  String _pais = 'Cargando...';
  String _moneda = '';

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.deniedForever) return;
    }

    final posicion = await Geolocator.getCurrentPosition();
    _obtenerPaisDesdeCoordenadas(posicion.latitude, posicion.longitude);
  }

  Future<void> _obtenerPaisDesdeCoordenadas(double lat, double lon) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
    final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pais = data['address']['country'] ?? 'Desconocido';
      final codigoPais = data['address']['country_code']?.toUpperCase() ?? '';
      final moneda = await _obtenerMonedaDesdePais(codigoPais);

      setState(() {
        _pais = pais;
        _moneda = moneda;
      });
    }
  }

  Future<String> _obtenerMonedaDesdePais(String codigo) async {
    final url = Uri.parse('https://restcountries.com/v3.1/alpha/$codigo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final monedas = data[0]['currencies'];
      if (monedas != null) {
        final clave = monedas.keys.first;
        final nombre = monedas[clave]['name'];
        return '$nombre ($clave)';
      }
    }
    return 'No disponible';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación y Moneda')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('País: $_pais', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Moneda local: $_moneda', style: const TextStyle(fontSize: 18, color: Colors.teal)),
          ],
        ),
      ),
    );
  }
}
 */
