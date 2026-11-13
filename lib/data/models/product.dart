class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    this.brand = '',
    this.images = const [],
    this.isLocal = false,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String thumbnail;
  final String brand;
  final List<String> images;
  final bool isLocal;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? 'Untitled product',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isLocal: json['isLocal'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'rating': rating,
        'stock': stock,
        'thumbnail': thumbnail,
        'brand': brand,
        'images': images,
        'isLocal': isLocal,
      };

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? rating,
    int? stock,
    String? thumbnail,
    String? brand,
    List<String>? images,
    bool? isLocal,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      thumbnail: thumbnail ?? this.thumbnail,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
