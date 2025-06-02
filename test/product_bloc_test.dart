import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';
import 'package:hmer_app/models/image.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

class MockImage extends Mock implements Image {}

void main() {
  group('ProductBloc', () {
    late Repository repository;
    late Image image;
    late List<Image> images;
    late ProductBloc productBloc;

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

    test('initial state is correct', () {
      final productBloc = ProductBloc(repository);
      expect(productBloc.state, ProductInitial());
    });

    group('ProductFetched', () {
      blocTest(
        'calls fetchImages when ProductFetched', 
        build: () => productBloc,
        act: (bloc) => bloc.add(ProductFetched()),
        verify: (_) {
          verify(() => repository.fetchImages()).called(1);
        }
      );

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

    group('ProductRefreshed', () {
      blocTest(
        'does not call fetchImages when state is not ProductSuccess',
        build: () => productBloc,
        act: (bloc) => bloc.add(ProductRefreshed()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => repository.fetchImages());
        },
      );

      blocTest<ProductBloc, ProductState>(
        'calls fetchImages when ProductRefreshed and state is ProductSuccess',
        build: () => productBloc,
        seed: () => ProductSuccess(images: images),
        act: (bloc) => bloc.add(ProductRefreshed()),
        verify: (_) {
          verify(() => repository.fetchImages()).called(1);
        },
      );

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