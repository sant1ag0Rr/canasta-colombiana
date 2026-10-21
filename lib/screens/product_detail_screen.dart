import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_note.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductRepository repository;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.repository,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  int? _selectedPriority;
  ProductNote? _savedNote;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final note = await widget.repository.getNote(widget.product.id);
    if (!mounted) return;

    setState(() {
      _savedNote = note;
      if (note != null) {
        _noteController.text = note.note;
        _selectedPriority = note.priority;
      }
      _isLoading = false;
    });
  }

  Future<void> _handleSave() async {
    // Regla de validación: solo se guarda si la prioridad es 2 o mayor
    if (_selectedPriority == null || _selectedPriority! < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La prioridad debe ser 2 o más para guardar'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await widget.repository.saveNote(
        widget.product.id,
        _noteController.text.trim(),
        _selectedPriority!,
      );

      if (!mounted) return;

      setState(() {
        _savedNote = result.note;
        _isSaving = false;
      });

      final message = result.synced
          ? 'Nota guardada y sincronizada con Firestore'
          : 'Nota guardada localmente (pendiente de sincronización)';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result.synced ? Colors.teal : Colors.amber.shade800,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildSyncStatusBadge(ColorScheme colors) {
    String label;
    IconData icon;
    Color bgColor;
    Color textColor;

    if (_savedNote == null) {
      label = 'Aún no hay información guardada';
      icon = Icons.info_outline;
      bgColor = colors.surfaceContainerHighest;
      textColor = colors.onSurfaceVariant;
    } else if (_savedNote!.pendingSync) {
      label = 'Pendiente';
      icon = Icons.cloud_upload_outlined;
      bgColor = Colors.amber.shade100;
      textColor = Colors.amber.shade900;
    } else {
      label = 'Sincronizado';
      icon = Icons.check_circle_outline;
      bgColor = Colors.teal.shade100;
      textColor = Colors.teal.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Encabezado del producto
                        Card(
                          elevation: 1,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.network(
                                widget.product.image,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 220,
                                    color: colors.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 64,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            widget.product.category,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: colors.onSecondaryContainer,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          ProductCard.formatCop(
                                            widget.product.price,
                                          ),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.product.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sección de persistencia y notas personales
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estado de sincronización',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildSyncStatusBadge(colors),

                                const Divider(height: 32),

                                const Text(
                                  'Prioridad de compra (1 a 5)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Solo se permite guardar si la prioridad es 2 o más.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: List.generate(5, (index) {
                                    final priorityValue = index + 1;
                                    final isSelected =
                                        _selectedPriority == priorityValue;
                                    return ChoiceChip(
                                      label: Text('Prioridad $priorityValue'),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedPriority =
                                              selected ? priorityValue : null;
                                        });
                                      },
                                    );
                                  }),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Nota personal',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _noteController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Escribe una nota o recordatorio sobre este producto...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: _isSaving ? null : _handleSave,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(
                                      _isSaving ? 'Guardando...' : 'Guardar',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
