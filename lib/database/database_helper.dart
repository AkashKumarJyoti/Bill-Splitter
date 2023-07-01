import 'dart:async';
import 'dart:io';
import 'package:bill_splitter/model/expenses.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper
{
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  // Variables
  static const dbName = "mydatabase.db";
  static const dbVersion = 1;
  static const dbTable = "myTable";
  static const columnId = "id";
  static const columnTip = "tip";
  static const columnAmount = "amount";
  static const columnTitle = "title";

  DatabaseHelper.internal();
  // Constructor
  // static final DatabaseHelper instance = DatabaseHelper();

  // Database Initialisation
  static Database? _database;

  Future<Database?> get database async{
    if(_database != null)
    {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbName);
    return openDatabase(path, version: dbVersion, onCreate: onCreate);
  }


  Future onCreate(Database db, int version) async
  {
    await db.execute(
        "CREATE TABLE $dbTable(id INTEGER PRIMARY KEY, $columnTitle TEXT, $columnAmount TEXT, $columnTip TEXT)");
    print("Table is created");
  }

  // Insert Method
  Future<int?> insertRecord(BillItem row) async
  {
    Database? db = await database;
    return await db?.insert(dbTable, row.toMap());
  }

  // Query Method
  Future<List<Map<String, dynamic>>?> queryDatabase() async
  {
    Database? db = await database;
    return await db?.query(dbTable);
  }

  // Update Method
  Future<int?> updateRecord(BillItem row) async
  {
    Database? db = await database;
    int? id = row.id;
    return await db?.update(dbTable, row.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete Method
  Future<int?> deleteRecord(int id) async
  {
    Database? db = await database;
    return await db?.delete(dbTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<BillItem?> getItem(int id) async {
    var dbClient = await database;
    var result = await dbClient?.rawQuery("SELECT * FROM $dbTable WHERE id = $id");
    if (result?.length == 0) return null;
    return BillItem.fromMap(result!.first);
  }




}