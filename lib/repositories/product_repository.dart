import 'dart:async';

import '../local/product_note_local_data_source.dart';
import '../models/product.dart';
import '../models/product_note.dart';
import '../remote/product_note_remote_data_source.dart';
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
  final ProductNoteLocalDataSource local;
  final ProductNoteRemoteDataSource? remote;

  ProductRepository({
    required this.productService,
    required this.local,
    this.remote,
  });

  // 1. Obtener catálogo desde el servicio HTTP
  Future<List<Product>> fetchProducts() {
    return productService.getProducts();
  }

  // 2. Obtener nota guardada localmente desde Drift
  Future<ProductNote?> getNote(int productId) {
    return local.getNote(productId);
  }

  // 3. Guardar nota con estrategia offline-first
  Future<SaveNoteResult> saveNote(int productId, String note, int priority) async {
    // (a) Valida priority >= 2; si no se cumple, lanza excepción propia sin tocar la base
    if (priority < 2) {
      throw const InvalidPriorityException(
        'La prioridad debe ser 2 o más para guardar',
      );
    }

    final newNote = ProductNote(
      productId: productId,
      note: note,
      priority: priority,
      updatedAt: DateTime.now(),
    );

    // (b) Guarda primero en Drift con pendingSync = true y updatedAt = ahora
    await local.saveNote(newNote);

    // (c) Intenta enviar a Firestore; si falla, el registro sigue pendiente
    final synced = await _trySync(newNote);

    final saved = await local.getNote(productId);
    return SaveNoteResult(
      note: saved!,
      synced: synced,
    );
  }

  // 4. Sincronizar registros pendientes
  Future<SyncResult> syncPending() async {
    // Lee SOLO los registros con pendingSync == true
    final pendingNotes = await local.getPendingNotes();

    int syncedCount = 0;
    int stillPendingCount = 0;

    for (final note in pendingNotes) {
      if (await _trySync(note)) {
        syncedCount++;
      } else {
        stillPendingCount++;
      }
    }

    return SyncResult(
      syncedCount: syncedCount,
      pendingCount: stillPendingCount,
    );
  }

  // Envía una nota a Firestore y, solo si termina bien, la marca como sincronizada.
  // Si Firebase falla o entra en timeout, conserva el registro local con
  // pendingSync = true y NO lanza error al usuario.
  Future<bool> _trySync(ProductNote note) async {
    final remoteSource = remote;
    if (remoteSource == null) return false;

    try {
      await remoteSource.upsertNote(note);
      await local.markSynced(note.productId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
