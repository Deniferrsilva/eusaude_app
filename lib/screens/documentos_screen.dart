import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'add_document_screen.dart';  // ✅ novo import


class DocumentosScreen extends StatefulWidget {
  final int usuarioId;

  DocumentosScreen({required this.usuarioId});

  @override
  _DocumentosScreenState createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen> {
  List documentos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDocumentos();
  }

  void _carregarDocumentos() async {
    final url = Uri.parse('http://10.0.2.2:8000/listar_documentos/${widget.usuarioId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        documentos = data['documentos'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar documentos')),
      );
    }
  }

  Future<void> _abrirDocumento(String caminhoArquivo) async {
    // Corrige o caminho removendo prefixo local
    String relativePath = caminhoArquivo.replaceFirst('uploads/', '');
    String url = 'http://10.0.2.2:8000/uploads/$relativePath';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o arquivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('Meus Documentos'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : documentos.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum documento encontrado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    final doc = documentos[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          child: Icon(Icons.picture_as_pdf, size: 32, color: Theme.of(context).primaryColor),
                        ),
                        title: Text(
                          doc['tipo'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Data: ${doc['data']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.open_in_new, color: Theme.of(context).primaryColor),
                          onPressed: () => _abrirDocumento(doc['caminho_arquivo']),
                        ),
                        onTap: () => _abrirDocumento(doc['caminho_arquivo']),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDocumentScreen(usuarioId: widget.usuarioId),
            ),
          );
          if (result == true) {
            _carregarDocumentos(); // atualiza a lista ao voltar
          }
        },
      ),
    );

  }
}
