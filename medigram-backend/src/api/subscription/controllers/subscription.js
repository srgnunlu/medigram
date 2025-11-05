'use strict';

/**
 * subscription controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::subscription.subscription', ({ strapi }) => ({
  // Create checkout session (Iyzico)
  async createCheckout(ctx) {
    try {
      const { plan } = ctx.request.body;
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      // Validate plan
      if (!['monthly', 'yearly'].includes(plan)) {
        return ctx.badRequest('Invalid plan type');
      }

      // Check if user already has active subscription
      const activeSubscription = await strapi.entityService.findMany(
        'api::subscription.subscription',
        {
          filters: {
            user: { id: user.id },
            status: 'active',
          },
        }
      );

      if (activeSubscription.length > 0) {
        return ctx.badRequest('You already have an active subscription');
      }

      // Calculate amount based on plan
      const prices = {
        monthly: 29.99,
        yearly: 299.99,
      };

      const amount = prices[plan];

      // TODO: Integrate with Iyzico API
      // For now, return mock checkout URL
      const mockCheckoutUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/payment/checkout?plan=${plan}&amount=${amount}`;

      // Create pending subscription
      const subscription = await strapi.entityService.create('api::subscription.subscription', {
        data: {
          user: user.id,
          plan: plan,
          amount: amount,
          currency: 'TRY',
          status: 'pending',
          autoRenew: true,
          publishedAt: new Date(),
        },
      });

      return ctx.send({
        success: true,
        data: {
          checkoutUrl: mockCheckoutUrl,
          subscriptionId: subscription.id,
          amount: amount,
          currency: 'TRY',
        },
      });
    } catch (error) {
      console.error('Error creating checkout:', error);
      return ctx.internalServerError('Failed to create checkout');
    }
  },

  // Get user's subscription
  async getMySubscription(ctx) {
    try {
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      const subscriptions = await strapi.entityService.findMany(
        'api::subscription.subscription',
        {
          filters: {
            user: { id: user.id },
            status: 'active',
          },
          sort: { createdAt: 'desc' },
          limit: 1,
        }
      );

      return ctx.send({
        success: true,
        data: subscriptions.length > 0 ? subscriptions[0] : null,
      });
    } catch (error) {
      console.error('Error fetching subscription:', error);
      return ctx.internalServerError('Failed to fetch subscription');
    }
  },

  // Cancel subscription
  async cancel(ctx) {
    try {
      const user = ctx.state.user;

      if (!user) {
        return ctx.unauthorized('You must be logged in');
      }

      const subscriptions = await strapi.entityService.findMany(
        'api::subscription.subscription',
        {
          filters: {
            user: { id: user.id },
            status: 'active',
          },
        }
      );

      if (subscriptions.length === 0) {
        return ctx.notFound('No active subscription found');
      }

      const subscription = subscriptions[0];

      // Update subscription status
      const updatedSubscription = await strapi.entityService.update(
        'api::subscription.subscription',
        subscription.id,
        {
          data: {
            status: 'cancelled',
            autoRenew: false,
            cancelledAt: new Date(),
          },
        }
      );

      // Update user premium status
      await strapi.query('plugin::users-permissions.user').update({
        where: { id: user.id },
        data: {
          isPremium: false,
        },
      });

      return ctx.send({
        success: true,
        message: 'Subscription cancelled successfully',
        data: updatedSubscription,
      });
    } catch (error) {
      console.error('Error cancelling subscription:', error);
      return ctx.internalServerError('Failed to cancel subscription');
    }
  },

  // Webhook handler for Iyzico
  async webhook(ctx) {
    try {
      const { status, subscriptionId, paymentId } = ctx.request.body;

      // TODO: Verify Iyzico webhook signature

      if (!subscriptionId) {
        return ctx.badRequest('Missing subscription ID');
      }

      // Find subscription
      const subscriptions = await strapi.entityService.findMany(
        'api::subscription.subscription',
        {
          filters: {
            id: subscriptionId,
          },
          populate: { user: true },
        }
      );

      if (subscriptions.length === 0) {
        return ctx.notFound('Subscription not found');
      }

      const subscription = subscriptions[0];

      // Handle payment success
      if (status === 'success') {
        const now = new Date();
        const endDate = new Date(now);

        // Set end date based on plan
        if (subscription.plan === 'monthly') {
          endDate.setMonth(endDate.getMonth() + 1);
        } else {
          endDate.setFullYear(endDate.getFullYear() + 1);
        }

        // Update subscription
        await strapi.entityService.update(
          'api::subscription.subscription',
          subscription.id,
          {
            data: {
              status: 'active',
              iyzicoPaymentId: paymentId,
              startDate: now,
              endDate: endDate,
            },
          }
        );

        // Update user premium status
        await strapi.query('plugin::users-permissions.user').update({
          where: { id: subscription.user.id },
          data: {
            isPremium: true,
            premiumUntil: endDate,
          },
        });

        return ctx.send({
          success: true,
          message: 'Payment processed successfully',
        });
      }

      // Handle payment failure
      if (status === 'failed') {
        await strapi.entityService.update(
          'api::subscription.subscription',
          subscription.id,
          {
            data: {
              status: 'cancelled',
            },
          }
        );

        return ctx.send({
          success: true,
          message: 'Payment failed',
        });
      }

      return ctx.send({ success: true });
    } catch (error) {
      console.error('Error handling webhook:', error);
      return ctx.internalServerError('Webhook processing failed');
    }
  },

  // Check premium status
  async checkPremium(ctx) {
    try {
      const user = ctx.state.user;

      if (!user) {
        return ctx.send({
          success: true,
          data: { isPremium: false },
        });
      }

      // Check if user has active subscription
      const subscriptions = await strapi.entityService.findMany(
        'api::subscription.subscription',
        {
          filters: {
            user: { id: user.id },
            status: 'active',
            endDate: { $gt: new Date() },
          },
        }
      );

      const isPremium = subscriptions.length > 0;

      // Update user if needed
      if (!isPremium) {
        await strapi.query('plugin::users-permissions.user').update({
          where: { id: user.id },
          data: {
            isPremium: false,
          },
        });
      }

      return ctx.send({
        success: true,
        data: {
          isPremium: isPremium,
          subscription: subscriptions.length > 0 ? subscriptions[0] : null,
        },
      });
    } catch (error) {
      console.error('Error checking premium status:', error);
      return ctx.internalServerError('Failed to check premium status');
    }
  },
}));
