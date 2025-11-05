'use strict';

/**
 * comment router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

const defaultRouter = createCoreRouter('api::comment.comment');

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
    path: '/comments',
    handler: 'api::comment.comment.create',
    config: {
      auth: true,
    },
  },
  {
    method: 'GET',
    path: '/comments/card/:cardId',
    handler: 'api::comment.comment.findByCard',
    config: {
      auth: false,
    },
  },
  {
    method: 'PUT',
    path: '/comments/:id',
    handler: 'api::comment.comment.update',
    config: {
      auth: true,
    },
  },
  {
    method: 'DELETE',
    path: '/comments/:id',
    handler: 'api::comment.comment.delete',
    config: {
      auth: true,
    },
  },
  {
    method: 'POST',
    path: '/comments/:id/like',
    handler: 'api::comment.comment.toggleLike',
    config: {
      auth: true,
    },
  },
];

module.exports = customRouter(defaultRouter, customRoutes);
