class Trip {
  final String title;
  final String price;
  final String nights;
  final String img;
  final DateTime date;
  bool isLiked;

  Trip({
    required this.title,
    required this.price,
    required this.nights,
    required this.img,
    required this.date,
    this.isLiked = false,
  });
}
