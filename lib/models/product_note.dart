class ProductNote {
  final int productId;
  final String note;
  final int priority;
  final DateTime updatedAt;
  final bool pendingSync;

  const ProductNote({
    required this.productId,
    required this.note,
    required this.priority,
    required this.updatedAt,
    this.pendingSync = true,
  });
}
