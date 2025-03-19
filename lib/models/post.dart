class Post {
  final String id;
  final String userId;
  final String username;
  final String caption;
  final String? media;
  final List<double> coordinates;
  final String address;
  final String category;
  final List<String> likes;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.caption,
    this.media,
    required this.coordinates,
    required this.address,
    required this.category,
    required this.likes,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      print("📦 Parsing Post JSON: $json");

      return Post(
        id: json['_id'] ?? "unknown_id",
        userId: json['user_id'] is String
            ? json['user_id']
            : json['user_id']?['_id'] ?? "unknown_user",
        username: json['user_id'] is String
            ? "Unknown User"
            : json['user_id']?['username'] ?? "Anonymous",
        caption: json['caption'] ?? "No caption",
        media: json['media'],
        coordinates: json['location']?['coordinates'] != null
            ? List<double>.from(json['location']['coordinates'])
            : [0.0, 0.0], // Handle missing coordinates
        address: json['location']?['address'] ?? "No address",
        category: json['category'] ?? "Uncategorized",
        likes: json['likes'] != null
            ? List<String>.from(json['likes'].map((user) => user['_id']))
            : [],
        createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
      );
    } catch (e) {
      print("❌ Error parsing post JSON: $e");
      return Post(
        id: "unknown",
        userId: "unknown_user",
        username: "Unknown User",
        caption: "Error Loading Post",
        media: null,
        coordinates: [0.0, 0.0],
        address: "No address",
        category: "Uncategorized",
        likes: [],
        createdAt: DateTime.now(),
      );
    }
  }
}
