import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expenses_tracker/models/expense.dart';

class ExpenseDatabase {
  static const _databaseName = 'expenses.db';
  static const _databaseVersion = 1;

  static const tableExpenses = 'expenses';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnAmount = 'amount';
  static const columnDate = 'date';
  static const columnCategory = 'category';

  static Future<Database> _open() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableExpenses (
            $columnId TEXT PRIMARY KEY,
            $columnTitle TEXT,
            $columnAmount INTEGER,
            $columnDate TEXT,
            $columnCategory TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertExpense(Expense expense) async {
    final db = await _open();
    await db.insert(
      tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Expense>> getExpenses() async {
    final db = await _open();
    final maps = await db.query(tableExpenses);
    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  static Future<void> deleteExpense(String id) async {
    final db = await _open();
    await db.delete(
      tableExpenses,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllExpenses() async {
    final db = await _open();
    await db.delete(tableExpenses);
  }
}
