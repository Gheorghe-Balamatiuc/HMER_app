import 'package:hmer_app/models/image.dart';
import 'package:equatable/equatable.dart';

/// Base class for all product-related states
sealed class ProductState extends Equatable {
  const ProductState();
}

/// Initial state when the product bloc is created
final class ProductInitial extends ProductState {
  const ProductInitial();

  @override
  List<Object?> get props => [];
}

/// State when products are being loaded
final class ProductLoading extends ProductState {
  const ProductLoading();

  @override
  List<Object?> get props => [];
}

/// State when products have been successfully loaded
final class ProductSuccess extends ProductState {
  const ProductSuccess({
    required this.images,
  });

  /// The list of images that were loaded
  final List<Image> images;

  @override
  List<Object?> get props => [images];
}

/// State when there was an error loading products
final class ProductFailure extends ProductState {
  const ProductFailure();

  @override
  List<Object?> get props => [];
}