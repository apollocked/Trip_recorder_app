class Trip {
  final String title;
  final String price;
  final String nights;
  final String img;
  final DateTime date;
  final String description;
  bool isLiked;

  Trip({
    required this.title,
    required this.price,
    required this.nights,
    required this.img,
    required this.date,
    this.description = '',
    this.isLiked = false,
  });

  // Convert Trip to Map for JSON storage
  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
    'nights': nights,
    'img': img,
    'date': date.toIso8601String(),
    'description': description,
    'isLiked': isLiked,
  };

  // Create Trip from JSON
  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    title: json['title'],
    price: json['price'],
    nights: json['nights'],
    img: json['img'],
    date: DateTime.parse(json['date']),
    description: json['description'] ?? '',
    isLiked: json['isLiked'] ?? false,
  );
}
