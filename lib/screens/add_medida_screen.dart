import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddMedidaScreen extends StatefulWidget {
  final int usuarioId;

  AddMedidaScreen({required this.usuarioId});

  @override
  _AddMedidaScreenState createState() => _AddMedidaScreenState();
}

class _AddMedidaScreenState extends State<AddMedidaScreen> {
  final _formKey = GlobalKey<FormState>();
  String peso = '';
  String cintura = '';
  String quadril = '';

  void _salvarMedida() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/cadastrar_medida'),
      body: {
        'usuario_id': widget.usuarioId.toString(),
        'peso': peso,
        'cintura': cintura,
        'quadril': quadril,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar medida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Medida')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Informe o peso' : null,
                onChanged: (value) => peso = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cintura (cm)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Informe a cintura' : null,
                onChanged: (value) => cintura = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quadril (cm)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Informe o quadril' : null,
                onChanged: (value) => quadril = value,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarMedida,
                child: Text('Salvar Medida'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
