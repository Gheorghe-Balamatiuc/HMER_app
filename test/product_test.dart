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
              'id': 1,
              'imagePrediction': 'test_prediction',
            },
          ),
          isA<Product>()
              .having((p) => p.image, '', 'test_image.png')
              .having((p) => p.id, '', 1)
            .having((p) => p.imagePrediction, '', 'test_prediction'),
        );
      });
    });
  });
}