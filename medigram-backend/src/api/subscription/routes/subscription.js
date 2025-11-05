'use strict';

/**
 * subscription router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

const defaultRouter = createCoreRouter('api::subscription.subscription');

const customRouter = (innerRouter, extraRoutes = []) => {
  let routes;
  return {
    get prefix() {
      return innerRouter.prefix;
    },
    get routes() {
      if (!routes) routes = innerRouter.routes.concat(extraRoutes);
      return routes;
    },
  };
};

const customRoutes = [
  {
    method: 'POST',
    path: '/subscriptions/checkout',
    handler: 'api::subscription.subscription.createCheckout',
    config: {
      auth: true,
    },
  },
  {
    method: 'GET',
    path: '/subscriptions/my',
    handler: 'api::subscription.subscription.getMySubscription',
    config: {
      auth: true,
    },
  },
  {
    method: 'POST',
    path: '/subscriptions/cancel',
    handler: 'api::subscription.subscription.cancel',
    config: {
      auth: true,
    },
  },
  {
    method: 'POST',
    path: '/subscriptions/webhook',
    handler: 'api::subscription.subscription.webhook',
    config: {
      auth: false, // Webhook from Iyzico
    },
  },
  {
    method: 'GET',
    path: '/subscriptions/check-premium',
    handler: 'api::subscription.subscription.checkPremium',
    config: {
      auth: false,
    },
  },
];

module.exports = customRouter(defaultRouter, customRoutes);
