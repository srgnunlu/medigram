'use strict';

/**
 * content-request router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

const defaultRouter = createCoreRouter('api::content-request.content-request');

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
    path: '/content-requests/submit',
    handler: 'api::content-request.content-request.submit',
    config: {
      auth: false,
    },
  },
  {
    method: 'PUT',
    path: '/content-requests/:id/approve',
    handler: 'api::content-request.content-request.approve',
    config: {
      auth: false,
    },
  },
  {
    method: 'PUT',
    path: '/content-requests/:id/reject',
    handler: 'api::content-request.content-request.reject',
    config: {
      auth: false,
    },
  },
  {
    method: 'POST',
    path: '/content-requests/:id/publish',
    handler: 'api::content-request.content-request.publish',
    config: {
      auth: false,
    },
  },
  {
    method: 'GET',
    path: '/content-requests/pending',
    handler: 'api::content-request.content-request.pending',
    config: {
      auth: false,
    },
  },
];

module.exports = customRouter(defaultRouter, customRoutes);