import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class InvalidPriorityException implements Exception {
  final String message;
  const InvalidPriorityException(this.message);

  @override
  String toString() => message;
}

class SyncResult {
  final int syncedCount;
  final int pendingCount;

  const SyncResult({
    required this.syncedCount,
    required this.pendingCount,
  });
}

class SaveNoteResult {
  final ProductNote note;
  final bool synced;

  const SaveNoteResult({
    required this.note,
    required this.synced,
  });
}

class ProductRepository {
  final ProductService productService;
  final AppDatabase database;
  final FirebaseFirestore? firestore;

  ProductRepository({
    required this.productService,
    required this.database,
    this.firestore,
  });

  // 1. Obtener catálogo desde el servicio HTTP
  Future<List<Product>> fetchProducts() {
    return productService.getProducts();
  }

  // 2. Obtener nota guardada localmente desde Drift
  Future<ProductNote?> getNote(int productId) {
    return database.getNoteByProductId(productId);
  }

  // 3. Guardar nota con estrategia offline-first
  Future<SaveNoteResult> saveNote(int productId, String note, int priority) async {
    // (a) Valida priority >= 2; si no se cumple, lanza excepción propia sin tocar la base
    if (priority < 2) {
      throw const InvalidPriorityException(
        'La prioridad debe ser 2 o más para guardar',
      );
    }

    final now = DateTime.now();

    // (b) Guarda primero en Drift con pendingSync = true y updatedAt = ahora
    await database.upsertNote(
      ProductNotesCompanion(
        productId: Value(productId),
        note: Value(note),
        priority: Value(priority),
        updatedAt: Value(now),
        pendingSync: const Value(true),
      ),
    );

    bool synced = false;
    final currentFirestore = firestore;

    // (c) Intenta enviar a Firestore
    if (currentFirestore != null) {
      try {
        await currentFirestore
            .collection('product_notes')
            .doc(productId.toString())
            .set(
              {
                'productId': productId,
                'note': note,
                'priority': priority,
                'updatedAt': Timestamp.fromDate(now),
              },
              SetOptions(merge: true),
            )
            .timeout(const Duration(seconds: 8));

        // (d) Si el envío termina bien, actualiza el registro local a pendingSync = false
        await database.markAsSynced(productId);
        synced = true;
      } catch (_) {
        // (e) Si Firebase falla o entra en timeout, conserva el registro local
        // con pendingSync = true y NO lanza error al usuario.
        synced = false;
      }
    }

    final saved = await database.getNoteByProductId(productId);
    return SaveNoteResult(
      note: saved!,
      synced: synced,
    );
  }

  // 4. Sincronizar registros pendientes
  Future<SyncResult> syncPending() async {
    // Lee SOLO los registros con pendingSync == true
    final pendingNotes = await database.getPendingNotes();

    if (pendingNotes.isEmpty) {
      return const SyncResult(syncedCount: 0, pendingCount: 0);
    }

    final currentFirestore = firestore;
    if (currentFirestore == null) {
      return SyncResult(syncedCount: 0, pendingCount: pendingNotes.length);
    }

    int syncedCount = 0;
    int stillPendingCount = 0;

    for (final note in pendingNotes) {
      try {
        await currentFirestore
            .collection('product_notes')
            .doc(note.productId.toString())
            .set(
              {
                'productId': note.productId,
                'note': note.note,
                'priority': note.priority,
                'updatedAt': Timestamp.fromDate(note.updatedAt),
              },
              SetOptions(merge: true),
            )
            .timeout(const Duration(seconds: 8));

        await database.markAsSynced(note.productId);
        syncedCount++;
      } catch (_) {
        stillPendingCount++;
      }
    }

    return SyncResult(
      syncedCount: syncedCount,
      pendingCount: stillPendingCount,
    );
  }
}
