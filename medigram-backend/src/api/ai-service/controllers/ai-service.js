'use strict';

/**
 * AI Service Controller
 * Handles AI-powered features: image generation, content generation, recommendations
 */

module.exports = {
  /**
   * Generate image using DALL-E
   * POST /ai-service/generate-image
   */
  async generateImage(ctx) {
    try {
      const { prompt, size = '1024x1024', n = 1 } = ctx.request.body;

      // Validate input
      if (!prompt || typeof prompt !== 'string' || prompt.trim().length === 0) {
        return ctx.badRequest('Valid prompt is required');
      }

      if (prompt.length > 1000) {
        return ctx.badRequest('Prompt must be less than 1000 characters');
      }

      // Check if user is premium (AI features are premium only)
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      // Check premium status
      const subscription = await strapi.db.query('api::subscription.subscription').findOne({
        where: {
          user: user.id,
          status: 'active'
        },
      });

      if (!subscription) {
        return ctx.forbidden('Premium subscription required for AI features');
      }

      // In production, you would call OpenAI API here
      // For now, returning mock response
      const openaiApiKey = process.env.OPENAI_API_KEY;

      if (openaiApiKey && openaiApiKey !== 'your-openai-api-key-here') {
        // Real OpenAI API call
        const response = await fetch('https://api.openai.com/v1/images/generations', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${openaiApiKey}`,
          },
          body: JSON.stringify({
            model: 'dall-e-3',
            prompt: prompt,
            n: n,
            size: size,
            quality: 'standard',
          }),
        });

        if (!response.ok) {
          const error = await response.json();
          strapi.log.error('OpenAI API error:', error);
          return ctx.badRequest('Failed to generate image. Please try again.');
        }

        const data = await response.json();

        // Log AI usage for analytics
        await strapi.db.query('api::ai-usage.ai-usage').create({
          data: {
            user: user.id,
            feature: 'image_generation',
            prompt: prompt,
            cost: 0.04, // DALL-E 3 standard cost
            createdAt: new Date(),
          },
        });

        return ctx.send({
          data: {
            images: data.data.map(img => ({
              url: img.url,
              revised_prompt: img.revised_prompt,
            })),
            prompt: prompt,
          },
        });
      } else {
        // Mock response for development
        return ctx.send({
          data: {
            images: [{
              url: `https://picsum.photos/seed/${Date.now()}/1024/1024`,
              revised_prompt: `Medical illustration: ${prompt}`,
            }],
            prompt: prompt,
            note: 'This is a mock response. Set OPENAI_API_KEY in .env for real generation.',
          },
        });
      }
    } catch (error) {
      strapi.log.error('Generate image error:', error);
      return ctx.internalServerError('An error occurred while generating image');
    }
  },

  /**
   * Generate medical content using GPT
   * POST /ai-service/generate-content
   */
  async generateContent(ctx) {
    try {
      const { topic, category, tone = 'professional', length = 'medium' } = ctx.request.body;

      // Validate input
      if (!topic || typeof topic !== 'string' || topic.trim().length === 0) {
        return ctx.badRequest('Valid topic is required');
      }

      if (topic.length > 500) {
        return ctx.badRequest('Topic must be less than 500 characters');
      }

      // Check authentication and premium status
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const subscription = await strapi.db.query('api::subscription.subscription').findOne({
        where: {
          user: user.id,
          status: 'active'
        },
      });

      if (!subscription) {
        return ctx.forbidden('Premium subscription required for AI features');
      }

      const lengthTokens = {
        short: 150,
        medium: 300,
        long: 500,
      };

      const maxTokens = lengthTokens[length] || 300;

      const openaiApiKey = process.env.OPENAI_API_KEY;

      if (openaiApiKey && openaiApiKey !== 'your-openai-api-key-here') {
        // Real OpenAI API call
        const systemPrompt = `You are a medical content writer. Create accurate, ${tone}, and informative medical content.
Category: ${category || 'general medicine'}.
Always cite general sources and maintain professional medical standards.`;

        const response = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${openaiApiKey}`,
          },
          body: JSON.stringify({
            model: 'gpt-4-turbo-preview',
            messages: [
              { role: 'system', content: systemPrompt },
              { role: 'user', content: `Write medical content about: ${topic}` },
            ],
            max_tokens: maxTokens,
            temperature: 0.7,
          }),
        });

        if (!response.ok) {
          const error = await response.json();
          strapi.log.error('OpenAI API error:', error);
          return ctx.badRequest('Failed to generate content. Please try again.');
        }

        const data = await response.json();
        const generatedContent = data.choices[0].message.content;

        // Log AI usage
        await strapi.db.query('api::ai-usage.ai-usage').create({
          data: {
            user: user.id,
            feature: 'content_generation',
            prompt: topic,
            cost: (data.usage.total_tokens / 1000) * 0.01, // Approximate cost
            createdAt: new Date(),
          },
        });

        return ctx.send({
          data: {
            content: generatedContent,
            topic: topic,
            category: category,
            tokens_used: data.usage.total_tokens,
          },
        });
      } else {
        // Mock response
        return ctx.send({
          data: {
            content: `# ${topic}\n\n## Genel Bakış\n\nBu konu hakkında detaylı tıbbi bilgi içeriği buraya gelecek. ${category ? `Kategori: ${category}` : ''}\n\n## Önemli Noktalar\n\n- Detaylı açıklama 1\n- Detaylı açıklama 2\n- Detaylı açıklama 3\n\n## Kaynaklar\n\nGenel tıbbi literatür kaynakları`,
            topic: topic,
            category: category,
            note: 'This is mock content. Set OPENAI_API_KEY in .env for real generation.',
          },
        });
      }
    } catch (error) {
      strapi.log.error('Generate content error:', error);
      return ctx.internalServerError('An error occurred while generating content');
    }
  },

  /**
   * Get personalized content recommendations
   * GET /ai-service/recommendations
   */
  async getRecommendations(ctx) {
    try {
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const { limit = 10, category } = ctx.query;

      // Get user's liked cards to understand preferences
      const likedCards = await strapi.db.query('api::medical-card.medical-card').findMany({
        where: {
          likes: {
            $contains: user.id.toString(),
          },
        },
        limit: 20,
        orderBy: { createdAt: 'desc' },
      });

      // Get user's saved cards
      const savedCards = await strapi.db.query('api::saved-card.saved-card').findMany({
        where: { user: user.id },
        populate: ['medicalCard'],
        limit: 20,
      });

      // Extract categories user is interested in
      const userCategories = {};
      likedCards.forEach(card => {
        userCategories[card.category] = (userCategories[card.category] || 0) + 1;
      });
      savedCards.forEach(saved => {
        if (saved.medicalCard) {
          userCategories[saved.medicalCard.category] = (userCategories[saved.medicalCard.category] || 0) + 1;
        }
      });

      // Get top categories
      const topCategories = Object.entries(userCategories)
        .sort(([, a], [, b]) => b - a)
        .slice(0, 3)
        .map(([cat]) => cat);

      // Build recommendation query
      const whereClause = {
        id: {
          $notIn: [
            ...likedCards.map(c => c.id),
            ...savedCards.map(s => s.medicalCard?.id).filter(Boolean),
          ],
        },
      };

      if (topCategories.length > 0 && !category) {
        whereClause.category = { $in: topCategories };
      } else if (category) {
        whereClause.category = category;
      }

      // Fetch recommendations with engagement scoring
      const recommendations = await strapi.db.query('api::medical-card.medical-card').findMany({
        where: whereClause,
        limit: parseInt(limit),
        orderBy: [
          { likes: 'desc' },
          { commentCount: 'desc' },
          { createdAt: 'desc' },
        ],
      });

      // Calculate relevance scores
      const scoredRecommendations = recommendations.map(card => {
        let score = 0;

        // Category match bonus
        if (topCategories.includes(card.category)) {
          const categoryIndex = topCategories.indexOf(card.category);
          score += (3 - categoryIndex) * 10; // 30, 20, 10 points
        }

        // Engagement score
        score += (card.likes?.length || 0) * 2;
        score += (card.commentCount || 0) * 3;
        score += (card.shareCount || 0) * 1;

        // Recency bonus (cards from last 30 days)
        const daysSinceCreation = (Date.now() - new Date(card.createdAt).getTime()) / (1000 * 60 * 60 * 24);
        if (daysSinceCreation < 30) {
          score += (30 - daysSinceCreation) * 0.5;
        }

        return {
          ...card,
          relevanceScore: Math.round(score),
        };
      });

      // Sort by relevance score
      scoredRecommendations.sort((a, b) => b.relevanceScore - a.relevanceScore);

      return ctx.send({
        data: {
          recommendations: scoredRecommendations,
          userPreferences: {
            topCategories: topCategories,
            totalLikes: likedCards.length,
            totalSaved: savedCards.length,
          },
        },
      });
    } catch (error) {
      strapi.log.error('Get recommendations error:', error);
      return ctx.internalServerError('An error occurred while fetching recommendations');
    }
  },

  /**
   * Analyze image and suggest medical content
   * POST /ai-service/analyze-image
   */
  async analyzeImage(ctx) {
    try {
      const { imageUrl } = ctx.request.body;

      if (!imageUrl) {
        return ctx.badRequest('Image URL is required');
      }

      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      // Check premium status
      const subscription = await strapi.db.query('api::subscription.subscription').findOne({
        where: {
          user: user.id,
          status: 'active'
        },
      });

      if (!subscription) {
        return ctx.forbidden('Premium subscription required for AI features');
      }

      const openaiApiKey = process.env.OPENAI_API_KEY;

      if (openaiApiKey && openaiApiKey !== 'your-openai-api-key-here') {
        // Real GPT-4 Vision API call
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${openaiApiKey}`,
          },
          body: JSON.stringify({
            model: 'gpt-4-vision-preview',
            messages: [
              {
                role: 'user',
                content: [
                  {
                    type: 'text',
                    text: 'Analyze this medical image and provide: 1) Brief description, 2) Suggested category, 3) Potential topics to cover, 4) Relevant medical keywords. Keep it professional and accurate.',
                  },
                  {
                    type: 'image_url',
                    image_url: {
                      url: imageUrl,
                    },
                  },
                ],
              },
            ],
            max_tokens: 500,
          }),
        });

        if (!response.ok) {
          const error = await response.json();
          strapi.log.error('OpenAI Vision API error:', error);
          return ctx.badRequest('Failed to analyze image. Please try again.');
        }

        const data = await response.json();

        return ctx.send({
          data: {
            analysis: data.choices[0].message.content,
            imageUrl: imageUrl,
          },
        });
      } else {
        // Mock response
        return ctx.send({
          data: {
            analysis: 'Görsel analizi tamamlandı. Anatomi/Fizyoloji kategorisi önerilir. İlgili konular: organ yapısı, sistem işleyişi, patolojik değişiklikler.',
            imageUrl: imageUrl,
            note: 'This is a mock response. Set OPENAI_API_KEY for real analysis.',
          },
        });
      }
    } catch (error) {
      strapi.log.error('Analyze image error:', error);
      return ctx.internalServerError('An error occurred while analyzing image');
    }
  },
};
