'use strict';

/**
 * content-request controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::content-request.content-request', ({ strapi }) => ({
  // Custom method to submit content request
  async submit(ctx) {
    try {
      const { title, content, category, source, submittedByEmail } = ctx.request.body;
      const user = ctx.state.user;

      // Validate required fields
      if (!title || !content || !category) {
        return ctx.badRequest('Missing required fields: title, content, and category are required');
      }

      // Validate title length (5-200 characters as per schema)
      if (title.length < 5 || title.length > 200) {
        return ctx.badRequest('Title must be between 5 and 200 characters');
      }

      // Validate content length (minimum 50 characters as per schema)
      if (content.length < 50) {
        return ctx.badRequest('Content must be at least 50 characters long');
      }

      // Validate email format if provided
      if (submittedByEmail) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(submittedByEmail)) {
          return ctx.badRequest('Invalid email format');
        }
      }

      // Sanitize inputs to prevent XSS
      const sanitize = require('@strapi/utils').sanitize;
      const sanitizedTitle = title.trim();
      const sanitizedContent = content.trim();
      const sanitizedSource = source ? source.trim() : null;

      // Create content request with authenticated user info
      const contentRequest = await strapi.entityService.create('api::content-request.content-request', {
        data: {
          title: sanitizedTitle,
          content: sanitizedContent,
          category,
          source: sanitizedSource,
          submittedBy: user.id.toString(),
          submittedByName: user.username || user.email,
          submittedByEmail: submittedByEmail || user.email,
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
      const user = ctx.state.user;

      // Check if content request exists
      const existingRequest = await strapi.entityService.findOne('api::content-request.content-request', id);

      if (!existingRequest) {
        return ctx.notFound('Content request not found');
      }

      // Check if already processed
      if (existingRequest.status !== 'pending') {
        return ctx.badRequest(`Content request is already ${existingRequest.status}`);
      }

      // Sanitize admin notes
      const sanitizedNotes = adminNotes ? adminNotes.trim() : null;

      const contentRequest = await strapi.entityService.update('api::content-request.content-request', id, {
        data: {
          status: 'approved',
          adminNotes: sanitizedNotes,
          reviewedAt: new Date(),
          reviewedBy: user.username || user.email,
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
      const user = ctx.state.user;

      // Validate rejection reason is provided
      if (!rejectionReason || rejectionReason.trim().length === 0) {
        return ctx.badRequest('Rejection reason is required');
      }

      // Check if content request exists
      const existingRequest = await strapi.entityService.findOne('api::content-request.content-request', id);

      if (!existingRequest) {
        return ctx.notFound('Content request not found');
      }

      // Check if already processed
      if (existingRequest.status !== 'pending') {
        return ctx.badRequest(`Content request is already ${existingRequest.status}`);
      }

      const contentRequest = await strapi.entityService.update('api::content-request.content-request', id, {
        data: {
          status: 'rejected',
          rejectionReason: rejectionReason.trim(),
          reviewedAt: new Date(),
          reviewedBy: user.username || user.email,
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
      const { imageUrl, thumbnail, subcategory, difficulty, isPremium } = ctx.request.body;

      // Get the content request
      const contentRequest = await strapi.entityService.findOne('api::content-request.content-request', id);

      if (!contentRequest) {
        return ctx.notFound('Content request not found');
      }

      if (contentRequest.status !== 'approved') {
        return ctx.badRequest('Content request must be approved before publishing');
      }

      // Check if already published
      if (contentRequest.publishedMedicalCard) {
        return ctx.badRequest('Content request has already been published');
      }

      // Validate required fields for medical card
      if (!imageUrl || !thumbnail || !subcategory) {
        return ctx.badRequest('imageUrl, thumbnail, and subcategory are required for publishing');
      }

      // Calculate reading time (average 200 words per minute, ~5 chars per word)
      const estimatedWords = contentRequest.content.length / 5;
      const readingTimeMinutes = Math.max(1, Math.ceil(estimatedWords / 200));

      // Create medical card from content request
      const medicalCard = await strapi.entityService.create('api::medical-card.medical-card', {
        data: {
          title: contentRequest.title,
          content: contentRequest.content,
          category: contentRequest.category,
          subcategory: subcategory,
          imageUrl: imageUrl,
          thumbnail: thumbnail,
          source: contentRequest.source || 'User Submission',
          author: contentRequest.submittedByName,
          likes: JSON.stringify([]),
          commentCount: 0,
          shareCount: 0,
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