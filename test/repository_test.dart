import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/api/api.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/models/image.dart';
import 'package:hmer_app/models/product.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for testing
class MockApiClient extends Mock implements ApiService {}

class MockImage extends Mock implements Image {}

class MockProduct extends Mock implements Product {}

class FakeProduct extends Fake implements Product {}

void main() {
  // Main test group for Repository tests
  group('Repository', () {
    late ApiService apiClient;
    late Repository repository;

    // Setup common test dependencies before each test
    setUp(() {
      apiClient = MockApiClient();
      repository = Repository(apiClient: apiClient);
    });

    // Test the constructor behavior
    group('Constructor', () {
      test('does not require an ApiService', () {
        expect(Repository(), isNotNull);
      });
    });

    // Test the fetchImages method
    group('fetchImages', () {
      // Test that fetchProducts is called
      test('calls fetchProducts', () async {
        try {
          await repository.fetchImages();
        } catch (_) {}
        verify(() => apiClient.fetchProducts()).called(1);
      });

      // Test exception handling when fetchProducts fails
      test('throws when fetchProducts fails', () {
        final exception = Exception('Failed to fetch products');
        when(() => apiClient.fetchProducts()).thenThrow(exception);
        expect(
          () async => await repository.fetchImages(),
          throwsA(exception),
        );
      });

      // Test that fetchImage is called with the correct product
      test('calls fetchImage with correct name', () async {
        registerFallbackValue(FakeProduct());
        final product = MockProduct();
        when(() => product.image).thenReturn('test_image.jpg');
        when(() => product.id).thenReturn(0);
        when(() => apiClient.fetchProducts()).thenAnswer((_) async => [product]);
        
        try {
          await repository.fetchImages();
        } catch (_) {}
        
        verify(() => apiClient.fetchImage(product)).called(1);
      });

      // Test exception handling when fetchImage fails
      test('throws when fetchImage fails', () async {
        final exception = Exception('Failed to fetch image');
        final product = MockProduct();
        when(() => product.image).thenReturn('test_image.jpg');
        when(() => product.id).thenReturn(0);
        when(() => apiClient.fetchProducts()).thenAnswer((_) async => [product]);
        when(() => apiClient.fetchImage(product)).thenThrow(exception);
        expect(
          () async => await repository.fetchImages(),
          throwsA(exception),
        );
      });

      // Test that fetchImages returns the correct list of images
      test('returns correct list of images', () async {
        final product = MockProduct();
        final image = MockImage();
        when(() => product.image).thenReturn('test_image.jpg');
        when(() => product.id).thenReturn(0);
        when(() => image.id).thenReturn(0);
        when(() => image.image).thenReturn(Uint8List.fromList([1, 2, 3]));
        when(() => apiClient.fetchProducts()).thenAnswer((_) async => [product, product]);
        when(() => apiClient.fetchImage(product)).thenAnswer((_) async => image);

        final images = await repository.fetchImages();

        expect(images, isA<List<Image>>());
        expect(images.length, 2);
        expect(images[0], isA<Image>().having((image) => image.image, 'image', Uint8List.fromList([1, 2, 3])));
        expect(images[1], isA<Image>().having((image) => image.image, 'image', Uint8List.fromList([1, 2, 3])));
      });
    });

    // Test the dispose method
    group('dispose', () {
      test('calls close on ApiService', () {
        repository.dispose();
        verify(() => apiClient.close()).called(1);
      });
    });
  });
}