/// Represents a product from the API
/// Contains metadata about an image but not the image data itself
class Product {
  const Product({
    required this.image,
    required this.id,
    required this.imagePrediction,
    required this.predictionDescription,
  });

  /// The filename of the image
  final String image;
  
  /// The unique identifier of the product
  final int id;
  
  /// The LaTeX representation of the mathematical expression in the image
  final String imagePrediction;
  
  /// A textual description of the mathematical expression
  final String predictionDescription;

  /// Creates a Product from a JSON map
  /// Throws a FormatException if the JSON is invalid
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