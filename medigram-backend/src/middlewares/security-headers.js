'use strict';

/**
 * Security Headers Middleware
 * Adds security-related HTTP headers to protect against common vulnerabilities
 */

module.exports = (config, { strapi }) => {
  return async (ctx, next) => {
    // Execute the request
    await next();

    // Add security headers
    const headers = {
      // Prevent clickjacking attacks
      'X-Frame-Options': 'SAMEORIGIN',

      // Prevent MIME type sniffing
      'X-Content-Type-Options': 'nosniff',

      // Enable XSS protection in older browsers
      'X-XSS-Protection': '1; mode=block',

      // Referrer policy
      'Referrer-Policy': 'strict-origin-when-cross-origin',

      // Permissions policy (formerly Feature Policy)
      'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',

      // Content Security Policy
      'Content-Security-Policy': [
        "default-src 'self'",
        "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
        "style-src 'self' 'unsafe-inline'",
        "img-src 'self' data: https:",
        "font-src 'self' data:",
        "connect-src 'self' https://api.openai.com https://api.iyzipay.com",
        "media-src 'self'",
        "object-src 'none'",
        "frame-ancestors 'self'",
      ].join('; '),

      // Strict Transport Security (HTTPS only)
      ...(process.env.NODE_ENV === 'production' && {
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
      }),
    };

    // Apply headers
    Object.entries(headers).forEach(([key, value]) => {
      if (value) {
        ctx.set(key, value);
      }
    });
  };
};
