'use strict';

/**
 * saved-card service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::saved-card.saved-card');
