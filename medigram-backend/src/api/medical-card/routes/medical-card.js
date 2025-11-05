'use strict';

/**
 * medical-card router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

const defaultRouter = createCoreRouter('api::medical-card.medical-card', {
  config: {
    find: {
      auth: false,
    },
    findOne: {
      auth: false,
    },
  },
});

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
    path: '/medical-cards/:id/like',
    handler: 'api::medical-card.medical-card.like',
    config: {
      auth: true,
    },
  },
  {
    method: 'POST',
    path: '/medical-cards/:id/share',
    handler: 'api::medical-card.medical-card.share',
    config: {
      auth: false, // Can share without login
    },
  },
];

module.exports = customRouter(defaultRouter, customRoutes);
