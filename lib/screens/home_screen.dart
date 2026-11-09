import 'dart:io';
import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../data/diary_repository.dart';
import '../models/diary_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DiaryRepository _repo = SqliteDiaryRepository();
  late Future<List<DiaryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getAll();
  }

  void _reload() => setState(() => _future = _repo.getAll());

  Future<void> _openForm() async {
    final saved = await Navigator.pushNamed(context, AppRoutes.form);
    if (saved == true) _reload();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Diario')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Mi Diario',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Mis entradas'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Nueva entrada'),
              onTap: () {
                Navigator.pop(context);
                _openForm();
              },
            ),
            const Divider(),
            AboutListTile(
              icon: const Icon(Icons.info),
              applicationName: 'Mi Diario',
              applicationVersion: '1.0',
              child: const Text('Acerca de'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('Aún no hay entradas. ¡Crea la primera!'));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: e.imagePath != null
                      ? Hero(
                    tag: 'entry-image-${e.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(e.imagePath!),
                          width: 56, height: 56, fit: BoxFit.cover),
                    ),
                  )
                      : const Icon(Icons.image_not_supported, size: 40),
                  title: Text(e.title),
                  subtitle: Text(_fmt(e.createdAt)),
                  trailing: e.hasLocation ? const Icon(Icons.place) : null,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.detail, arguments: e),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }
}