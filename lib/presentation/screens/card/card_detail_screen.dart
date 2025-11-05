import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/core/utils/date_formatter.dart';
import 'package:medigram/presentation/controllers/comment_controller.dart';
import 'package:medigram/presentation/controllers/medical_card_controller.dart';
import 'package:medigram/presentation/controllers/auth_controller.dart';

class CardDetailScreen extends StatefulWidget {
  final MedicalCard card;

  const CardDetailScreen({super.key, required this.card});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final commentCtrl = Get.put(CommentController());
    commentCtrl.fetchComments(widget.card.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final commentCtrl = Get.find<CommentController>();
    commentCtrl.createComment(
      cardId: widget.card.id,
      content: _commentController.text.trim(),
    ).then((success) {
      if (success) {
        _commentController.clear();
        _commentFocusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<MedicalCardController>();
    final authController = Get.find<AuthController>();
    final commentController = Get.find<CommentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kart Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Save/unsave functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => cardController.shareCard(widget.card.id),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (widget.card.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.card.imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 300,
                        color: AppColors.surfaceLight,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 300,
                        color: AppColors.surfaceLight,
                        child: const Icon(Icons.error),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Chip(
                          label: Text(widget.card.category),
                          backgroundColor: AppColors.getCategoryColor(widget.card.category),
                        ),

                        const SizedBox(height: AppConstants.spacingM),

                        // Title
                        Text(
                          widget.card.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        const SizedBox(height: AppConstants.spacingS),

                        // Author & Date
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.getCategoryColor(widget.card.category),
                              child: Text(
                                widget.card.author[0].toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingS),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.card.author,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  DateFormatter.formatDateTime(widget.card.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Content
                        Text(
                          widget.card.content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Source
                        if (widget.card.source.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingM),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.source, size: 20),
                                const SizedBox(width: AppConstants.spacingS),
                                Expanded(
                                  child: Text(
                                    'Kaynak: ${widget.card.source}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Actions
                        Row(
                          children: [
                            // Like
                            Obx(() {
                              final currentUser = authController.currentUser;
                              final isLiked = currentUser != null &&
                                  widget.card.isLikedBy(currentUser.id.toString());

                              return InkWell(
                                onTap: () => cardController.toggleLike(widget.card.id),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? AppColors.error : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${widget.card.likes.length}'),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(width: AppConstants.spacingL),

                            // Comments
                            Row(
                              children: [
                                const Icon(Icons.comment_outlined),
                                const SizedBox(width: 4),
                                Text('${widget.card.commentCount}'),
                              ],
                            ),
                            const SizedBox(width: AppConstants.spacingL),

                            // Share
                            InkWell(
                              onTap: () => cardController.shareCard(widget.card.id),
                              child: Row(
                                children: [
                                  const Icon(Icons.share_outlined),
                                  const SizedBox(width: 4),
                                  Text('${widget.card.shareCount}'),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: AppConstants.spacingXL),

                        // Comments Section
                        Text(
                          'Yorumlar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: AppConstants.spacingM),

                        Obx(() {
                          if (commentController.isLoading &&
                              commentController.comments.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (commentController.comments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppConstants.spacingL),
                                child: Text(
                                  'Henüz yorum yok. İlk yorumu siz yapın!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: commentController.comments.length,
                            itemBuilder: (context, index) {
                              final comment = commentController.comments[index];
                              return _CommentTile(comment: comment);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: AppConstants.spacingM,
              right: AppConstants.spacingM,
              top: AppConstants.spacingS,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Yorum yazın...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Obx(
                  () => IconButton(
                    icon: commentController.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: commentController.isSubmitting ? null : _submitComment,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(
              comment.author?.username?[0]?.toUpperCase() ?? 'U',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author?.username ?? 'Kullanıcı',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDateTime(comment.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
