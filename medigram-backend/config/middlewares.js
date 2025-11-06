module.exports = [
  'strapi::logger',
  'strapi::errors',
  // Error logging middleware
  'global::error-logger',
  // Security headers middleware
  'global::security-headers',
  // Rate limiting middleware
  'global::rate-limit',
  'strapi::security',
  'strapi::cors',
  'strapi::poweredBy',
  'strapi::query',
  'strapi::body',
  'strapi::session',
  'strapi::favicon',
  'strapi::public',
];
