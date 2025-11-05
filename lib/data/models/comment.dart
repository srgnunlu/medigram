import 'package:equatable/equatable.dart';
import 'package:medigram/data/models/user.dart';

class Comment extends Equatable {
  final int id;
  final String content;
  final User? author;
  final int? medicalCardId;
  final int? parentCommentId;
  final List<Comment> replies;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.content,
    this.author,
    this.medicalCardId,
    this.parentCommentId,
    this.replies = const [],
    this.likes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final data = json['attributes'] ?? json;

    // Parse author
    User? author;
    if (data['author'] != null) {
      if (data['author'] is Map) {
        final authorData = data['author']['data'] ?? data['author'];
        if (authorData is Map) {
          author = User.fromJson(authorData);
        }
      }
    }

    // Parse replies
    List<Comment> replies = [];
    if (data['replies'] != null) {
      if (data['replies'] is Map && data['replies']['data'] != null) {
        final repliesData = data['replies']['data'];
        if (repliesData is List) {
          replies = repliesData.map((item) => Comment.fromJson(item)).toList();
        }
      } else if (data['replies'] is List) {
        replies = (data['replies'] as List)
            .map((item) => Comment.fromJson(item))
            .toList();
      }
    }

    // Parse likes
    List<String> likes = [];
    if (data['likes'] != null) {
      if (data['likes'] is String) {
        try {
          likes = (data['likes'] as String)
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList();
        } catch (e) {
          likes = [];
        }
      } else if (data['likes'] is List) {
        likes = List<String>.from(data['likes'].map((e) => e.toString()));
      }
    }

    return Comment(
      id: json['id'] ?? 0,
      content: data['content'] ?? '',
      author: author,
      medicalCardId: data['medicalCard']?['id'],
      parentCommentId: data['parentComment']?['id'],
      replies: replies,
      likes: likes,
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        data['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author?.toJson(),
      'medicalCardId': medicalCardId,
      'parentCommentId': parentCommentId,
      'replies': replies.map((r) => r.toJson()).toList(),
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Comment copyWith({
    int? id,
    String? content,
    User? author,
    int? medicalCardId,
    int? parentCommentId,
    List<Comment>? replies,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      medicalCardId: medicalCardId ?? this.medicalCardId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  @override
  List<Object?> get props => [
        id,
        content,
        author,
        medicalCardId,
        parentCommentId,
        replies,
        likes,
        createdAt,
        updatedAt,
      ];
}
