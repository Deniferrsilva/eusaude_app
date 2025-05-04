import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class AddAnotacaoScreen extends StatefulWidget {
  final int usuarioId;

  AddAnotacaoScreen({required this.usuarioId});

  @override
  _AddAnotacaoScreenState createState() => _AddAnotacaoScreenState();
}

class _AddAnotacaoScreenState extends State<AddAnotacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  String texto = '';
  XFile? fotoFile;

  Future<void> _tirarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto != null) {
      setState(() {
        fotoFile = foto;
      });
    }
  }

  void _salvarAnotacao() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha o texto da anotação!')));
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8000/cadastrar_anotacao'));
    request.fields['usuario_id'] = widget.usuarioId.toString();
    request.fields['texto'] = texto;

    if (fotoFile != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoFile!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar anotação.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Anotação')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Texto da Anotação'),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Digite algo...' : null,
                onChanged: (value) => texto = value,
              ),
              SizedBox(height: 20),
              fotoFile != null
                  ? Image.file(File(fotoFile!.path), height: 200)
                  : Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(child: Text('Nenhuma foto selecionada')),
                    ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _tirarFoto,
                icon: Icon(Icons.camera_alt),
                label: Text('Tirar Foto'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarAnotacao,
                child: Text('Salvar Anotação'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
