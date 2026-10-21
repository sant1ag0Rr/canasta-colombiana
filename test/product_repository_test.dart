import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taller_movil/database/app_database.dart';
import 'package:taller_movil/local/product_note_local_data_source.dart';
import 'package:taller_movil/models/product_note.dart';
import 'package:taller_movil/remote/product_note_remote_data_source.dart';
import 'package:taller_movil/repositories/product_repository.dart';
import 'package:taller_movil/services/product_service.dart';

// Remoto falso para simular Firestore disponible o caído
class FakeRemoteDataSource implements ProductNoteRemoteDataSource {
  bool shouldFail;
  final List<int> sentIds = [];

  FakeRemoteDataSource({this.shouldFail = false});

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  @override
  Future<void> upsertNote(ProductNote note) async {
    if (shouldFail) {
      throw Exception('Fallo remoto simulado');
    }
    sentIds.add(note.productId);
  }
}

void main() {
  late AppDatabase database;
  late ProductNoteLocalDataSource local;
  late FakeRemoteDataSource remote;
  late ProductRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = ProductNoteLocalDataSource(database);
    remote = FakeRemoteDataSource();
    repository = ProductRepository(
      productService: ProductService('http://localhost'),
      local: local,
      remote: remote,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('Persistencia local con Drift', () {
    test('Una nota nueva queda guardada con pendingSync = true', () async {
      await local.saveNote(
        ProductNote(
          productId: 1,
          note: 'Comprar para el desayuno',
          priority: 3,
          updatedAt: DateTime(2026, 10, 20),
        ),
      );

      final saved = await local.getNote(1);
      expect(saved, isNotNull);
      expect(saved!.note, 'Comprar para el desayuno');
      expect(saved.priority, 3);
      expect(saved.pendingSync, isTrue);
    });

    test('Guardar dos veces el mismo producto actualiza sin duplicar', () async {
      await local.saveNote(
        ProductNote(
          productId: 1,
          note: 'Primera nota',
          priority: 2,
          updatedAt: DateTime(2026, 10, 20),
        ),
      );
      await local.saveNote(
        ProductNote(
          productId: 1,
          note: 'Nota editada',
          priority: 5,
          updatedAt: DateTime(2026, 10, 21),
        ),
      );

      final rows = await database.select(database.productNotes).get();
      expect(rows.length, 1);
      expect(rows.first.note, 'Nota editada');
      expect(rows.first.priority, 5);
    });

    test('Un producto sin nota guardada retorna null', () async {
      expect(await local.getNote(99), isNull);
    });
  });

  group('Repository offline-first', () {
    test('No guarda si la prioridad es menor que 2', () async {
      await expectLater(
        repository.saveNote(1, 'Nota', 1),
        throwsA(isA<InvalidPriorityException>()),
      );
      expect(await local.getNote(1), isNull);
    });

    test('Si Firestore responde bien, queda sincronizado', () async {
      final result = await repository.saveNote(1, 'Nota', 4);

      expect(result.synced, isTrue);
      expect(result.note.pendingSync, isFalse);
      expect(remote.sentIds, [1]);
    });

    test('Si Firebase falla, la nota sigue local y pendiente', () async {
      remote.shouldFail = true;

      final result = await repository.saveNote(1, 'Nota offline', 3);

      expect(result.synced, isFalse);
      final saved = await local.getNote(1);
      expect(saved!.note, 'Nota offline');
      expect(saved.pendingSync, isTrue);
    });

    test('Sincronizar envía solo los pendientes y los marca como sincronizados',
        () async {
      // Producto 1 ya sincronizado
      await repository.saveNote(1, 'Sincronizada', 2);

      // Productos 2 y 3 quedan pendientes por fallo remoto
      remote.shouldFail = true;
      await repository.saveNote(2, 'Pendiente A', 3);
      await repository.saveNote(3, 'Pendiente B', 4);

      remote.shouldFail = false;
      remote.sentIds.clear();
      final result = await repository.syncPending();

      expect(result.syncedCount, 2);
      expect(result.pendingCount, 0);
      expect(remote.sentIds, unorderedEquals([2, 3]));
      expect(await local.getPendingNotes(), isEmpty);
    });

    test('Sin Firebase disponible, todo queda pendiente', () async {
      final offlineRepository = ProductRepository(
        productService: ProductService('http://localhost'),
        local: local,
      );

      final result = await offlineRepository.saveNote(1, 'Nota', 2);
      final sync = await offlineRepository.syncPending();

      expect(result.synced, isFalse);
      expect(sync.syncedCount, 0);
      expect(sync.pendingCount, 1);
    });
  });
}
