import 'package:hmer_app/models/image.dart';
import 'package:equatable/equatable.dart';

sealed class ProductState extends Equatable {
  const ProductState();
}

final class ProductInitial extends ProductState {
  const ProductInitial();

  @override
  List<Object?> get props => [];
}

final class ProductLoading extends ProductState {
  const ProductLoading();

  @override
  List<Object?> get props => [];
}

final class ProductSuccess extends ProductState {
  const ProductSuccess({
    required this.images,
  });

  final List<Image> images;

  @override
  List<Object?> get props => [images];
}

final class ProductFailure extends ProductState {
  const ProductFailure();

  @override
  List<Object?> get props => [];
}