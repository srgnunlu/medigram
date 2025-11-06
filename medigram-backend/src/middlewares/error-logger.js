'use strict';

/**
 * Error Logger Middleware
 * Logs errors and optionally sends them to error tracking service (Sentry)
 */

const fs = require('fs');
const path = require('path');

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Error log file path
const errorLogPath = path.join(logsDir, 'error.log');
const accessLogPath = path.join(logsDir, 'access.log');

// Helper to format error for logging
function formatError(error, ctx) {
  return {
    timestamp: new Date().toISOString(),
    method: ctx.request.method,
    url: ctx.request.url,
    ip: ctx.request.ip,
    userId: ctx.state.user?.id,
    userAgent: ctx.request.headers['user-agent'],
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
      status: error.status || 500,
    },
  };
}

// Helper to log to file
function logToFile(filePath, data) {
  const logEntry = JSON.stringify(data) + '\n';
  fs.appendFile(filePath, logEntry, (err) => {
    if (err) {
      console.error('Failed to write to log file:', err);
    }
  });
}

// Helper to send to Sentry (if configured)
async function sendToSentry(error, ctx) {
  if (!process.env.SENTRY_DSN) {
    return;
  }

  try {
    // In production, you would import and use @sentry/node here
    // Example:
    // const Sentry = require('@sentry/node');
    // Sentry.captureException(error, {
    //   user: { id: ctx.state.user?.id },
    //   request: {
    //     url: ctx.request.url,
    //     method: ctx.request.method,
    //     headers: ctx.request.headers,
    //   },
    // });
  } catch (e) {
    console.error('Failed to send error to Sentry:', e);
  }
}

module.exports = (config, { strapi }) => {
  return async (ctx, next) => {
    const startTime = Date.now();

    try {
      await next();

      // Log successful requests in development
      if (process.env.LOG_LEVEL === 'debug') {
        const duration = Date.now() - startTime;
        const accessLog = {
          timestamp: new Date().toISOString(),
          method: ctx.request.method,
          url: ctx.request.url,
          status: ctx.status,
          duration: `${duration}ms`,
          ip: ctx.request.ip,
          userId: ctx.state.user?.id,
        };
        logToFile(accessLogPath, accessLog);
      }
    } catch (error) {
      const duration = Date.now() - startTime;

      // Format error data
      const errorData = formatError(error, ctx);
      errorData.duration = `${duration}ms`;

      // Log to console
      strapi.log.error('Request error:', errorData);

      // Log to file
      logToFile(errorLogPath, errorData);

      // Send to Sentry in production
      if (process.env.NODE_ENV === 'production') {
        await sendToSentry(error, ctx);
      }

      // Re-throw to let Strapi handle the error response
      throw error;
    }
  };
};
