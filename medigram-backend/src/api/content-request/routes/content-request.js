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
      auth: true, // Authenticated users can submit
      policies: [],
    },
  },
  {
    method: 'PUT',
    path: '/content-requests/:id/approve',
    handler: 'api::content-request.content-request.approve',
    config: {
      auth: true,
      policies: ['admin::is-admin'], // Only admins can approve
    },
  },
  {
    method: 'PUT',
    path: '/content-requests/:id/reject',
    handler: 'api::content-request.content-request.reject',
    config: {
      auth: true,
      policies: ['admin::is-admin'], // Only admins can reject
    },
  },
  {
    method: 'POST',
    path: '/content-requests/:id/publish',
    handler: 'api::content-request.content-request.publish',
    config: {
      auth: true,
      policies: ['admin::is-admin'], // Only admins can publish
    },
  },
  {
    method: 'GET',
    path: '/content-requests/pending',
    handler: 'api::content-request.content-request.pending',
    config: {
      auth: true,
      policies: ['admin::is-admin'], // Only admins can view pending
    },
  },
];

module.exports = customRouter(defaultRouter, customRoutes);