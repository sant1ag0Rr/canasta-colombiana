import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_note.dart';

class ProductNoteRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductNoteRemoteDataSource(this.firestore);

  // Usa el productId como ID del documento para que reenviar
  // la misma nota actualice el documento en vez de duplicarlo
  Future<void> upsertNote(ProductNote note) async {
    await firestore
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
  }
}
