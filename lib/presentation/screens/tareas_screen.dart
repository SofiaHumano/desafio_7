import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/tareas_service.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final TareasService _service = TareasService();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    _controller.clear();

    try {
      await _service.agregar(texto);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la tarea: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _agregar(),
                  decoration: const InputDecoration(
                    labelText: 'Nueva tarea',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _agregar,
                child: const Text('Agregar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _service.tareasDelUsuario(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final ta = a.data()['fechaCreacion'] as Timestamp?;
                final tb = b.data()['fechaCreacion'] as Timestamp?;
                if (ta == null && tb == null) return 0;
                if (ta == null) return -1;
                if (tb == null) return 1;
                return tb.compareTo(ta);
              });

              if (docs.isEmpty) {
                return const Center(child: Text('Todavía no tenés tareas'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final data = doc.data();
                  final String titulo = (data['titulo'] as String?) ?? '';
                  final bool completada = (data['completada'] as bool?) ?? false;

                  return ListTile(
                    leading: Checkbox(
                      value: completada,
                      onChanged: (valor) =>
                          _service.actualizar(doc.id, valor ?? false),
                    ),
                    title: Text(
                      titulo,
                      style: TextStyle(
                        decoration:
                        completada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: cs.error),
                      onPressed: () => _service.eliminar(doc.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}