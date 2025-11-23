enum PostType {
  study_buddy,
  event,
  marketplace,
}

class PostModel {
  final String postId;
  final String authorId;
  final PostType type;
  final String title;
  final String description;
  final String location;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.authorId,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['post_id'] ?? '',
      authorId: map['author_id'] ?? '',
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${map['type']}',
        orElse: () => PostType.event,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'post_id': postId,
      'author_id': authorId,
      'type': type.name, // stores as 'study_buddy', etc.
      'title': title,
      'description': description,
      'location': location,
      'created_at': createdAt,
    };
  }
}
