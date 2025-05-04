import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddAgendamentoScreen extends StatefulWidget {
  final int usuarioId;

  AddAgendamentoScreen({required this.usuarioId});

  @override
  _AddAgendamentoScreenState createState() => _AddAgendamentoScreenState();
}

class _AddAgendamentoScreenState extends State<AddAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  String tipo = '';
  DateTime? dataSelecionada;
  final _dataController = TextEditingController();
  bool isSaving = false;

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'Selecione a data do agendamento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() {
        dataSelecionada = picked;
        _dataController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _salvarAgendamento() async {
    if (!_formKey.currentState!.validate() || dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    setState(() => isSaving = true);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/cadastrar_agendamento'),
      body: {
        'usuario_id': widget.usuarioId.toString(),
        'tipo': tipo,
        'data': dataSelecionada!.toIso8601String(),
      },
    );

    setState(() => isSaving = false);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Sucesso'),
            ],
          ),
          content: Text('Agendamento salvo com sucesso!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar. Tente novamente.')),
      );
    }
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 20.0;

    return Scaffold(
      appBar: AppBar(title: Text('Novo Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Preencha os dados abaixo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: spacing),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tipo de Agendamento',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Informe o tipo' : null,
                onChanged: (value) => tipo = value,
              ),
              SizedBox(height: spacing),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data do Agendamento',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: _selecionarData,
                validator: (_) => dataSelecionada == null ? 'Selecione a data' : null,
              ),
              SizedBox(height: spacing * 1.5),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: isSaving
                      ? SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(Icons.save),
                  label: Text(isSaving ? 'Salvando...' : 'Salvar'),
                  onPressed: isSaving ? null : _salvarAgendamento,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
