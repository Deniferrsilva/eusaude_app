import 'package:flutter/material.dart';
import 'documentos_screen.dart';
import 'agendamentos_screen.dart';
import 'perfil_screen.dart';
import 'medidas_screen.dart';
import 'login_screen.dart';
import 'anotacoes_screen.dart';
// import 'notificacoes_screen.dart'; // caso queira criar uma tela de notificações futuramente

class DashboardScreen extends StatelessWidget {
  final int usuarioId;

  DashboardScreen({required this.usuarioId});

  final List<_DashboardItem> items = [
    _DashboardItem(icon: Icons.insert_drive_file, title: 'Meus Documentos'),
    _DashboardItem(icon: Icons.calendar_today, title: 'Meus Agendamentos'),
    _DashboardItem(icon: Icons.fitness_center, title: 'Minhas Medidas'),
    _DashboardItem(icon: Icons.notes, title: 'Minhas Anotações'),
    _DashboardItem(icon: Icons.person, title: 'Meu Perfil'),
    _DashboardItem(icon: Icons.logout, title: 'Sair'),
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget Function()> navigationMap = {
      'Meus Documentos': () => DocumentosScreen(usuarioId: usuarioId),
      'Meus Agendamentos': () => AgendamentosScreen(usuarioId: usuarioId),
      'Minhas Medidas': () => MedidasScreen(usuarioId: usuarioId),
      'Minhas Anotações': () => AnotacoesScreen(usuarioId: usuarioId),
      'Meu Perfil': () => PerfilScreen(usuarioId: usuarioId),
      // 'Notificacoes': () => NotificacoesScreen(), // exemplo se quiser ter tela de notificações
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('EuSaúde'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sem notificações no momento.')),
                  );
                  // Ou navega para uma tela de notificações
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificacoesScreen()));
                },
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    '3', // número de notificações pendentes (coloque dinâmico no futuro)
                    style: TextStyle(color: Colors.white, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 por linha
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: () {
                if (item.title == 'Sair') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                } else {
                  final screenBuilder = navigationMap[item.title];
                  if (screenBuilder != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screenBuilder()),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String title;

  _DashboardItem({required this.icon, required this.title});
}
