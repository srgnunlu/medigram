'use strict';

/**
 * content-request controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::content-request.content-request', ({ strapi }) => ({
  // Custom method to submit content request
  async submit(ctx) {
    try {
      const { title, content, category, source, submittedBy, submittedByName, submittedByEmail } = ctx.request.body;

      // Validate required fields
      if (!title || !content || !category || !submittedBy || !submittedByName) {
        return ctx.badRequest('Missing required fields');
      }

      // Create content request
      const contentRequest = await strapi.entityService.create('api::content-request.content-request', {
        data: {
          title,
          content,
          category,
          source,
          submittedBy,
          submittedByName,
          submittedByEmail,
          status: 'pending',
          publishedAt: new Date(),
        },
      });

      return ctx.send({
        success: true,
        message: 'Content request submitted successfully',
        data: contentRequest,
      });
    } catch (error) {
      console.error('Error submitting content request:', error);
      return ctx.internalServerError('Failed to submit content request');
    }
  },

  // Custom method to approve content request
  async approve(ctx) {
    try {
      const { id } = ctx.params;
      const { adminNotes } = ctx.request.body;

      const contentRequest = await strapi.entityService.update('api::content-request.content-request', id, {
        data: {
          status: 'approved',
          adminNotes,
          reviewedAt: new Date(),
          reviewedBy: ctx.state.user?.id || 'admin',
        },
      });

      return ctx.send({
        success: true,
        message: 'Content request approved',
        data: contentRequest,
      });
    } catch (error) {
      console.error('Error approving content request:', error);
      return ctx.internalServerError('Failed to approve content request');
    }
  },

  // Custom method to reject content request
  async reject(ctx) {
    try {
      const { id } = ctx.params;
      const { rejectionReason } = ctx.request.body;

      const contentRequest = await strapi.entityService.update('api::content-request.content-request', id, {
        data: {
          status: 'rejected',
          rejectionReason,
          reviewedAt: new Date(),
          reviewedBy: ctx.state.user?.id || 'admin',
        },
      });

      return ctx.send({
        success: true,
        message: 'Content request rejected',
        data: contentRequest,
      });
    } catch (error) {
      console.error('Error rejecting content request:', error);
      return ctx.internalServerError('Failed to reject content request');
    }
  },

  // Custom method to publish approved content as medical card
  async publish(ctx) {
    try {
      const { id } = ctx.params;

      // Get the content request
      const contentRequest = await strapi.entityService.findOne('api::content-request.content-request', id);

      if (!contentRequest) {
        return ctx.notFound('Content request not found');
      }

      if (contentRequest.status !== 'approved') {
        return ctx.badRequest('Content request must be approved before publishing');
      }

      // Create medical card from content request
      const medicalCard = await strapi.entityService.create('api::medical-card.medical-card', {
        data: {
          title: contentRequest.title,
          content: contentRequest.content,
          category: contentRequest.category,
          source: contentRequest.source,
          author: contentRequest.submittedByName,
          tags: [contentRequest.category],
          likes: [],
          shareCount: 0,
          commentCount: 0,
          readingTimeMinutes: Math.ceil(contentRequest.content.length / 1000), // Estimate reading time
          difficulty: 'Orta', // Default difficulty
          isPremium: false,
          publishedAt: new Date(),
        },
      });

      // Update content request to mark as published
      await strapi.entityService.update('api::content-request.content-request', id, {
        data: {
          status: 'published',
          publishedMedicalCard: medicalCard.id,
        },
      });

      return ctx.send({
        success: true,
        message: 'Content published successfully',
        data: {
          contentRequest: await strapi.entityService.findOne('api::content-request.content-request', id),
          medicalCard,
        },
      });
    } catch (error) {
      console.error('Error publishing content:', error);
      return ctx.internalServerError('Failed to publish content');
    }
  },

  // Custom method to get pending requests for admin
  async pending(ctx) {
    try {
      const pendingRequests = await strapi.entityService.findMany('api::content-request.content-request', {
        filters: {
          status: 'pending',
        },
        sort: { createdAt: 'desc' },
        populate: '*',
      });

      return ctx.send({
        success: true,
        data: pendingRequests,
      });
    } catch (error) {
      console.error('Error fetching pending requests:', error);
      return ctx.internalServerError('Failed to fetch pending requests');
    }
  },
}));