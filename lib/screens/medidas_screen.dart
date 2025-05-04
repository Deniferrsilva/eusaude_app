import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_medida_screen.dart';
import 'peso_grafico.dart'; // ajuste o caminho se necessário


class MedidasScreen extends StatefulWidget {
  final int usuarioId;

  MedidasScreen({required this.usuarioId});

  @override
  _MedidasScreenState createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  List medidas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMedidas();
  }

  void _carregarMedidas() async {
    final url = Uri.parse('http://10.0.2.2:8000/listar_medidas/${widget.usuarioId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        medidas = data['medidas'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar medidas')),
      );
    }
  }

  void _exportarMedidas() async {
    final url = Uri.parse('http://10.0.2.2:8000/exportar_medidas/${widget.usuarioId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV exportado em ${data['caminho_arquivo']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar CSV')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Minhas Medidas'),
      actions: [
        IconButton(
          icon: Icon(Icons.file_download),
          tooltip: 'Exportar CSV',
          onPressed: _exportarMedidas,
        ),
      ],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : medidas.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma medida registrada.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Evolução do Peso',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PesoGrafico(medidas: List<Map<String, dynamic>>.from(medidas)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: medidas.length,
                      itemBuilder: (context, index) {
                        final m = medidas[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                  child: Icon(Icons.monitor_weight, color: Theme.of(context).primaryColor, size: 32),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Peso: ${m['peso']} kg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      Text('Cintura: ${m['cintura']} cm'),
                                      Text('Quadril: ${m['quadril']} cm'),
                                      Text('Data: ${m['data']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMedidaScreen(usuarioId: widget.usuarioId)),
        );
        if (result == true) {
          _carregarMedidas();
        }
      },
    ),
  );
}

}
