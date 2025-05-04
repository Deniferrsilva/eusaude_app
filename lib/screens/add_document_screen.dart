import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AddDocumentScreen extends StatefulWidget {
  final int usuarioId;

  AddDocumentScreen({required this.usuarioId});

  @override
  _AddDocumentScreenState createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  File? _selectedFile;
  final _tipoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      // Cancelado ou erro
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _tipoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione um arquivo e preencha o tipo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/upload_documento'),
    );
    request.fields['usuario_id'] = widget.usuarioId.toString();
    request.fields['tipo'] = _tipoController.text;
    request.files.add(
      await http.MultipartFile.fromPath('arquivo', _selectedFile!.path,
          filename: path.basename(_selectedFile!.path)),
    );

    var response = await request.send();

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento enviado com sucesso!')),
      );
      Navigator.pop(context, true); // Retorna para atualizar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar documento')),
      );
    }
  }

  @override
  void dispose() {
    _tipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Documento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.attach_file),
              label: Text(_selectedFile != null
                  ? 'Arquivo selecionado: ${path.basename(_selectedFile!.path)}'
                  : 'Selecionar PDF'),
              onPressed: _pickFile,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo do Documento (ex: Exame)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: Icon(Icons.upload),
                    label: Text('Enviar Documento'),
                    onPressed: _uploadFile,
                  ),
          ],
        ),
      ),
    );
  }
}
