import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const BuscaCepApp());
}

class BuscaCepApp extends StatelessWidget {
  const BuscaCepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busca CEP',
      home: const BuscaCepPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BuscaCepPage extends StatefulWidget {
  const BuscaCepPage({super.key});

  @override
  State<BuscaCepPage> createState() => _BuscaCepPageState();
}

class _BuscaCepPageState extends State<BuscaCepPage> {
  final TextEditingController _cepController = TextEditingController();
  String? _logradouro;
  String? _cidade;
  String? _erro;

  Future<void> _buscarCep() async {
    final cep = _cepController.text.trim();

    if (cep.isEmpty || cep.length != 8) {
      setState(() {
        _erro = 'Digite um CEP válido de 8 dígitos';
        _logradouro = null;
        _cidade = null;
      });
      return;
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('erro')) {
          setState(() {
            _erro = 'CEP não encontrado';
            _logradouro = null;
            _cidade = null;
          });
        } else {
          setState(() {
            _logradouro = data['logradouro'];
            _cidade = data['localidade'];
            _erro = null;
          });
        }
      } else {
        setState(() {
          _erro = 'Erro ao buscar o CEP';
          _logradouro = null;
          _cidade = null;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro de conexão';
        _logradouro = null;
        _cidade = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Busca CEP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _buscarCep,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            if (_erro != null)
              Text(
                _erro!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (_cidade != null && _logradouro != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cidade: $_cidade', style: const TextStyle(fontSize: 18)),
                  Text('Logradouro: $_logradouro', style: const TextStyle(fontSize: 18)),
                ],
              )
          ],
        ),
      ),
    );
  }
}
