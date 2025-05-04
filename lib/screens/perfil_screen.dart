import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  final int usuarioId;

  PerfilScreen({required this.usuarioId});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? usuario;
  Map<String, dynamic>? ultimaMedida;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  void _carregarPerfil() async {
    final perfilUrl = Uri.parse('http://10.0.2.2:8000/usuario/${widget.usuarioId}');
    final medidaUrl = Uri.parse('http://10.0.2.2:8000/ultima_medida/${widget.usuarioId}');

    try {
      final responses = await Future.wait([http.get(perfilUrl), http.get(medidaUrl)]);

      final perfilResponse = responses[0];
      final medidaResponse = responses[1];

      if (perfilResponse.statusCode == 200) {
        final perfilData = jsonDecode(perfilResponse.body);
        usuario = perfilData['usuario'];
      }

      if (medidaResponse.statusCode == 200) {
        final medidaData = jsonDecode(medidaResponse.body);
        ultimaMedida = medidaData['medida'];
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar perfil')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meu Perfil')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : usuario == null
              ? Center(child: Text('Não foi possível carregar o perfil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      usuario!['foto_perfil'] != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage('http://10.0.2.2:8000/${usuario!['foto_perfil']}'),
                            )
                          : CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person, size: 60),
                            ),
                      SizedBox(height: 20),
                      Text(
                        usuario!['nome'] ?? 'Sem nome',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        usuario!['email'] ?? 'Sem email',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      Divider(),
                      Text('Última Medida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ultimaMedida == null
                          ? Text('Nenhuma medida registrada.')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text('Peso: ${ultimaMedida!['peso']} kg', style: TextStyle(fontSize: 16)),
                                Text('Cintura: ${ultimaMedida!['cintura']} cm', style: TextStyle(fontSize: 16)),
                                Text('Quadril: ${ultimaMedida!['quadril']} cm', style: TextStyle(fontSize: 16)),
                                Text('Data: ${ultimaMedida!['data']}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ],
                            ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarPerfilScreen(usuarioId: widget.usuarioId),
                            ),
                          );
                          if (result == true) {
                            _carregarPerfil(); // atualiza os dados
                          }
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Editar Perfil'),
                        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                      ),

                    ],
                  ),
                ),
    );
  }
}
