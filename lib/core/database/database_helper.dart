import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _dbName = "bolitero_database.db";
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    // Si la base de datos no existe localmente, copiamos la base pre-sembrada en milisegundos
    if (!await File(path).exists()) {
      try {
        final ByteData data = await rootBundle.load('assets/seed/bolitero_seed.db');
        final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        // En caso de fallo de assets, SQLite creará el archivo por defecto
      }
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Fallback DDL en caso de inicialización limpia sin asset
        await db.execute('''
          CREATE TABLE IF NOT EXISTS local_draws (
            id TEXT PRIMARY KEY,
            lottery TEXT NOT NULL,
            period TEXT NOT NULL,
            draw_date TEXT NOT NULL,
            draw_time TEXT,
            pick3_raw TEXT NOT NULL,
            pick4_raw TEXT,
            fijo TEXT NOT NULL,
            centena TEXT NOT NULL,
            corrido1 TEXT,
            corrido2 TEXT,
            status TEXT DEFAULT 'official',
            created_at INTEGER NOT NULL
          );
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_draws_date_lottery 
          ON local_draws (draw_date DESC, lottery, period);
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_draws_fijo 
          ON local_draws (fijo);
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS charada_entries (
            number INTEGER PRIMARY KEY,
            primary_name TEXT NOT NULL,
            category TEXT DEFAULT 'clasica',
            synonyms TEXT NOT NULL,
            deity TEXT,
            accompanying TEXT,
            description TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS lab_plays (
            id TEXT PRIMARY KEY,
            draw_date TEXT NOT NULL,
            lottery TEXT NOT NULL,
            period TEXT NOT NULL,
            play_type TEXT NOT NULL,
            numbers TEXT NOT NULL,
            virtual_points REAL DEFAULT 10.0,
            status TEXT DEFAULT 'pending',
            payout_multiplier REAL DEFAULT 0.0,
            total_payout REAL DEFAULT 0.0,
            created_at INTEGER NOT NULL,
            settled_at INTEGER
          );
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_lab_pending 
          ON lab_plays (status, draw_date, lottery, period);
        ''');
      },
      onOpen: (db) async {
        // Garantizar que los índices existan siempre aun si se cargó la BD del asset pre-sembrado
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_draws_date_lottery 
          ON local_draws (draw_date DESC, lottery, period);
        ''');
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_draws_fijo 
          ON local_draws (fijo);
        ''');
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_lab_pending 
          ON lab_plays (status, draw_date, lottery, period);
        ''');
      },
    );
  }
}
