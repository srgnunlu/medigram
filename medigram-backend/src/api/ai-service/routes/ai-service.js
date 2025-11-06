module.exports = {
  routes: [
    {
      method: 'POST',
      path: '/ai-service/generate-image',
      handler: 'ai-service.generateImage',
      config: {
        auth: true,
        policies: [],
        middlewares: [],
      },
    },
    {
      method: 'POST',
      path: '/ai-service/generate-content',
      handler: 'ai-service.generateContent',
      config: {
        auth: true,
        policies: [],
        middlewares: [],
      },
    },
    {
      method: 'GET',
      path: '/ai-service/recommendations',
      handler: 'ai-service.getRecommendations',
      config: {
        auth: true,
        policies: [],
        middlewares: [],
      },
    },
    {
      method: 'POST',
      path: '/ai-service/analyze-image',
      handler: 'ai-service.analyzeImage',
      config: {
        auth: true,
        policies: [],
        middlewares: [],
      },
    },
  ],
};
