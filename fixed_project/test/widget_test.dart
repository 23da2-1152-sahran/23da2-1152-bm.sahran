import 'package:flutter_test/flutter_test.dart';
import 'package:senior_fashion/models/product.dart';

void main() {
  test('Product maps Firestore data correctly', () {
    final product = Product.fromMap({
      'id': 'sculptural-wool-overcoat',
      'name': 'Sculptural Wool Overcoat',
      'subtitle': 'Oatmeal Melange',
      'price': 480.0,
      'badge': 'NEW',
      'imageUrl': 'assets/sculptural_wool_overcoat.png',
      'collection': "WINTER COLLECTION '24",
      'colors': ['Oatmeal', 'Charcoal'],
      'sizes': ['S', 'M'],
      'description': 'Demo description',
      'category': 'Outerwear',
      'stock': 15,
    });

    expect(product.id, 'sculptural-wool-overcoat');
    expect(product.price, 480.0);
    expect(product.category, 'Outerwear');
    expect(product.toMap()['stock'], 15);
  });
}
