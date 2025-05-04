import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_agendamento_screen.dart';
import 'edit_agendamento_screen.dart';

class AgendamentosScreen extends StatefulWidget {
  final int usuarioId;
  AgendamentosScreen({required this.usuarioId});

  @override
  _AgendamentosScreenState createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  List<Map<String, dynamic>> agendamentos = [];
  bool isLoading = true;
  String filtroStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => isLoading = true);
   final url = Uri.parse('http://10.0.2.2:8000/listar_agendamentos/${widget.usuarioId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          agendamentos = List<Map<String, dynamic>>.from(data['agendamentos']);
          isLoading = false;
        });
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
      );
    }
  }

  Future<void> _atualizarStatus(int id, String status) async {
    final url = Uri.parse('http://10.0.2.2:8000/atualizar_status_agendamento');
    try {
      final response = await http.post(url, body: {
        'agendamento_id': id.toString(),
        'novo_status': status,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para $status')),
        );
        _carregarAgendamentos();
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> agFiltrados = filtroStatus == 'todos'
        ? agendamentos
        : agendamentos.where((ag) => ag['status'] == filtroStatus).toList();

    Map<String, List<Map<String, dynamic>>> agPorData = {};
    for (var ag in agFiltrados) {
      String dataStr = ag['data'].split('T').first; // pegar só a data
      agPorData[dataStr] = (agPorData[dataStr] ?? [])..add(ag);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Agendamentos'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => filtroStatus = value),
            icon: Icon(Icons.filter_alt),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'todos', child: Text('Todos')),
              PopupMenuItem(value: 'confirmado', child: Text('Confirmados')),
              PopupMenuItem(value: 'pendente', child: Text('Pendentes')),
              PopupMenuItem(value: 'cancelado', child: Text('Cancelados')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _carregarAgendamentos,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : agPorData.isEmpty
              ? Center(child: Text('Nenhum agendamento encontrado.'))
              : ListView(
                  children: agPorData.entries.map((entry) {
                    String data = entry.key;
                    List<Map<String, dynamic>> ags = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _formatarData(data),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...ags.map((ag) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Slidable(
                                key: ValueKey(ag['id']),
                                startActionPane: ActionPane(
                                  motion: DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) => _editarAgendamento(ag),
                                      icon: Icons.edit,
                                      label: 'Editar',
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) => _atualizarStatus(ag['id'], 'cancelado'),
                                      icon: Icons.cancel,
                                      label: 'Cancelar',
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _corStatus(ag['status']),
                                      child: Icon(Icons.event, color: Colors.white),
                                    ),
                                    title: Text(
                                      ag['tipo'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                ag['local'] ?? 'Local não informado',
                                                style: TextStyle(color: Colors.grey[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (ag['descricao'] != null && ag['descricao'].isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.description, size: 16, color: Colors.grey),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    ag['descricao'],
                                                    style: TextStyle(color: Colors.grey[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Chip(
                                            label: Text(
                                              ag['status'].toUpperCase(),
                                              style: TextStyle(
                                                color: _corStatus(ag['status']),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: _corStatus(ag['status']).withOpacity(0.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddAgendamentoScreen(usuarioId: widget.usuarioId)),
          );
          if (result == true) _carregarAgendamentos();
        },
      ),
    );
  }

void _editarAgendamento(Map<String, dynamic> agendamento) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditAgendamentoScreen(agendamento: agendamento),
    ),
  );
  if (result == true) _carregarAgendamentos();
}

  String _formatarData(String data) {
    try {
      final date = DateTime.parse(data);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return data;
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'confirmado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// void _editarAgendamento(Map<String, dynamic> agendamento) async {
//   final result = await Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => EditAgendamentoScreen(agendamento: agendamento)),
//   );
//   if (result == true) _carregarAgendamentos();
// }

