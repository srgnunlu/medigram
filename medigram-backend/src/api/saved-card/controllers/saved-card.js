'use strict';

/**
 * saved-card controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::saved-card.saved-card', ({ strapi }) => ({
  // Save a medical card
  async save(ctx) {
    try {
      const { medicalCardId } = ctx.request.body;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in to save cards');
      }

      if (!medicalCardId) {
        return ctx.badRequest('Medical card ID is required');
      }

      // Check if medical card exists
      const medicalCard = await strapi.entityService.findOne(
        'api::medical-card.medical-card',
        medicalCardId
      );

      if (!medicalCard) {
        return ctx.notFound('Medical card not found');
      }

      // Check if already saved
      const existingSave = await strapi.entityService.findMany('api::saved-card.saved-card', {
        filters: {
          user: { id: user.id },
          medicalCard: { id: medicalCardId },
        },
      });

      if (existingSave.length > 0) {
        return ctx.badRequest('Card already saved');
      }

      // Create saved card
      const savedCard = await strapi.entityService.create('api::saved-card.saved-card', {
        data: {
          user: user.id,
          medicalCard: medicalCardId,
          publishedAt: new Date(),
        },
        populate: {
          medicalCard: true,
        },
      });

      return ctx.send({
        success: true,
        message: 'Card saved successfully',
        data: savedCard,
      });
    } catch (error) {
      console.error('Error saving card:', error);
      return ctx.internalServerError('Failed to save card');
    }
  },

  // Unsave a medical card
  async unsave(ctx) {
    try {
      const { medicalCardId } = ctx.params;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      // Find saved card
      const savedCards = await strapi.entityService.findMany('api::saved-card.saved-card', {
        filters: {
          user: { id: user.id },
          medicalCard: { id: medicalCardId },
        },
      });

      if (savedCards.length === 0) {
        return ctx.notFound('Saved card not found');
      }

      // Delete saved card
      await strapi.entityService.delete('api::saved-card.saved-card', savedCards[0].id);

      return ctx.send({
        success: true,
        message: 'Card unsaved successfully',
      });
    } catch (error) {
      console.error('Error unsaving card:', error);
      return ctx.internalServerError('Failed to unsave card');
    }
  },

  // Get user's saved cards
  async getMySavedCards(ctx) {
    try {
      const user = ctx.state.user;
      const { page = 1, pageSize = 25 } = ctx.query;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      const savedCards = await strapi.entityService.findMany('api::saved-card.saved-card', {
        filters: {
          user: { id: user.id },
        },
        populate: {
          medicalCard: {
            populate: '*',
          },
        },
        sort: { createdAt: 'desc' },
        start: (page - 1) * pageSize,
        limit: pageSize,
      });

      return ctx.send({
        success: true,
        data: savedCards,
      });
    } catch (error) {
      console.error('Error fetching saved cards:', error);
      return ctx.internalServerError('Failed to fetch saved cards');
    }
  },

  // Check if a card is saved
  async checkSaved(ctx) {
    try {
      const { cardId } = ctx.params;
      const user = ctx.state.user;

      if (!user) {
        return ctx.send({
          success: true,
          data: { isSaved: false },
        });
      }

      const savedCards = await strapi.entityService.findMany('api::saved-card.saved-card', {
        filters: {
          user: { id: user.id },
          medicalCard: { id: cardId },
        },
      });

      return ctx.send({
        success: true,
        data: {
          isSaved: savedCards.length > 0,
        },
      });
    } catch (error) {
      console.error('Error checking saved status:', error);
      return ctx.internalServerError('Failed to check saved status');
    }
  },
}));
