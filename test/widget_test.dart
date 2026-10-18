import 'package:flutter_test/flutter_test.dart';
import 'package:taller_movil/models/product.dart';
import 'package:taller_movil/widgets/product_card.dart';

void main() {
  group('Pruebas unitarias de modelo y formateo', () {
    test('Product.fromJson parsea correctamente tipos numéricos a double', () {
      final json = {
        'id': 1,
        'name': 'Café de Huila Especial 500 g',
        'category': 'Café',
        'price': 38000,
        'image': 'https://picsum.photos/seed/cafe/600/600',
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'Café de Huila Especial 500 g');
      expect(product.category, 'Café');
      expect(product.price, 38000.0);
      expect(product.image, 'https://picsum.photos/seed/cafe/600/600');
    });

    test('ProductCard.formatCop formatea precios con separador de miles en COP', () {
      expect(ProductCard.formatCop(8500), '\$ 8.500');
      expect(ProductCard.formatCop(38000), '\$ 38.000');
      expect(ProductCard.formatCop(180000), '\$ 180.000');
    });
  });
}
