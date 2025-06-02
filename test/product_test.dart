import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/models/product.dart';

void main() {
  group('Product', () {
    group('fromJson', () {
      test('should return a valid Product object when given valid JSON', () {
        expect(
          Product.fromJson(
            <String, dynamic> {
              'image': 'test_image.png',
            },
          ),
          isA<Product>()
              .having((p) => p.image, '', 'test_image.png'),
        );
      });
    });
  });
}