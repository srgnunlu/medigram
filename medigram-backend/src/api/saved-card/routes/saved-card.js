'use strict';

/**
 * saved-card router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

const defaultRouter = createCoreRouter('api::saved-card.saved-card');

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
    path: '/saved-cards',
    handler: 'api::saved-card.saved-card.save',
    config: {
      auth: true,
    },
  },
  {
    method: 'DELETE',
    path: '/saved-cards/:medicalCardId',
    handler: 'api::saved-card.saved-card.unsave',
    config: {
      auth: true,
    },
  },
  {
    method: 'GET',
    path: '/saved-cards/my',
    handler: 'api::saved-card.saved-card.getMySavedCards',
    config: {
      auth: true,
    },
  },
  {
    method: 'GET',
    path: '/saved-cards/check/:cardId',
    handler: 'api::saved-card.saved-card.checkSaved',
    config: {
      auth: false,
    },
  },
];

module.exports = customRouter(defaultRouter, customRoutes);
