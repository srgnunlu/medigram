import 'package:equatable/equatable.dart';

class MedicalCard extends Equatable {
  final int id;
  final String title;
  final String content;
  final String category;
  final String subcategory;
  final String imageUrl;
  final String thumbnail;
  final String source;
  final String author;
  final String? aiImagePrompt;
  final List<String> likes;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicalCard({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.thumbnail,
    required this.source,
    required this.author,
    this.aiImagePrompt,
    required this.likes,
    required this.commentCount,
    required this.shareCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalCard.fromJson(Map<String, dynamic> json) {
    // Handle Strapi response format
    final data = json['attributes'] ?? json;

    return MedicalCard(
      id: json['id'] ?? 0,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      source: data['source'] ?? '',
      author: data['author'] ?? '',
      aiImagePrompt: data['aiImagePrompt'],
      likes: _parseLikes(data['likes']),
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static List<String> _parseLikes(dynamic likes) {
    if (likes == null) return [];
    if (likes is String) {
      try {
        // Parse JSON string
        final decoded = likes;
        if (decoded.startsWith('[')) {
          return List<String>.from(
            (decoded as String)
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .where((s) => s.isNotEmpty),
          );
        }
      } catch (e) {
        return [];
      }
    }
    if (likes is List) {
      return List<String>.from(likes.map((e) => e.toString()));
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'subcategory': subcategory,
      'imageUrl': imageUrl,
      'thumbnail': thumbnail,
      'source': source,
      'author': author,
      'aiImagePrompt': aiImagePrompt,
      'likes': likes,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MedicalCard copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    String? subcategory,
    String? imageUrl,
    String? thumbnail,
    String? source,
    String? author,
    String? aiImagePrompt,
    List<String>? likes,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalCard(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      source: source ?? this.source,
      author: author ?? this.author,
      aiImagePrompt: aiImagePrompt ?? this.aiImagePrompt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
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
        title,
        content,
        category,
        subcategory,
        imageUrl,
        thumbnail,
        source,
        author,
        aiImagePrompt,
        likes,
        commentCount,
        shareCount,
        createdAt,
        updatedAt,
      ];
}
