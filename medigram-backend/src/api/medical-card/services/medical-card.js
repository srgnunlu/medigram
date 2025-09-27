'use strict';

/**
 * medical-card service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::medical-card.medical-card');
