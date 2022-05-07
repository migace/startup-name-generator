import 'package:flutter/cupertino.dart';
import 'package:my_app/startupNamesModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute(
        'CREATE TABLE startupNames(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT)');
  }

  static Future<Database> db() async {
    return openDatabase(join(await getDatabasesPath(), 'database.db'),
        onCreate: (db, version) async {
      await createTables(db);
    }, version: 1);
  }

  static Future<void> insert(String tableName, StartupName startupName) async {
    final db = await SQLHelper.db();

    await db.insert(tableName, startupName.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getItems(String tableName) async {
    final db = await SQLHelper.db();

    return db.query(tableName, orderBy: "id");
  }

  static Future<void> remove(String tableName, int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
