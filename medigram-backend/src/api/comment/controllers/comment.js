'use strict';

/**
 * comment controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::comment.comment', ({ strapi }) => ({
  // Create comment
  async create(ctx) {
    try {
      const { content, medicalCardId, parentCommentId } = ctx.request.body;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in to comment');
      }

      // Validate required fields
      if (!content || content.trim().length === 0) {
        return ctx.badRequest('Comment content is required');
      }

      if (!medicalCardId) {
        return ctx.badRequest('Medical card ID is required');
      }

      // Validate content length
      if (content.length > 1000) {
        return ctx.badRequest('Comment must be less than 1000 characters');
      }

      // Check if medical card exists
      const medicalCard = await strapi.entityService.findOne(
        'api::medical-card.medical-card',
        medicalCardId
      );

      if (!medicalCard) {
        return ctx.notFound('Medical card not found');
      }

      // If parentCommentId provided, check if it exists
      if (parentCommentId) {
        const parentComment = await strapi.entityService.findOne(
          'api::comment.comment',
          parentCommentId
        );

        if (!parentComment) {
          return ctx.notFound('Parent comment not found');
        }
      }

      // Create comment
      const comment = await strapi.entityService.create('api::comment.comment', {
        data: {
          content: content.trim(),
          author: user.id,
          medicalCard: medicalCardId,
          parentComment: parentCommentId || null,
          likes: JSON.stringify([]),
          publishedAt: new Date(),
        },
        populate: {
          author: {
            fields: ['id', 'username', 'email'],
          },
        },
      });

      // Update medical card comment count
      if (!parentCommentId) {
        await strapi.entityService.update(
          'api::medical-card.medical-card',
          medicalCardId,
          {
            data: {
              commentCount: (medicalCard.commentCount || 0) + 1,
            },
          }
        );
      }

      return ctx.send({
        success: true,
        message: 'Comment created successfully',
        data: comment,
      });
    } catch (error) {
      console.error('Error creating comment:', error);
      return ctx.internalServerError('Failed to create comment');
    }
  },

  // Get comments for a medical card
  async findByCard(ctx) {
    try {
      const { cardId } = ctx.params;
      const { page = 1, pageSize = 20 } = ctx.query;

      const comments = await strapi.entityService.findMany('api::comment.comment', {
        filters: {
          medicalCard: { id: cardId },
          parentComment: { id: null }, // Only top-level comments
        },
        populate: {
          author: {
            fields: ['id', 'username', 'email'],
          },
          replies: {
            populate: {
              author: {
                fields: ['id', 'username', 'email'],
              },
            },
          },
        },
        sort: { createdAt: 'desc' },
        start: (page - 1) * pageSize,
        limit: pageSize,
      });

      return ctx.send({
        success: true,
        data: comments,
      });
    } catch (error) {
      console.error('Error fetching comments:', error);
      return ctx.internalServerError('Failed to fetch comments');
    }
  },

  // Update comment
  async update(ctx) {
    try {
      const { id } = ctx.params;
      const { content } = ctx.request.body;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      // Get existing comment
      const existingComment = await strapi.entityService.findOne(
        'api::comment.comment',
        id,
        {
          populate: { author: true },
        }
      );

      if (!existingComment) {
        return ctx.notFound('Comment not found');
      }

      // Check if user is the author
      if (existingComment.author.id !== user.id) {
        return ctx.forbidden('You can only edit your own comments');
      }

      // Validate content
      if (!content || content.trim().length === 0) {
        return ctx.badRequest('Comment content is required');
      }

      if (content.length > 1000) {
        return ctx.badRequest('Comment must be less than 1000 characters');
      }

      // Update comment
      const updatedComment = await strapi.entityService.update(
        'api::comment.comment',
        id,
        {
          data: {
            content: content.trim(),
          },
          populate: {
            author: {
              fields: ['id', 'username', 'email'],
            },
          },
        }
      );

      return ctx.send({
        success: true,
        message: 'Comment updated successfully',
        data: updatedComment,
      });
    } catch (error) {
      console.error('Error updating comment:', error);
      return ctx.internalServerError('Failed to update comment');
    }
  },

  // Delete comment
  async delete(ctx) {
    try {
      const { id } = ctx.params;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      // Get existing comment
      const existingComment = await strapi.entityService.findOne(
        'api::comment.comment',
        id,
        {
          populate: {
            author: true,
            medicalCard: true,
            parentComment: true,
          },
        }
      );

      if (!existingComment) {
        return ctx.notFound('Comment not found');
      }

      // Check if user is the author or admin
      const isAuthor = existingComment.author.id === user.id;
      const isAdmin = user.role && (user.role.type === 'admin' || user.role.name === 'Admin');

      if (!isAuthor && !isAdmin) {
        return ctx.forbidden('You can only delete your own comments');
      }

      // Delete comment
      await strapi.entityService.delete('api::comment.comment', id);

      // Update medical card comment count if it's a top-level comment
      if (!existingComment.parentComment && existingComment.medicalCard) {
        const medicalCard = await strapi.entityService.findOne(
          'api::medical-card.medical-card',
          existingComment.medicalCard.id
        );

        if (medicalCard) {
          await strapi.entityService.update(
            'api::medical-card.medical-card',
            existingComment.medicalCard.id,
            {
              data: {
                commentCount: Math.max(0, (medicalCard.commentCount || 0) - 1),
              },
            }
          );
        }
      }

      return ctx.send({
        success: true,
        message: 'Comment deleted successfully',
      });
    } catch (error) {
      console.error('Error deleting comment:', error);
      return ctx.internalServerError('Failed to delete comment');
    }
  },

  // Like/unlike comment
  async toggleLike(ctx) {
    try {
      const { id } = ctx.params;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in to like comments');
      }

      const comment = await strapi.entityService.findOne('api::comment.comment', id);

      if (!comment) {
        return ctx.notFound('Comment not found');
      }

      // Parse likes array
      let likes = [];
      try {
        likes = comment.likes ? JSON.parse(comment.likes) : [];
      } catch (e) {
        likes = [];
      }

      const userId = user.id.toString();
      const isLiked = likes.includes(userId);

      // Toggle like
      if (isLiked) {
        likes = likes.filter(id => id !== userId);
      } else {
        likes.push(userId);
      }

      // Update comment
      await strapi.entityService.update('api::comment.comment', id, {
        data: {
          likes: JSON.stringify(likes),
        },
      });

      return ctx.send({
        success: true,
        data: {
          isLiked: !isLiked,
          likeCount: likes.length,
        },
      });
    } catch (error) {
      console.error('Error toggling comment like:', error);
      return ctx.internalServerError('Failed to toggle like');
    }
  },
}));
