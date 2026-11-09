import '../models/diary_entry.dart';
import 'app_database.dart';

/// Abstracción: la UI depende de esto, no de SQLite (principio D de SOLID).
abstract class DiaryRepository {
  Future<List<DiaryEntry>> getAll();
  Future<int> insert(DiaryEntry entry);
  Future<void> delete(int id);
}

/// Implementación concreta con SQLite.
class SqliteDiaryRepository implements DiaryRepository {
  @override
  Future<List<DiaryEntry>> getAll() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query('entries', orderBy: 'created_at DESC');
      return rows.map(DiaryEntry.fromMap).toList();
    } catch (e) {
      throw Exception('No se pudieron cargar las entradas: $e');
    }
  }

  @override
  Future<int> insert(DiaryEntry entry) async {
    try {
      final db = await AppDatabase.instance.database;
      return await db.insert('entries', entry.toMap()..remove('id'));
    } catch (e) {
      throw Exception('No se pudo guardar la entrada: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await AppDatabase.instance.database;
      await db.delete('entries', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('No se pudo eliminar la entrada: $e');
    }
  }
}