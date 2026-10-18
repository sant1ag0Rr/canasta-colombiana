import 'package:flutter/material.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final ProductRepository repository;

  const ProductListScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _futureProducts;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _futureProducts = widget.repository.fetchProducts();
  }

  void _retryProductsList() {
    setState(() {
      _futureProducts = widget.repository.fetchProducts();
    });
  }

  Future<void> _syncPendingNotes() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await widget.repository.syncPending();
      if (!mounted) return;

      String message;
      Color bgColor;

      if (result.syncedCount == 0 && result.pendingCount == 0) {
        message = 'No hay registros pendientes';
        bgColor = Colors.blueGrey;
      } else if (result.syncedCount > 0 && result.pendingCount == 0) {
        message = result.syncedCount == 1
            ? 'Se sincronizó 1 registro'
            : 'Se sincronizaron ${result.syncedCount} registros';
        bgColor = Colors.teal;
      } else if (result.syncedCount == 0 && result.pendingCount > 0) {
        message = result.pendingCount == 1
            ? 'No se pudo sincronizar: 1 registro sigue pendiente'
            : 'No se pudo sincronizar: ${result.pendingCount} registros siguen pendientes';
        bgColor = Colors.redAccent;
      } else {
        message =
            'Se sincronizaron ${result.syncedCount} registros, pero ${result.pendingCount} siguen pendientes';
        bgColor = Colors.amber.shade800;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: bgColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error durante la sincronización: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        titleSpacing: 12,
        title: const Text(
          'Canasta colombiana',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: _isSyncing ? null : _syncPendingNotes,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync, size: 18),
              label: const Text(
                'Sincronizar pendientes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        // Estado 1: Carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Estado 2: Error
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _retryProductsList,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];

        // Estado 3: Lista vacía
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles en este momento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado 4: Datos
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => _openDetail(product),
            );
          },
        );
      },
    );
  }
}
