'use strict';

/**
 * Rate Limiting Middleware
 * Protects API endpoints from abuse and DDoS attacks
 */

// In-memory store for rate limiting (use Redis in production)
const requestCounts = new Map();
const blockedIPs = new Map();

// Cleanup old entries every 10 minutes
setInterval(() => {
  const now = Date.now();
  const tenMinutesAgo = now - 10 * 60 * 1000;

  // Clean request counts
  for (const [key, value] of requestCounts.entries()) {
    if (value.resetTime < now) {
      requestCounts.delete(key);
    }
  }

  // Clean blocked IPs
  for (const [ip, blockUntil] of blockedIPs.entries()) {
    if (blockUntil < now) {
      blockedIPs.delete(ip);
    }
  }
}, 10 * 60 * 1000);

module.exports = (config, { strapi }) => {
  return async (ctx, next) => {
    // Skip rate limiting if disabled
    if (process.env.RATE_LIMIT_ENABLED === 'false') {
      return await next();
    }

    // Get client identifier (IP address or user ID)
    const ip = ctx.request.ip || ctx.request.socket.remoteAddress;
    const userId = ctx.state.user?.id;
    const identifier = userId ? `user:${userId}` : `ip:${ip}`;

    // Check if IP is blocked
    const blockUntil = blockedIPs.get(ip);
    if (blockUntil && blockUntil > Date.now()) {
      const remainingTime = Math.ceil((blockUntil - Date.now()) / 1000);
      ctx.status = 429;
      ctx.body = {
        error: {
          status: 429,
          name: 'TooManyRequests',
          message: `Too many requests. IP blocked for ${remainingTime} seconds.`,
          details: {
            retryAfter: remainingTime,
          },
        },
      };
      return;
    }

    // Rate limit configuration
    const maxRequests = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10);
    const windowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10); // 15 minutes
    const blockDurationMs = 30 * 60 * 1000; // 30 minutes block

    const now = Date.now();

    // Get or create request count for identifier
    let record = requestCounts.get(identifier);
    if (!record || record.resetTime < now) {
      record = {
        count: 0,
        resetTime: now + windowMs,
        violations: record?.violations || 0,
      };
      requestCounts.set(identifier, record);
    }

    // Increment request count
    record.count++;

    // Check if limit exceeded
    if (record.count > maxRequests) {
      record.violations++;

      // Block IP after multiple violations
      if (record.violations >= 3) {
        blockedIPs.set(ip, now + blockDurationMs);
        strapi.log.warn(`IP blocked for excessive requests: ${ip}`);
      }

      const remainingTime = Math.ceil((record.resetTime - now) / 1000);

      ctx.status = 429;
      ctx.body = {
        error: {
          status: 429,
          name: 'TooManyRequests',
          message: 'Too many requests, please try again later.',
          details: {
            limit: maxRequests,
            remaining: 0,
            resetTime: record.resetTime,
            retryAfter: remainingTime,
          },
        },
      };

      // Log rate limit violation
      strapi.log.warn(`Rate limit exceeded for ${identifier}`);
      return;
    }

    // Set rate limit headers
    ctx.set('X-RateLimit-Limit', maxRequests.toString());
    ctx.set('X-RateLimit-Remaining', (maxRequests - record.count).toString());
    ctx.set('X-RateLimit-Reset', record.resetTime.toString());

    await next();
  };
};
