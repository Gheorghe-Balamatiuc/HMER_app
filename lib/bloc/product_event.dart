import 'dart:typed_data';

sealed class ProductEvent {
  const ProductEvent();
}

final class ProductFetched extends ProductEvent {
  const ProductFetched();
}

final class ProductRefreshed extends ProductEvent {
  const ProductRefreshed();
}

final class ProductAdded extends ProductEvent {
  const ProductAdded(this.image, this.name);

  final Uint8List image;
  final String name;
}