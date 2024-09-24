class Product {
  final int id;
  final String title;
  final double price;
  final String? image;
  final String description;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.image, 
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0, 
      title: json['title'] ?? '', 
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : double.parse(json['price']?.toString() ?? '0'),
      image: json['image'], 
      description: json['description'] ?? '',  
    );
  }
}