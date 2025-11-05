import 'package:dio/dio.dart';
import 'package:medigram/data/models/comment.dart';
import 'package:medigram/data/services/api_client.dart';

class CommentService {
  final ApiClient _apiClient = ApiClient();

  // Create comment
  Future<Comment> createComment({
    required String content,
    required int medicalCardId,
    int? parentCommentId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/comments',
        data: {
          'content': content,
          'medicalCardId': medicalCardId,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
        },
      );

      if (response.data['success'] == true) {
        return Comment.fromJson(response.data['data']);
      }

      throw response.data['message'] ?? 'Failed to create comment';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get comments for a card
  Future<List<Comment>> getCommentsByCard({
    required int cardId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/comments/card/$cardId',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => Comment.fromJson(item)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update comment
  Future<Comment> updateComment(int id, String content) async {
    try {
      final response = await _apiClient.put(
        '/comments/$id',
        data: {'content': content},
      );

      if (response.data['success'] == true) {
        return Comment.fromJson(response.data['data']);
      }

      throw response.data['message'] ?? 'Failed to update comment';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete comment
  Future<void> deleteComment(int id) async {
    try {
      await _apiClient.delete('/comments/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Toggle like on comment
  Future<Map<String, dynamic>> toggleLike(int commentId) async {
    try {
      final response = await _apiClient.post('/comments/$commentId/like');

      if (response.data['success'] == true) {
        return response.data['data'];
      }

      throw 'Failed to toggle like';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          final errorData = data['error'];
          if (errorData is Map && errorData.containsKey('message')) {
            return errorData['message'].toString();
          }
          return errorData.toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return 'An error occurred: ${error.response!.statusCode}';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
