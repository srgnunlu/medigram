'use strict';

/**
 * medical-card controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::medical-card.medical-card', ({ strapi }) => ({
  // Custom method to like/unlike a medical card
  async like(ctx) {
    try {
      const { id } = ctx.params;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in to like cards');
      }

      // Get the medical card
      const medicalCard = await strapi.entityService.findOne('api::medical-card.medical-card', id);

      if (!medicalCard) {
        return ctx.notFound('Medical card not found');
      }

      // Parse likes array
      let likes = [];
      try {
        likes = medicalCard.likes ? JSON.parse(medicalCard.likes) : [];
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

      // Update the medical card
      const updatedCard = await strapi.entityService.update('api::medical-card.medical-card', id, {
        data: {
          likes: JSON.stringify(likes),
        },
      });

      return ctx.send({
        success: true,
        data: {
          id: updatedCard.id,
          isLiked: !isLiked,
          likeCount: likes.length,
        },
      });
    } catch (error) {
      console.error('Error liking medical card:', error);
      return ctx.internalServerError('Failed to like medical card');
    }
  },

  // Custom method to increment share count
  async share(ctx) {
    try {
      const { id } = ctx.params;

      const medicalCard = await strapi.entityService.findOne('api::medical-card.medical-card', id);

      if (!medicalCard) {
        return ctx.notFound('Medical card not found');
      }

      const updatedCard = await strapi.entityService.update('api::medical-card.medical-card', id, {
        data: {
          shareCount: (medicalCard.shareCount || 0) + 1,
        },
      });

      return ctx.send({
        success: true,
        data: {
          id: updatedCard.id,
          shareCount: updatedCard.shareCount,
        },
      });
    } catch (error) {
      console.error('Error sharing medical card:', error);
      return ctx.internalServerError('Failed to share medical card');
    }
  },

  // Override find to add filtering by category
  async find(ctx) {
    const { category, isPremium, search } = ctx.query;

    // Build filters
    const filters = {};
    if (category) {
      filters.category = { $eq: category };
    }
    if (isPremium !== undefined) {
      filters.isPremium = { $eq: isPremium === 'true' };
    }
    if (search) {
      filters.$or = [
        { title: { $containsi: search } },
        { content: { $containsi: search } },
        { author: { $containsi: search } },
      ];
    }

    // Fetch with filters
    const entities = await strapi.entityService.findMany('api::medical-card.medical-card', {
      filters,
      sort: { createdAt: 'desc' },
      populate: '*',
      ...ctx.query,
    });

    return this.transformResponse(entities);
  },
}));
