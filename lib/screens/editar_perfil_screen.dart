import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditarPerfilScreen extends StatefulWidget {
  final int usuarioId;

  EditarPerfilScreen({required this.usuarioId});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String email = '';
  File? novaFoto;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final url = Uri.parse('http://10.0.2.2:8000/usuario/${widget.usuarioId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nome = data['usuario']['nome'] ?? '';
        email = data['usuario']['email'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados do perfil')),
      );
    }
  }

  void _selecionarFoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => novaFoto = File(result.files.single.path!));
    }
  }

  void _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/atualizar_usuario'),
    );
    request.fields['usuario_id'] = widget.usuarioId.toString();
    request.fields['nome'] = nome;
    request.fields['email'] = email;

    if (novaFoto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto_perfil', novaFoto!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: novaFoto != null ? FileImage(novaFoto!) : null,
                            child: novaFoto == null ? Icon(Icons.person, size: 60) : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _selecionarFoto,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: nome,
                      decoration: InputDecoration(labelText: 'Nome'),
                      validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
                      onChanged: (value) => nome = value,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) => value == null || value.isEmpty ? 'Informe o email' : null,
                      onChanged: (value) => email = value,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _salvarEdicao,
                      child: Text('Salvar Alterações'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
