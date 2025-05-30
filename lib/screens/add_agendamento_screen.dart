import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart'; // ✅ Importação NotificationService

class AddAgendamentoScreen extends StatefulWidget {
  final int usuarioId;

  AddAgendamentoScreen({required this.usuarioId});

  @override
  _AddAgendamentoScreenState createState() => _AddAgendamentoScreenState();
}

class _AddAgendamentoScreenState extends State<AddAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();
  final _localController = TextEditingController(); // ✅ novo campo local
  DateTime? dataSelecionada;
  int _antecedenciaMinutos = 60;
  List<String> _sugestoesEndereco = [];
  bool _carregandoSugestoes = false;

  Future<void> _buscarSugestoesEndereco(String query) async {
    if (query.length < 3) {
      setState(() {
        _sugestoesEndereco = [];
      });
      return;
    }

    setState(() => _carregandoSugestoes = true);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    final response = await http.get(url, headers: {'User-Agent': 'eusaude_app'});
    
    if (response.statusCode == 200) {
      final resultados = jsonDecode(response.body) as List;
      setState(() {
        _sugestoesEndereco = resultados.map((r) => r['display_name'] as String).toList();
      });
    } else {
      setState(() => _sugestoesEndereco = []);
    }
    setState(() => _carregandoSugestoes = false);
  }

  Future<void> _salvarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      var url = Uri.parse('http://10.0.2.2:8000/cadastrar_agendamento');
      var response = await http.post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'usuario_id': widget.usuarioId.toString(),
              'tipo': _tipoController.text,
              'descricao': _descricaoController.text,
              'local': _localController.text,
              'data': dataSelecionada!.toIso8601String(),
            },
          );


      if (response.statusCode == 200) {
        final idNotificacao = DateTime.now().millisecondsSinceEpoch.remainder(100000);
        final agendamentoDate = dataSelecionada!;

        final scheduledNotificationDate = agendamentoDate.subtract(Duration(minutes: _antecedenciaMinutos));

        await NotificationService.scheduleNotification(
          id: idNotificacao,
          title: 'Lembrete de Agendamento',
          body: 'Você tem um agendamento de "${_tipoController.text}" em ${_dataController.text}',
          scheduledDate: scheduledNotificationDate.isBefore(DateTime.now())
              ? DateTime.now().add(Duration(seconds: 5))
              : scheduledNotificationDate,
        );

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text('Sucesso')],
            ),
            content: Text('Agendamento salvo e notificação programada!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar agendamento')));
      }
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          dataSelecionada = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          _dataController.text = '${picked.day}/${picked.month}/${picked.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tipoController,
                decoration: InputDecoration(labelText: 'Tipo'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o tipo' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _localController,
                decoration: InputDecoration(labelText: 'Local da Consulta'),
                onChanged: _buscarSugestoesEndereco,
                validator: (value) => value == null || value.isEmpty ? 'Informe o local' : null,
              ),
              if (_carregandoSugestoes) ...[
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                )
              ],
              ..._sugestoesEndereco.map((s) => ListTile(
                    title: Text(s),
                    onTap: () {
                      setState(() {
                        _localController.text = s;
                        _sugestoesEndereco.clear();
                      });
                    },
                  )),
              SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data e Hora',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selecionarData,
                validator: (value) => value == null || value.isEmpty ? 'Selecione a data e hora' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _antecedenciaMinutos,
                decoration: InputDecoration(labelText: 'Notificar com antecedência'),
                items: [
                  DropdownMenuItem(value: 5, child: Text('5 minutos antes')),
                  DropdownMenuItem(value: 15, child: Text('15 minutos antes')),
                  DropdownMenuItem(value: 30, child: Text('30 minutos antes')),
                  DropdownMenuItem(value: 60, child: Text('1 hora antes')),
                  DropdownMenuItem(value: 1440, child: Text('1 dia antes')),
                ],
                onChanged: (value) {
                  setState(() {
                    _antecedenciaMinutos = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarAgendamento,
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
