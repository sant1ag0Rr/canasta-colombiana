import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/product_note.dart';

class ProductNoteLocalDataSource {
  final AppDatabase db;

  ProductNoteLocalDataSource(this.db);

  ProductNote _toDomain(ProductNoteRow row) {
    return ProductNote(
      productId: row.productId,
      note: row.note,
      priority: row.priority,
      updatedAt: row.updatedAt,
      pendingSync: row.pendingSync,
    );
  }

  // 1. Obtener nota por productId
  Future<ProductNote?> getNote(int productId) async {
    final row = await (db.select(db.productNotes)
          ..where((tbl) => tbl.productId.equals(productId)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  // 2. Upsert: guarda o actualiza el existente sin duplicar registros
  // y lo deja pendiente de sincronizar
  Future<void> saveNote(ProductNote note) async {
    await db.into(db.productNotes).insertOnConflictUpdate(
          ProductNotesCompanion.insert(
            productId: Value(note.productId),
            note: note.note,
            priority: note.priority,
            updatedAt: note.updatedAt,
            pendingSync: const Value(true),
          ),
        );
  }

  // 3. Obtener todas las que tengan pendingSync == true
  Future<List<ProductNote>> getPendingNotes() async {
    final rows = await (db.select(db.productNotes)
          ..where((tbl) => tbl.pendingSync.equals(true)))
        .get();
    return rows.map(_toDomain).toList();
  }

  // 4. Marcar como sincronizada (pendingSync = false) por productId
  Future<void> markSynced(int productId) async {
    await (db.update(db.productNotes)
          ..where((tbl) => tbl.productId.equals(productId)))
        .write(const ProductNotesCompanion(pendingSync: Value(false)));
  }
}
