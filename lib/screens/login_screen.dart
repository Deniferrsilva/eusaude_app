import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart'; // ✅ Importa o NotificationService
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              SizedBox(height: 60),
              Text(
                'Bem-vindo ao EuSaúde',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Gerencie seus documentos e agendamentos de forma simples e segura.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.health_and_safety,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  try {
                    var result = await ApiService.loginUsuario(
                      email: emailController.text,
                      senha: senhaController.text,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                          usuarioId: result['usuario_id'],
                        ),
                      ),
                    );
                  } catch (e) {
                    // Handle login error
                    print('Login error: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  'Criar nova conta',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: 40), // espaço antes do botão de notificação
              
              // ✅ BOTÃO DE TESTE DE NOTIFICAÇÃO
              ElevatedButton(
                onPressed: () {
                  // Chamando o método showNotification para testar
                  NotificationService.showNotification(
                    id: 1,
                    title: "Teste de Notificação",
                    body: "Esta é uma notificação de teste 🚀",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cor diferente para destacar
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Testar Notificação',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // Chamando o método scheduleNotification para testar agendamento
                  final scheduledDate = DateTime.now().add(Duration(seconds: 10));
                  NotificationService.scheduleNotification(
                    id: 2,
                    title: "Notificação Agendada",
                    body: "Esta notificação aparecerá em 10 segundos.",
                    scheduledDate: scheduledDate,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Outra cor para diferenciar
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Agendar Notificação (10s)',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
