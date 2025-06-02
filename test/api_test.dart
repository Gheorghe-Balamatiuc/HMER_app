import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/api/api.dart';
import 'package:hmer_app/models/image.dart';
import 'package:hmer_app/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('ApiService', () {
    late http.Client httpClient;
    late ApiService apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = ApiService(httpClient: httpClient);
    });

    group('Constructor', () {
      test('does not require an httpClient', () {
        expect(ApiService(), isNotNull);
      });
    });    

    group('fetchProducts', () {
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.fetchProducts();
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.parse('https://localhost:7005/Product'),
          ),
        ).called(1);
      });

      test('throws Exception on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await apiClient.fetchProducts(),
          throwsA(isA<Exception>()),
        );
      });

      test('returns image list on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
[
  {
    "image": "2d3eb689-c73f-4d8f-8259-88d0a7f57235.jpg"
  },
  {
    "image": "de657f10-2cbc-4308-af98-902797c847a4.png"
  },
  {
    "image": "cb75b3a7-a4b4-4977-b6cf-36de71b1b86e.png"
  }
]
''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final products = await apiClient.fetchProducts();
        expect(products, isA<List<Product>>());
        expect(products.length, 3);
        expect(products[0], 
          isA<Product>()
              .having((p) => p.image, 'image', '2d3eb689-c73f-4d8f-8259-88d0a7f57235.jpg'),
        );
        expect(products[1], 
          isA<Product>()
              .having((p) => p.image, 'image', 'de657f10-2cbc-4308-af98-902797c847a4.png'),
        );
        expect(products[2], 
          isA<Product>()
              .having((p) => p.image, 'image', 'cb75b3a7-a4b4-4977-b6cf-36de71b1b86e.png'),
        );
      });
    });

    group('fetchImage', () {
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.bodyBytes).thenReturn(Uint8List(0));
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.fetchImage('test.jpg');
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.parse('https://localhost:7005/resources/test.jpg'),
          ),
        ).called(1);
      });

      test('throws Exception on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await apiClient.fetchImage('test.jpg'),
          throwsA(isA<Exception>()),
        );
      });

      test('returns Image on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.bodyBytes).thenReturn(Uint8List.fromList([1, 2, 3]));
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final image = await apiClient.fetchImage('test.jpg');
        expect(
          image, 
          isA<Image>()
              .having((i) => i.image, 'image', Uint8List.fromList([1, 2, 3])),
        );
      });
    });

    group('close', () {
      test('closes the http client', () {
        apiClient.close();
        verify(() => httpClient.close()).called(1);
      });
    });
  });
}