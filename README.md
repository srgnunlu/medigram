# Medigram - Medical Information Sharing Platform

![Medigram](https://img.shields.io/badge/Medigram-Medical%20Platform-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.0.0-orange)

Medigram is a comprehensive medical information sharing platform that allows healthcare professionals and medical students to share, discover, and learn from medical content with AI-powered features.

## 🚀 Features

### Core Features
- **Medical Cards**: Create and share medical information cards with images and detailed content
- **Categories**: Organized content by medical specialties (Anatomy, Cardiology, Neurology, etc.)
- **Social Features**: Like, comment, and share medical content
- **Saved Cards**: Bookmark cards for later reference

### Premium Features (Iyzico Integration)
- **Monthly & Yearly Subscriptions**: ₺29.99/month or ₺299.99/year
- **Premium Content**: Access exclusive medical content
- **No Ads**: Ad-free experience

### AI-Powered Features (OpenAI Integration)
- **AI Image Generation**: Create medical illustrations using DALL-E 3
- **Content Generation**: Generate professional medical content with GPT-4
- **Personalized Recommendations**: AI-driven content suggestions based on user preferences
- **Image Analysis**: Analyze medical images using GPT-4 Vision

### Security & Performance
- **JWT Authentication**: Secure user authentication
- **Role-Based Access Control**: Admin and moderator roles
- **Rate Limiting**: Protection against API abuse
- **Security Headers**: OWASP security best practices
- **Response Caching**: Optimized API performance
- **Error Logging**: Comprehensive error tracking

## 🏗️ Architecture

### Backend
- **Framework**: Strapi 5.23.6 (Node.js)
- **Database**: PostgreSQL (production) / SQLite (development)
- **Caching**: Redis (optional)
- **Authentication**: JWT tokens
- **Payment**: Iyzico payment gateway
- **AI**: OpenAI API (DALL-E 3, GPT-4, GPT-4 Vision)

### Frontend
- **Framework**: Flutter (>=2.15.1)
- **State Management**: GetX
- **API Client**: Dio
- **Storage**: Flutter Secure Storage
- **Theme**: Material 3 Dark Theme
- **Design Pattern**: Clean Architecture + MVC

## 📋 Prerequisites

- Node.js >= 18.x
- Flutter >= 3.19.0
- PostgreSQL >= 15 (production)
- Redis >= 7 (optional, for production)
- Docker & Docker Compose (optional)

## 🚀 Quick Start

### Using Docker (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/medigram.git
   cd medigram
   ```

2. **Configure environment**
   ```bash
   cp medigram-backend/.env.example medigram-backend/.env
   # Edit .env with your configuration
   ```

3. **Start services**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - Backend API: http://localhost:1337
   - Admin Panel: http://localhost:1337/admin

### Manual Setup

#### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd medigram-backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env file with your configuration
   ```

4. **Start development server**
   ```bash
   npm run develop
   ```

#### Flutter Setup

1. **Navigate to project root**
   ```bash
   cd medigram
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Variables

#### Backend (.env)

```env
# Server
HOST=0.0.0.0
PORT=1337

# Security
JWT_SECRET=your-jwt-secret
API_TOKEN_SALT=your-api-token-salt
ADMIN_JWT_SECRET=your-admin-jwt-secret

# Database (PostgreSQL)
DATABASE_CLIENT=postgres
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_NAME=medigram
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your-password

# Iyzico Payment
IYZICO_API_KEY=your-iyzico-api-key
IYZICO_SECRET_KEY=your-iyzico-secret-key
IYZICO_BASE_URL=https://api.iyzipay.com

# OpenAI (AI Features)
OPENAI_API_KEY=your-openai-api-key

# Redis (Optional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_MAX_REQUESTS=100
RATE_LIMIT_WINDOW_MS=900000

# Logging
LOG_LEVEL=info
NODE_ENV=development
```

#### Flutter (lib/core/config/environment.dart)

```dart
Environment.setEnvironment(EnvironmentType.development);
```

## 📚 API Documentation

API documentation is available in OpenAPI 3.0 format:
- **Location**: `medigram-backend/docs/api-spec.yaml`
- **View Online**: Import the spec into [Swagger Editor](https://editor.swagger.io/)

### Key Endpoints

#### Authentication
- `POST /api/auth/local/register` - Register new user
- `POST /api/auth/local` - Login

#### Medical Cards
- `GET /api/medical-cards` - List cards (with filters)
- `POST /api/medical-cards` - Create card
- `POST /api/medical-cards/:id/like` - Like card
- `POST /api/medical-cards/:id/share` - Share card

#### AI Services (Premium)
- `POST /api/ai-service/generate-image` - Generate medical image
- `POST /api/ai-service/generate-content` - Generate content
- `GET /api/ai-service/recommendations` - Get recommendations
- `POST /api/ai-service/analyze-image` - Analyze image

#### Subscriptions
- `POST /api/subscription/checkout` - Create payment
- `GET /api/subscription/my` - Get subscription
- `POST /api/subscription/cancel` - Cancel subscription

## 🏃‍♂️ Running Tests

### Backend Tests
```bash
cd medigram-backend
npm test
```

### Flutter Tests
```bash
flutter test
```

## 📦 Deployment

### Using Docker

```bash
# Build production image
docker build -t medigram-backend ./medigram-backend

# Run with docker-compose
docker-compose -f docker-compose.yml up -d
```

### Manual Deployment

1. **Build backend**
   ```bash
   cd medigram-backend
   npm run build
   NODE_ENV=production npm start
   ```

2. **Build Flutter app**
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release
   ```

## 🔒 Security

### Implemented Security Measures

- ✅ JWT authentication with secure token storage
- ✅ Role-based access control (RBAC)
- ✅ Rate limiting (100 requests per 15 minutes)
- ✅ Security headers (CSP, XSS, clickjacking protection)
- ✅ Input validation and sanitization
- ✅ SQL injection prevention (Strapi ORM)
- ✅ CORS configuration
- ✅ HTTPS enforcement (production)
- ✅ Error logging and monitoring

### Security Best Practices

1. Always use HTTPS in production
2. Keep dependencies updated
3. Use strong JWT secrets
4. Enable Redis for distributed rate limiting
5. Configure Sentry for error tracking
6. Regular security audits

## 📊 Monitoring & Logging

### Log Files (Backend)
- Error logs: `medigram-backend/logs/error.log`
- Access logs: `medigram-backend/logs/access.log`

### Cache Statistics
- Endpoint: `GET /api/cache/stats`
- Clear cache: `POST /api/cache/clear` (admin only)

### Rate Limit Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1234567890
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Backend Developer**: Strapi + Node.js
- **Mobile Developer**: Flutter
- **AI Integration**: OpenAI APIs
- **Payment Integration**: Iyzico

## 🙏 Acknowledgments

- [Strapi](https://strapi.io/) - Headless CMS
- [Flutter](https://flutter.dev/) - Cross-platform framework
- [OpenAI](https://openai.com/) - AI capabilities
- [Iyzico](https://www.iyzico.com/) - Payment gateway

## 📞 Support

For support, email support@medigram.com or open an issue on GitHub.

## 🗺️ Roadmap

### Phase 1 (Completed) ✅
- Backend security improvements
- Flutter base infrastructure
- Authentication system
- Medical card CRUD

### Phase 2 (Completed) ✅
- Social features (comments, likes, saves)
- User interactions
- Card detail screen

### Phase 3 (Completed) ✅
- Premium subscriptions
- Iyzico payment integration
- Premium content protection

### Phase 4 (Completed) ✅
- AI image generation (DALL-E)
- AI content generation (GPT-4)
- Personalized recommendations
- AI Studio interface

### Phase 5 (Completed) ✅
- Production readiness
- Docker containerization
- CI/CD pipeline
- Security hardening
- Performance optimization
- API documentation

### Future Enhancements 🚀
- [ ] Real-time chat between users
- [ ] Video content support
- [ ] Mobile push notifications
- [ ] Multi-language support
- [ ] Advanced search with Elasticsearch
- [ ] Medical quiz system
- [ ] Certification programs
- [ ] WebRTC for telemedicine
- [ ] Integration with medical databases

## 📈 Performance

### Backend
- Response time: < 100ms (cached)
- Rate limit: 100 requests / 15 min
- Cache hit rate: ~70-80%
- Database queries: Optimized with indexes

### Flutter
- App size: ~25MB (release)
- Cold start: < 3s
- Image caching: 7 days
- API timeout: 30s

## 🐛 Known Issues

None at the moment. Please report issues on GitHub.

---

**Made with ❤️ for the medical community**
