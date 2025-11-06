'use strict';

/**
 * Response Cache Middleware
 * Caches GET responses to improve performance
 * Use Redis in production for distributed caching
 */

// In-memory cache (use Redis in production)
const cache = new Map();
const cacheStats = {
  hits: 0,
  misses: 0,
  size: 0,
};

// Cache configuration
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes
const MAX_CACHE_SIZE = 1000; // Maximum number of cached items

// Cleanup old cache entries every minute
setInterval(() => {
  const now = Date.now();
  let deletedCount = 0;

  for (const [key, value] of cache.entries()) {
    if (value.expiresAt < now) {
      cache.delete(key);
      deletedCount++;
    }
  }

  if (deletedCount > 0) {
    cacheStats.size = cache.size;
    console.log(`Cache cleanup: removed ${deletedCount} expired entries, ${cache.size} remaining`);
  }
}, 60 * 1000);

// Helper to generate cache key
function generateCacheKey(ctx) {
  const userId = ctx.state.user?.id || 'anonymous';
  const url = ctx.request.url;
  return `${userId}:${url}`;
}

// Helper to check if response should be cached
function shouldCache(ctx) {
  // Only cache GET requests
  if (ctx.request.method !== 'GET') {
    return false;
  }

  // Don't cache if user explicitly requests fresh data
  if (ctx.request.headers['cache-control'] === 'no-cache') {
    return false;
  }

  // Don't cache admin routes
  if (ctx.request.url.startsWith('/admin')) {
    return false;
  }

  // Don't cache authentication routes
  if (ctx.request.url.includes('/auth/')) {
    return false;
  }

  return true;
}

// Evict least recently used items if cache is full
function evictLRU() {
  if (cache.size < MAX_CACHE_SIZE) {
    return;
  }

  let oldestKey = null;
  let oldestTime = Date.now();

  for (const [key, value] of cache.entries()) {
    if (value.createdAt < oldestTime) {
      oldestTime = value.createdAt;
      oldestKey = key;
    }
  }

  if (oldestKey) {
    cache.delete(oldestKey);
  }
}

module.exports = (config, { strapi }) => {
  // Add cache stats endpoint
  strapi.server.router.get('/api/cache/stats', (ctx) => {
    ctx.body = {
      ...cacheStats,
      hitRate: cacheStats.hits + cacheStats.misses > 0
        ? (cacheStats.hits / (cacheStats.hits + cacheStats.misses) * 100).toFixed(2) + '%'
        : '0%',
    };
  });

  // Clear cache endpoint (admin only)
  strapi.server.router.post('/api/cache/clear', async (ctx) => {
    // Check if user is admin
    const user = ctx.state.user;
    if (!user || !user.role || user.role.type !== 'admin') {
      return ctx.unauthorized('Admin access required');
    }

    const previousSize = cache.size;
    cache.clear();
    cacheStats.size = 0;

    ctx.body = {
      success: true,
      message: `Cache cleared. Removed ${previousSize} entries.`,
    };
  });

  return async (ctx, next) => {
    // Check if this request should be cached
    if (!shouldCache(ctx)) {
      return await next();
    }

    // Generate cache key
    const cacheKey = generateCacheKey(ctx);

    // Check if response is in cache
    const cachedResponse = cache.get(cacheKey);
    if (cachedResponse && cachedResponse.expiresAt > Date.now()) {
      // Cache hit
      cacheStats.hits++;
      ctx.status = cachedResponse.status;
      ctx.body = cachedResponse.body;
      ctx.set('X-Cache', 'HIT');
      ctx.set('X-Cache-Age', Math.floor((Date.now() - cachedResponse.createdAt) / 1000).toString());
      return;
    }

    // Cache miss
    cacheStats.misses++;

    // Execute request
    await next();

    // Only cache successful responses
    if (ctx.status >= 200 && ctx.status < 300 && ctx.body) {
      evictLRU();

      const now = Date.now();
      cache.set(cacheKey, {
        status: ctx.status,
        body: ctx.body,
        createdAt: now,
        expiresAt: now + CACHE_DURATION,
      });

      cacheStats.size = cache.size;
      ctx.set('X-Cache', 'MISS');
    }
  };
};
