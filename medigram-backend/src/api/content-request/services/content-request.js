'use strict';

/**
 * content-request service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::content-request.content-request');