import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_agendamento_screen.dart'; // ✅ ou o caminho correto para seu arquivo


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
    // aplica o filtro
    List<Map<String, dynamic>> agFiltrados = filtroStatus == 'todos'
        ? agendamentos
        : agendamentos.where((ag) => ag['status'] == filtroStatus).toList();

    // agrupa por data
    Map<String, List<Map<String, dynamic>>> agPorData = {};
    for (var ag in agFiltrados) {
      String dataStr = ag['data']; // espera string no formato yyyy-MM-dd
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
              : ListView.builder(
                  itemCount: agPorData.length,
                  itemBuilder: (context, index) {
                    String data = agPorData.keys.toList()[index];
                    List<Map<String, dynamic>> ags = agPorData[data]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            _formatarData(data),
                            style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...ags.map((ag) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Slidable(
                                key: ValueKey(ag['id']),
                                startActionPane: ActionPane(
                                  motion: DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) => _editarAgendamento(ag),
                                      icon: Icons.edit,
                                      label: 'Editar',
                                      backgroundColor: Colors.blue,
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) =>
                                          _atualizarStatus(ag['id'], 'cancelado'),
                                      icon: Icons.cancel,
                                      label: 'Cancelar',
                                      backgroundColor: Colors.red,
                                    ),
                                  ],
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _corStatus(ag['status']),
                                      child: Icon(Icons.event_note, color: Colors.white),
                                    ),
                                    title: Text(ag['tipo']),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (ag['medico'] != null && ag['medico'].isNotEmpty)
                                          Text('Médico: ${ag['medico']}'),
                                        Text('Local: ${ag['local']}'),
                                        SizedBox(height: 4),
                                        Chip(
                                          label: Text(ag['status'].toUpperCase()),
                                          backgroundColor: _corStatus(ag['status']).withOpacity(0.2),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    );
                  },
                ),
            floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAgendamentoScreen(usuarioId: widget.usuarioId)),
          );
          if (result == true) _carregarAgendamentos();
        },
      ),
    );
  }


  void _editarAgendamento(Map<String, dynamic> agendamento) {
    // exemplo simples (você pode navegar para uma tela de edição real)
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar ${agendamento['tipo']}'),
        content: Text('Implementar tela de edição.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
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

