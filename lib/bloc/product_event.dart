import 'dart:typed_data';

/// Base class for all product-related events
sealed class ProductEvent {
  const ProductEvent();
}

/// Event to fetch products from the repository
/// This is typically used when loading products for the first time
final class ProductFetched extends ProductEvent {
  const ProductFetched();
}

/// Event to refresh the current list of products
/// This is typically used when pulling to refresh
final class ProductRefreshed extends ProductEvent {
  const ProductRefreshed();
}

/// Event to add a new product by uploading an image
final class ProductAdded extends ProductEvent {
  const ProductAdded(this.image, this.name);

  /// The binary data of the image to upload
  final Uint8List image;

  /// The filename of the image
  final String name;
}

/// Event to delete a product with the specified ID
final class ProductDeleted extends ProductEvent {
  const ProductDeleted(this.id);

  /// The ID of the product to delete
  final int id;
}