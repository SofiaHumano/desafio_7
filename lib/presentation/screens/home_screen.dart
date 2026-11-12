import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import 'perfil_screen.dart';
import 'tareas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  int _indice = 0;

  final List<String> _titulos = ['Mis tareas', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    final pantallas = [
      const TareasScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: cs.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: cs.onPrimary,
                    child: Icon(Icons.person, size: 36, color: cs.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email,
                    style: TextStyle(color: cs.onPrimary, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('Mis tareas'),
              selected: _indice == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() => _indice = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              selected: _indice == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() => _indice = 1);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Cerrar sesión', style: TextStyle(color: cs.error)),
              onTap: () async {
                Navigator.pop(context);
                await _auth.cerrarSesion();
              },
            ),
          ],
        ),
      ),

      body: pantallas[_indice],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}