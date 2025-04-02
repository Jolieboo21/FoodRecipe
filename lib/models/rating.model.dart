class Rating {
  final int id;
  final int recipeId; // ID của công thức được đánh giá
  final int userId; // ID của người dùng đánh giá
  final double score; // Điểm đánh giá
  final String comment; // Nhận xét của người dùng

  Rating({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.score,
    required this.comment,
  });
}
