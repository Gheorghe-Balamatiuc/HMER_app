import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/models/product.dart';

void main() {
  // Test group for Product class functionality
  group('Product', () {
    // Tests for the fromJson factory method
    group('fromJson', () {
      // Test that valid JSON can be correctly parsed into a Product object
      test('should return a valid Product object when given valid JSON', () {
        expect(
          Product.fromJson(
            <String, dynamic> {
              'image': 'test_image.png',
              'id': 1,
              'imagePrediction': 'test_prediction',
              'predictionDescription': 'test_description',
            },
          ),
          isA<Product>()
              .having((p) => p.image, '', 'test_image.png')
              .having((p) => p.id, '', 1)
              .having((p) => p.imagePrediction, '', 'test_prediction')
              .having((p) => p.predictionDescription, '', 'test_description'),
        );
      });
    });
  });
}