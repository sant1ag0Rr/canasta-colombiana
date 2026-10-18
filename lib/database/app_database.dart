import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ProductNotes extends Table {
  IntColumn get productId => integer()();
  TextColumn get note => text()();
  IntColumn get priority => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {productId};
}

@DriftDatabase(tables: [ProductNotes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // 1. Obtener nota por productId
  Future<ProductNote?> getNoteByProductId(int productId) {
    return (select(productNotes)..where((tbl) => tbl.productId.equals(productId)))
        .getSingleOrNull();
  }

  // 2. Upsert: guarda o actualiza el existente sin duplicar registros
  Future<int> upsertNote(ProductNotesCompanion companion) {
    return into(productNotes).insertOnConflictUpdate(companion);
  }

  // 3. Obtener todas las que tengan pendingSync == true
  Future<List<ProductNote>> getPendingNotes() {
    return (select(productNotes)..where((tbl) => tbl.pendingSync.equals(true)))
        .get();
  }

  // 4. Marcar como sincronizada (pendingSync = false) por productId
  Future<int> markAsSynced(int productId) {
    return (update(productNotes)..where((tbl) => tbl.productId.equals(productId)))
        .write(const ProductNotesCompanion(pendingSync: Value(false)));
  }
}
