import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'database/app_database.dart';
import 'firebase_options.dart';
import 'local/product_note_local_data_source.dart';
import 'remote/product_note_remote_data_source.dart';
import 'repositories/product_repository.dart';
import 'screens/product_list_screen.dart';
import 'services/product_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseFirestore? firestore;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firestore = FirebaseFirestore.instance;
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  // Instancias únicas compartidas de base de datos, fuentes de datos, servicio y repositorio
  final database = AppDatabase();
  final local = ProductNoteLocalDataSource(database);
  final remote =
      firestore == null ? null : ProductNoteRemoteDataSource(firestore);
  final productService = ProductService(kProductsUrl);
  final productRepository = ProductRepository(
    productService: productService,
    local: local,
    remote: remote,
  );

  runApp(MyApp(repository: productRepository));
}

class MyApp extends StatelessWidget {
  final ProductRepository repository;

  const MyApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canasta colombiana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
      ),
      home: ProductListScreen(repository: repository),
    );
  }
}
