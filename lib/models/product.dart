class Product {
  const Product({
    required this.image,
    required this.id,
    required this.imagePrediction,
    required this.predictionDescription,
  });

  final String image;
  final int id;
  final String imagePrediction;
  final String predictionDescription;

  factory Product.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'image': String image,
        'id': int id,
        'imagePrediction': String imagePrediction,
        'predictionDescription': String predictionDescription,
      } => Product(
        image: image,
        id: id,
        imagePrediction: imagePrediction,
        predictionDescription: predictionDescription,
      ),
      _ => throw const FormatException('Invalid JSON format for Product'),
    };
  }
}