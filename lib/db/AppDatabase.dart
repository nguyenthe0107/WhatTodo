import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/models/Tasks.dart';

class AppDatabase {
  static final AppDatabase _appDatabase = new AppDatabase._internal();

  AppDatabase._internal();

  Database _database;

  static AppDatabase get() {
    return _appDatabase;
  }

  bool didInit = false;

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async {
    if (!didInit) await _init();
    return _database;
  }

  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tasks.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute("CREATE TABLE ${Tasks.tblTask} ("
          "${Tasks.dbId} INTEGER PRIMARY KEY,"
          "${Tasks.dbTitle} TEXT,"
          "${Tasks.dbDescription} TEXT,"
          "${Tasks.dbScheduleDate} LONG"
          ")");
    });
    didInit = true;
  }

  Future<List<Tasks>> getTasks() async {
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM ${Tasks.tblTask}');
    List<Tasks> tasks = new List();
    for (Map<String, dynamic> item in result) {
      var myTask = new Tasks.fromMap(item);
      tasks.add(myTask);
    }
    return tasks;
  }

  /// Inserts or replaces the book.
  Future updateTask(Tasks task) async {
    var db = await _getDb();
    await db.inTransaction(() async {
      await db.rawInsert('INSERT OR REPLACE INTO '
          '${Tasks.tblTask}(${Tasks.dbId},${Tasks.dbTitle},${Tasks
          .dbDescription},${Tasks.dbScheduleDate})'
          ' VALUES(${task.id}, "${task.title}", "${task
          .description}", ${task.scheduleDate})');
    });
  }
}