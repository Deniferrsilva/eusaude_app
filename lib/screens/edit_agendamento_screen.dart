import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditAgendamentoScreen extends StatefulWidget {
  final Map<String, dynamic> agendamento;

  EditAgendamentoScreen({required this.agendamento});

  @override
  _EditAgendamentoScreenState createState() => _EditAgendamentoScreenState();
}

class _EditAgendamentoScreenState extends State<EditAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tipoController;
  late TextEditingController _descricaoController;
  late TextEditingController _localController;
  late TextEditingController _dataController;
  DateTime? dataSelecionada;
  List<String> _sugestoesEndereco = [];
  bool _carregandoSugestoes = false;

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.agendamento['tipo']);
    _descricaoController = TextEditingController(text: widget.agendamento['descricao'] ?? '');
    _localController = TextEditingController(text: widget.agendamento['local'] ?? '');
    dataSelecionada = DateTime.tryParse(widget.agendamento['data']);
    _dataController = TextEditingController(
      text: dataSelecionada != null
          ? '${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year} ${dataSelecionada!.hour}:${dataSelecionada!.minute.toString().padLeft(2, '0')}'
          : '',
    );
  }

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

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dataSelecionada ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          dataSelecionada = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          _dataController.text = '${picked.day}/${picked.month}/${picked.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  Future<void> _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      var url = Uri.parse('http://10.0.2.2:8000/atualizar_agendamento');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'agendamento_id': widget.agendamento['id'].toString(),
          'tipo': _tipoController.text,
          'descricao': _descricaoController.text,
          'local': _localController.text,
          'data': dataSelecionada!.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text('Sucesso')],
            ),
            content: Text('Agendamento atualizado com sucesso!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar agendamento')));
      }
    }
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarEdicao,
                child: Text('Salvar Alterações'),
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
