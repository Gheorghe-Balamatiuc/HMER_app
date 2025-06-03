class Product {
  const Product({
    required this.image,
    required this.id,
  });

  final String image;
  final int id;

  factory Product.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'image': String image,
        'id': int id,
      } => Product(
        image: image,
        id: id,
      ),
      _ => throw const FormatException('Invalid JSON format for Product'),
    };
  }
}