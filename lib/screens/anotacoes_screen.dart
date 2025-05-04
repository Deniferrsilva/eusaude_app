import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_anotacao_screen.dart';
import 'visualizar_foto_screen.dart';

class AnotacoesScreen extends StatefulWidget {
  final int usuarioId;

  AnotacoesScreen({required this.usuarioId});

  @override
  _AnotacoesScreenState createState() => _AnotacoesScreenState();
}

class _AnotacoesScreenState extends State<AnotacoesScreen> {
  List anotacoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAnotacoes();
  }

  void _carregarAnotacoes() async {
    final url = Uri.parse('http://10.0.2.2:8000/listar_anotacoes/${widget.usuarioId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        anotacoes = data['anotacoes'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar anotações')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Anotações')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : anotacoes.isEmpty
              ? Center(child: Text('Nenhuma anotação encontrada.'))
              : ListView.builder(
                  itemCount: anotacoes.length,
                  itemBuilder: (context, index) {
                    final anotacao = anotacoes[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(anotacao['texto']),
                        subtitle: Text(anotacao['data']),
                        trailing: anotacao['caminho_foto'] != null
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VisualizarFotoScreen(
                                        fotoUrl: 'http://10.0.2.2:8000/${anotacao['caminho_foto']}',
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  'http://10.0.2.2:8000/${anotacao['caminho_foto']}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAnotacaoScreen(usuarioId: widget.usuarioId)),
          );
          if (result == true) {
            _carregarAnotacoes();
          }
        },
      ),
    );
  }
}
