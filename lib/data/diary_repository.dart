import 'package:sqflite/sqflite.dart';
import 'diary_database.dart';
import '../models/tasting.dart';
import '../models/tea_personal.dart';

class DiaryRepository {
  Future<Database> get _db => DiaryDatabase.instance.database;

  // ── Tasting ──────────────────────────────────────────────────────────────

  Future<int> addTasting(Tasting tasting) async {
    final db = await _db;

    return db.transaction((txn) async {
      final id = await txn.insert('tasting', tasting.toMap());

      final existing = await txn.query(
        'tea_personal',
        where: 'tea_id = ?',
        whereArgs: [tasting.teaId],
      );

      if (existing.isEmpty) {
        await txn.insert('tea_personal', {
          'tea_id': tasting.teaId,
          'first_tasted_at': tasting.date.millisecondsSinceEpoch,
          'last_tasted_at': tasting.date.millisecondsSinceEpoch,
          'tasting_count': 1,
          'average_rating': tasting.rating.toDouble(),
          'is_favorite': 0,
        });
      } else {
        await _recalculateTeaPersonal(txn, tasting.teaId);
      }

      return id;
    });
  }

  Future<void> updateTasting(Tasting tasting) async {
    assert(tasting.id != null, 'updateTasting richiede un id valido');
    final db = await _db;

    await db.transaction((txn) async {
      await txn.update(
        'tasting',
        tasting.toMap(),
        where: 'id = ?',
        whereArgs: [tasting.id],
      );
      await _recalculateTeaPersonal(txn, tasting.teaId);
    });
  }

  Future<void> deleteTasting(int tastingId) async {
    final db = await _db;

    await db.transaction((txn) async {
      final rows = await txn.query(
        'tasting',
        columns: ['tea_id'],
        where: 'id = ?',
        whereArgs: [tastingId],
      );
      if (rows.isEmpty) return;

      final teaId = rows.first['tea_id'] as String;
      await txn.delete('tasting', where: 'id = ?', whereArgs: [tastingId]);

      final remaining = await txn.query(
        'tasting',
        where: 'tea_id = ?',
        whereArgs: [teaId],
      );

      if (remaining.isEmpty) {
        await txn.delete('tea_personal', where: 'tea_id = ?', whereArgs: [teaId]);
      } else {
        await _recalculateTeaPersonal(txn, teaId);
      }
    });
  }

  Future<List<Tasting>> getTastingsForTea(String teaId) async {
    final db = await _db;
    final rows = await db.query(
      'tasting',
      where: 'tea_id = ?',
      whereArgs: [teaId],
      orderBy: 'date DESC',
    );
    return rows.map(Tasting.fromMap).toList();
  }

  // ── TeaPersonal ──────────────────────────────────────────────────────────

  Future<List<TeaPersonal>> getAllTeaPersonal() async {
    final db = await _db;
    final rows = await db.query('tea_personal', orderBy: 'last_tasted_at DESC');
    return rows.map(TeaPersonal.fromMap).toList();
  }

  Future<TeaPersonal?> getTeaPersonal(String teaId) async {
    final db = await _db;
    final rows = await db.query(
      'tea_personal',
      where: 'tea_id = ?',
      whereArgs: [teaId],
    );
    if (rows.isEmpty) return null;
    return TeaPersonal.fromMap(rows.first);
  }

  Future<void> toggleFavorite(String teaId) async {
    final db = await _db;
    await db.rawUpdate(
      'UPDATE tea_personal SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END WHERE tea_id = ?',
      [teaId],
    );
  }

  // ── Helper privato ────────────────────────────────────────────────────────

  // Ricalcola tasting_count, average_rating, last_tasted_at, first_tasted_at
  // leggendo tutte le tasting rimaste per quel tè.
  Future<void> _recalculateTeaPersonal(
    DatabaseExecutor txn,
    String teaId,
  ) async {
    final tastings = await txn.query(
      'tasting',
      where: 'tea_id = ?',
      whereArgs: [teaId],
      orderBy: 'date ASC',
    );

    final count = tastings.length;
    final ratings = tastings.map((r) => (r['rating'] as num).toDouble()).toList();
    final avg = ratings.reduce((a, b) => a + b) / count;
    final firstDate = tastings.first['date'] as int;
    final lastDate = tastings.last['date'] as int;

    await txn.update(
      'tea_personal',
      {
        'tasting_count': count,
        'average_rating': avg,
        'first_tasted_at': firstDate,
        'last_tasted_at': lastDate,
      },
      where: 'tea_id = ?',
      whereArgs: [teaId],
    );
  }
}
