import 'package:equatable/equatable.dart';

class AIGeneratedImage extends Equatable {
  final String url;
  final String? revisedPrompt;
  final String originalPrompt;
  final DateTime createdAt;

  const AIGeneratedImage({
    required this.url,
    this.revisedPrompt,
    required this.originalPrompt,
    required this.createdAt,
  });

  factory AIGeneratedImage.fromJson(Map<String, dynamic> json) {
    return AIGeneratedImage(
      url: json['url'] ?? '',
      revisedPrompt: json['revised_prompt'],
      originalPrompt: json['original_prompt'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'revised_prompt': revisedPrompt,
      'original_prompt': originalPrompt,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [url, revisedPrompt, originalPrompt, createdAt];
}
