# LUNG Oraculum 🔮

A decentralized prediction market platform built on Solana blockchain, enabling users to predict future events with real-time updates, blockchain-based order recording, and comprehensive user behavior analytics.

## 🌟 Features

- **Solana Blockchain Integration**: All predictions recorded on-chain with transparent settlement
- **Real-time Updates**: WebSocket-based live event feeds and prediction updates
- **Advanced Security**: Multi-layered anti-fraud and attack prevention
- **Behavioral Analytics**: Redis-powered user behavior tracking and personalized recommendations
- **Event Streaming**: Kafka-based event processing for scalability
- **Multiple Event Types**: Binary, multiple-choice, and scalar predictions
- **Leaderboards**: Competitive rankings and achievement system
- **Web Crawler**: Automated event creation from various data sources

## 🏗️ Tech Stack

### Backend
- **Go 1.21+** with Gin web framework
- **PostgreSQL 15+** for relational data
- **Redis 7+** for caching and behavior tracking
- **Apache Kafka** for event streaming
- **Solana** blockchain (Anchor framework)

### Frontend
- **React 18+** with modern hooks
- **Solana Wallet Adapter** for wallet integration
- **WebSocket** for real-time updates
- **Tailwind CSS** for styling

### Infrastructure
- **Docker** & **Kubernetes** for containerization
- **Nginx** for API gateway and load balancing
- **Prometheus** & **Grafana** for monitoring

## 📚 Documentation

- [Roadmap](./ROADMAP.md) - Complete MVP to production roadmap
- [Architecture](./ARCHITECTURE.md) - System architecture and design patterns
- [API Documentation](./docs/API.md) - REST API reference (Coming soon)
- [Smart Contract](./docs/SMART_CONTRACT.md) - Solana program documentation (Coming soon)

## 🚀 Quick Start

### Prerequisites

- Go 1.21 or higher
- Node.js 18+ and npm/yarn
- Docker and Docker Compose
- Solana CLI tools
- Anchor Framework
- PostgreSQL 15+
- Redis 7+
- Kafka (or use Docker Compose)

### Local Development Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd LUNG_Oraculum
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Start infrastructure services**
```bash
docker-compose up -d postgres redis kafka
```

4. **Run database migrations**
```bash
make migrate-up
```

5. **Start the backend server**
```bash
make run-api
```

6. **Start the frontend (in a new terminal)**
```bash
cd frontend
npm install
npm run dev
```

7. **Build and deploy Solana program (Devnet)**
```bash
cd solana-program
anchor build
anchor deploy
```

### Using Docker Compose (Full Stack)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## 📂 Project Structure

```
lung-oraculum/
├── cmd/                    # Application entry points
│   ├── api/               # Main API server
│   ├── crawler/           # Web crawler service
│   └── worker/            # Background workers
├── internal/              # Private application code
│   ├── domain/            # Business entities
│   ├── usecase/           # Business logic
│   ├── adapter/           # External adapters (DB, APIs, etc.)
│   ├── config/            # Configuration
│   └── middleware/        # HTTP middleware
├── pkg/                   # Public packages
│   ├── logger/
│   ├── validator/
│   ├── jwt/
│   └── errors/
├── solana-program/        # Solana smart contracts
│   ├── programs/
│   └── tests/
├── frontend/              # React application
│   └── src/
├── migrations/            # SQL migrations
├── docker/                # Docker configurations
├── k8s/                   # Kubernetes manifests
├── scripts/               # Utility scripts
└── docs/                  # Documentation
```

## 🔧 Development Commands

```bash
# Backend
make run-api          # Run API server
make run-crawler      # Run crawler service
make run-worker       # Run background worker
make test             # Run tests
make lint             # Run linter
make build            # Build all binaries

# Database
make migrate-up       # Apply migrations
make migrate-down     # Rollback migrations
make migrate-create   # Create new migration

# Solana
make anchor-build     # Build Solana program
make anchor-test      # Test Solana program
make anchor-deploy    # Deploy to configured network

# Docker
make docker-build     # Build Docker images
make docker-up        # Start all services
make docker-down      # Stop all services

# Frontend
cd frontend && npm run dev      # Development server
cd frontend && npm run build    # Production build
cd frontend && npm test         # Run tests
```

## 🧪 Testing

### Backend Tests
```bash
# Run all tests
make test

# Run specific package tests
go test ./internal/usecase/prediction/... -v

# Run with coverage
make test-coverage
```

### Frontend Tests
```bash
cd frontend
npm test                    # Run tests
npm run test:coverage       # With coverage
```

### Solana Program Tests
```bash
cd solana-program
anchor test
```

## 🔐 Security

### Anti-Fraud Measures
- Time-based prediction locks
- Multi-account detection
- Wash trading detection
- Rate limiting (Redis-based)
- Device fingerprinting
- Behavioral analysis

### Best Practices
- Never commit `.env` files
- Rotate secrets regularly
- Use hardware wallets for production
- Enable 2FA for admin accounts
- Regular security audits

See [Security Guide](./docs/SECURITY.md) for more details (Coming soon).

## 📊 Database Schema

See [migrations/](./migrations/) for the complete database schema.

Key tables:
- `users` - User accounts and wallet addresses
- `events` - Prediction events
- `predictions` - User predictions
- `leaderboard` - User rankings
- `audit_logs` - Security audit trail

## 🌐 API Documentation

The API follows REST principles and uses JSON for request/response bodies.

### Base URL
- Development: `http://localhost:8080/api/v1`
- Production: `https://api.lungoraculum.com/api/v1`

### Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

See [API Documentation](./docs/API.md) for complete endpoint reference (Coming soon).

## 🔗 Blockchain Integration

### Solana Networks
- **Devnet**: Development and testing
- **Testnet**: Pre-production testing
- **Mainnet-beta**: Production

### Supported Wallets
- Phantom
- Solflare
- Backpack
- Any wallet supporting Solana Wallet Adapter

## 📈 Monitoring

### Metrics
- Prometheus metrics exposed at `/metrics`
- Grafana dashboards for visualization
- Custom business metrics (predictions/hour, revenue, etc.)

### Logging
- Structured logging with Zap
- Log aggregation with ELK stack (production)
- Audit logs for all critical operations

## 🚢 Deployment

### Development
```bash
docker-compose up -d
```

### Production (Kubernetes)
```bash
# Build and push images
make docker-build
docker push <your-registry>/lung-oraculum-api:latest

# Deploy to Kubernetes
kubectl apply -f k8s/
```

See [Deployment Guide](./docs/DEPLOYMENT.md) for detailed instructions (Coming soon).

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines (Coming soon).

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- Solana Foundation
- Anchor Framework
- Gin Web Framework
- React Team

## 📞 Support

- Documentation: [docs.lungoraculum.com](https://docs.lungoraculum.com) (Coming soon)
- Discord: [Join our community](https://discord.gg/lungoraculum) (Coming soon)
- Twitter: [@LungOraculum](https://twitter.com/lungoraculum) (Coming soon)
- Email: support@lungoraculum.com

## 🗺️ Roadmap

See [ROADMAP.md](./ROADMAP.md) for detailed development phases (MVP to Production).

### Current Phase: **Phase 1 - MVP Foundation** 🚧

**Next Milestones:**
- [ ] Complete backend API implementation
- [ ] Solana program deployment on Devnet
- [ ] Basic frontend UI
- [ ] User authentication and wallet integration

---

**Built with ❤️ by the LUNG Oraculum Team**
