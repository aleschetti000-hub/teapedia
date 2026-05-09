import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DiaryDatabase {
  DiaryDatabase._();
  static final DiaryDatabase instance = DiaryDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'teapedia_diary.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tea_personal (
        tea_id          TEXT PRIMARY KEY,
        first_tasted_at INTEGER NOT NULL,
        last_tasted_at  INTEGER NOT NULL,
        tasting_count   INTEGER NOT NULL DEFAULT 1,
        average_rating  REAL    NOT NULL,
        is_favorite     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE tasting (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        tea_id  TEXT    NOT NULL,
        date    INTEGER NOT NULL,
        rating  INTEGER NOT NULL,
        aromas  TEXT    NOT NULL,
        notes   TEXT,
        FOREIGN KEY (tea_id) REFERENCES tea_personal (tea_id)
      )
    ''');
  }
}
