import 'package:get/get.dart';
import 'package:medigram/data/models/comment.dart';
import 'package:medigram/data/services/comment_service.dart';
import 'package:medigram/data/services/auth_service.dart';
import 'package:medigram/core/utils/snackbar_helper.dart';

class CommentController extends GetxController {
  final CommentService _commentService = CommentService();
  final AuthService _authService = AuthService();

  final RxList<Comment> _comments = <Comment>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxInt _currentPage = 1.obs;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isSubmitting => _isSubmitting.value;

  // Fetch comments for a card
  Future<void> fetchComments(int cardId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _isLoading.value = true;
        _currentPage.value = 1;
        _comments.clear();
      } else if (_currentPage.value == 1) {
        _isLoading.value = true;
      } else {
        _isLoadingMore.value = true;
      }

      final fetchedComments = await _commentService.getCommentsByCard(
        cardId: cardId,
        page: _currentPage.value,
      );

      if (refresh || _currentPage.value == 1) {
        _comments.value = fetchedComments;
      } else {
        _comments.addAll(fetchedComments);
      }

      if (fetchedComments.isNotEmpty) {
        _currentPage.value++;
      }
    } catch (e) {
      SnackbarHelper.showError('Yorumlar yüklenemedi: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  // Create comment
  Future<bool> createComment({
    required int cardId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      _isSubmitting.value = true;

      final comment = await _commentService.createComment(
        content: content,
        medicalCardId: cardId,
        parentCommentId: parentCommentId,
      );

      if (parentCommentId == null) {
        _comments.insert(0, comment);
      } else {
        // Add reply to parent comment
        final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
        if (parentIndex != -1) {
          final parent = _comments[parentIndex];
          final updatedReplies = List<Comment>.from(parent.replies)..add(comment);
          _comments[parentIndex] = parent.copyWith(replies: updatedReplies);
        }
      }

      SnackbarHelper.showSuccess('Yorum eklendi!');
      return true;
    } catch (e) {
      SnackbarHelper.showError('Yorum eklenemedi: ${e.toString()}');
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Update comment
  Future<void> updateComment(int commentId, String newContent) async {
    try {
      final updatedComment = await _commentService.updateComment(commentId, newContent);

      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
      }

      SnackbarHelper.showSuccess('Yorum güncellendi!');
    } catch (e) {
      SnackbarHelper.showError('Yorum güncellenemedi: ${e.toString()}');
    }
  }

  // Delete comment
  Future<void> deleteComment(int commentId) async {
    try {
      await _commentService.deleteComment(commentId);
      _comments.removeWhere((c) => c.id == commentId);
      SnackbarHelper.showSuccess('Yorum silindi!');
    } catch (e) {
      SnackbarHelper.showError('Yorum silinemedi: ${e.toString()}');
    }
  }

  // Toggle like on comment
  Future<void> toggleLike(int commentId) async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        SnackbarHelper.showWarning('Beğenmek için giriş yapmalısınız.');
        return;
      }

      final result = await _commentService.toggleLike(commentId);

      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = _comments[index];
        final user = await _authService.getCurrentUser();

        if (user != null) {
          List<String> updatedLikes = List.from(comment.likes);
          if (result['isLiked'] == true) {
            if (!updatedLikes.contains(user.id.toString())) {
              updatedLikes.add(user.id.toString());
            }
          } else {
            updatedLikes.remove(user.id.toString());
          }

          _comments[index] = comment.copyWith(likes: updatedLikes);
        }
      }
    } catch (e) {
      SnackbarHelper.showError('İşlem başarısız: ${e.toString()}');
    }
  }

  void clearComments() {
    _comments.clear();
    _currentPage.value = 1;
  }
}
