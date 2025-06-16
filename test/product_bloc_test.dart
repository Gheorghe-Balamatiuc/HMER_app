import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';
import 'package:hmer_app/models/image.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for Repository to isolate the BLoC tests
class MockRepository extends Mock implements Repository {}

// Mock class for Image to use in tests
class MockImage extends Mock implements Image {}

void main() {
  // Main test group for ProductBloc functionality
  group('ProductBloc', () {
    late Repository repository;
    late Image image;
    late List<Image> images;
    late ProductBloc productBloc;

    // Setup common test dependencies before each test
    setUp(() {
      image = MockImage();
      images = [
        image,
        image,
      ];
      repository = MockRepository();
      when(() => image.image).thenReturn(Uint8List.fromList([1, 2, 3]));
      when(() => repository.fetchImages()).thenAnswer((_) async => images);
      productBloc = ProductBloc(repository);
    });

    // Test for the initial state of the BLoC
    test('initial state is correct', () {
      final productBloc = ProductBloc(repository);
      expect(productBloc.state, ProductInitial());
    });

    // Test group for ProductFetched event
    group('ProductFetched', () {
      // Test that fetchImages is called when ProductFetched event is added
      blocTest(
        'calls fetchImages when ProductFetched', 
        build: () => productBloc,
        act: (bloc) => bloc.add(ProductFetched()),
        verify: (_) {
          verify(() => repository.fetchImages()).called(1);
        }
      );

      // Test error handling when fetchImages throws an exception
      blocTest(
        'emits [ProductLoading, ProductFailure] when fetchImages throws',
        setUp: () {
          when(() => repository.fetchImages()).thenThrow(Exception('Error'));
        },
        build: () => productBloc,
        act: (bloc) => bloc.add(ProductFetched()),
        expect: () => [
          ProductLoading(),
          ProductFailure(),
        ],
      );

      // Test successful fetch of images
      blocTest(
        'emits [ProductLoading, ProductSuccess] with images when fetchImages succeeds',
        build: () => productBloc,
        act: (bloc) => bloc.add(ProductFetched()),
        expect: () => [
          ProductLoading(),
          ProductSuccess(images: images),
        ],
      );
    });

    // Test group for ProductRefreshed event
    group('ProductRefreshed', () {
      // Test that fetchImages is not called when state is not ProductSuccess
      blocTest(
        'does not call fetchImages when state is not ProductSuccess',
        build: () => productBloc,
        act: (bloc) => bloc.add(ProductRefreshed()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => repository.fetchImages());
        },
      );

      // Test that fetchImages is called when state is ProductSuccess
      blocTest<ProductBloc, ProductState>(
        'calls fetchImages when ProductRefreshed and state is ProductSuccess',
        build: () => productBloc,
        seed: () => ProductSuccess(images: images),
        act: (bloc) => bloc.add(ProductRefreshed()),
        verify: (_) {
          verify(() => repository.fetchImages()).called(1);
        },
      );

      // Test error handling when fetchImages throws an exception during refresh
      blocTest<ProductBloc, ProductState>(
        'emits nothing when fetchImages throws',
        setUp: () {
          when(() => repository.fetchImages()).thenThrow(Exception('Error'));
        },
        build: () => productBloc,
        seed: () => ProductSuccess(images: images),
        act: (bloc) => bloc.add(ProductRefreshed()),
        expect: () => [],
      );

      // Test successful refresh of images
      blocTest<ProductBloc, ProductState>(
        'emits [ProductSuccess] with new images when fetchImages succeeds',
        build: () => productBloc,
        seed: () => ProductSuccess(images: []),
        act: (bloc) => bloc.add(ProductRefreshed()),
        expect: () => [
          ProductSuccess(images: images),
        ],
      );
    });
  });
}