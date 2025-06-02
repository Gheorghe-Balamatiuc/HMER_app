import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/api/api.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/models/image.dart';
import 'package:hmer_app/models/product.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiService {}

class MockImage extends Mock implements Image {}

class MockProduct extends Mock implements Product {}

void main() {
  group('Repository', () {
    late ApiService apiClient;
    late Repository repository;

    setUp(() {
      apiClient = MockApiClient();
      repository = Repository(apiClient: apiClient);
    });

    group('Constructor', () {
      test('does not require an ApiService', () {
        expect(Repository(), isNotNull);
      });
    });

    group('fetchImages', () {
      test('calls fetchProducts', () async {
        try {
          await repository.fetchImages();
        } catch (_) {}
        verify(() => apiClient.fetchProducts()).called(1);
      });

      test('throws when fetchProducts fails', () {
        final exception = Exception('Failed to fetch products');
        when(() => apiClient.fetchProducts()).thenThrow(exception);
        expect(
          () async => await repository.fetchImages(),
          throwsA(exception),
        );
      });

      test('calls fetchImage with correct name', () async {
        final product = MockProduct();
        when(() => product.image).thenReturn('test_image.jpg');
        when(() => apiClient.fetchProducts()).thenAnswer((_) async => [product]);
        try {
          await repository.fetchImages();
        } catch (_) {}
        verify(() => apiClient.fetchImage('test_image.jpg')).called(1);
      });

      test('throws when fetchImage fails', () async {
        final exception = Exception('Failed to fetch image');
        final product = MockProduct();
        when(() => product.image).thenReturn('test_image.jpg');
        when(() => apiClient.fetchProducts()).thenAnswer((_) async => [product]);
        when(() => apiClient.fetchImage('test_image.jpg')).thenThrow(exception);
        expect(
          () async => await repository.fetchImages(),
          throwsA(exception),
        );
      });

      test('returns correct list of images', () async {
        final product = MockProduct();
        final image = MockImage();
        when(() => product.image).thenReturn('test_image.jpg');
        when(() => image.image).thenReturn(Uint8List.fromList([1, 2, 3]));
        when(() => apiClient.fetchProducts()).thenAnswer((_) async => [product, product]);
        when(() => apiClient.fetchImage('test_image.jpg')).thenAnswer((_) async => image);

        final images = await repository.fetchImages();

        expect(images, isA<List<Image>>());
        expect(images.length, 2);
        expect(images[0], isA<Image>().having((image) => image.image, 'image', Uint8List.fromList([1, 2, 3])));
        expect(images[1], isA<Image>().having((image) => image.image, 'image', Uint8List.fromList([1, 2, 3])));
      });
    });

    group('dispose', () {
      test('calls close on ApiService', () {
        repository.dispose();
        verify(() => apiClient.close()).called(1);
      });
    });
  });
}