class Product {
  const Product({
    required this.image,
  });

  final String image;

  factory Product.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'image': String image,
      } => Product(
        image: image
      ),
      _ => throw const FormatException('Invalid JSON format for Product'),
    };
  }
}