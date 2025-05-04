import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
static const String baseUrl = 'http://10.0.2.2:8000';
// http://192.168.1.8:8000/uploads/usuario_2/arquivo.pdf

 // use seu IP local real se testar no dispositivo físico

  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
  }) async {
    var uri = Uri.parse('$baseUrl/cadastrar_usuario');
    var request = http.MultipartRequest('POST', uri);

    request.fields['nome'] = nome;
    request.fields['email'] = email;
    request.fields['senha'] = senha;
    request.fields['telefone'] = telefone;
    // Aqui pode adicionar foto futuramente

    var response = await request.send();
    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      return jsonDecode(respStr);
    } else {
      throw Exception('Erro ao cadastrar usuário: ${response.statusCode}');
    }
  }

static Future<Map<String, dynamic>> loginUsuario({
  required String email,
  required String senha,
}) async {
  var uri = Uri.parse('$baseUrl/login');
  var request = http.MultipartRequest('POST', uri);
  request.fields['email'] = email;
  request.fields['senha'] = senha;

  var response = await request.send();
  var respStr = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    return jsonDecode(respStr);
  } else {
    throw Exception(jsonDecode(respStr)['mensagem']);
  }
}

}
