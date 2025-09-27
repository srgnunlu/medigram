module.exports = ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  app: {
    keys: env.array('APP_KEYS'),
  },
  settings: {
    cors: {
      enabled: true,
      headers: '*',
      origin: ['http://localhost:*', 'http://127.0.0.1:*', 'https://localhost:*', 'https://127.0.0.1:*', 'http://172.20.10.3:*', 'https://172.20.10.3:*']
    },
  },
});

