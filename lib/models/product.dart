class Product {
  const Product({
    required this.image,
    required this.id,
    required this.imagePrediction,
  });

  final String image;
  final int id;
  final String imagePrediction;

  factory Product.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'image': String image,
        'id': int id,
        'imagePrediction': String imagePrediction,
      } => Product(
        image: image,
        id: id,
        imagePrediction: imagePrediction,
      ),
      _ => throw const FormatException('Invalid JSON format for Product'),
    };
  }
}