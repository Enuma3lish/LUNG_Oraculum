# LUNG Oraculum - Solana Prediction Game Roadmap

## 🎯 Project Overview

A decentralized prediction market platform built on Solana blockchain, enabling users to predict future events with real-time updates, blockchain-based order recording, and comprehensive user behavior analytics.

---

## 🏗️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend Layer                           │
│                         (React.js)                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Prediction UI│  │  Real-time   │  │  Wallet      │          │
│  │              │  │  Events Feed │  │  Integration │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    WebSocket + REST API
                         │
┌────────────────────────┴────────────────────────────────────────┐
│                      Backend Layer (Go-Gin)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   API        │  │  WebSocket   │  │  Prediction  │          │
│  │   Gateway    │  │  Handler     │  │  Engine      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Auth/JWT    │  │  Rate        │  │  Anti-Attack │          │
│  │  Service     │  │  Limiter     │  │  Service     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────┬──────────────┬──────────────┬────────────────────┘
              │              │              │
         ┌────┴────┐    ┌────┴────┐   ┌────┴────┐
         │         │    │         │   │         │
         ▼         ▼    ▼         ▼   ▼         ▼
┌─────────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐
│ PostgreSQL  │ │  Redis   │ │  Kafka   │ │   Solana     │
│             │ │          │ │          │ │  Blockchain  │
│ - Users     │ │ - Cache  │ │ - Events │ │              │
│ - Events    │ │ - Session│ │ - Logs   │ │ - Orders     │
│ - Orders    │ │ - Behav. │ │ - Tasks  │ │ - Wallets    │
│ - Leaderbd  │ │ - Locks  │ │          │ │ - Payments   │
└─────────────┘ └──────────┘ └──────────┘ └──────────────┘
         ▲                         │
         │                         ▼
         │                  ┌──────────────┐
         │                  │   Kafka      │
         │                  │  Consumers   │
         │                  └──────┬───────┘
         │                         │
         └─────────────────────────┘
              (Event Processing)

┌─────────────────────────────────────────────────────────────────┐
│                    Background Services                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Web Crawler  │  │  Event       │  │  Blockchain  │          │
│  │ Service      │  │  Validator   │  │  Listener    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Technology Stack

### Backend
- **Framework**: Go-Gin (HTTP web framework)
- **Language**: Go 1.21+
- **Dependencies**:
  - `github.com/gin-gonic/gin` - Web framework
  - `github.com/lib/pq` - PostgreSQL driver
  - `github.com/go-redis/redis/v9` - Redis client
  - `github.com/segmentio/kafka-go` - Kafka client
  - `github.com/gagliardetto/solana-go` - Solana SDK
  - `github.com/golang-jwt/jwt/v5` - JWT authentication
  - `github.com/joho/godotenv` - Environment configuration

### Frontend
- **Framework**: React.js 18+
- **State Management**: Redux Toolkit / Zustand
- **Real-time**: WebSocket / Socket.io client
- **Blockchain**: @solana/web3.js, @solana/wallet-adapter
- **UI Library**: Tailwind CSS / Material-UI
- **Charts**: Recharts / Chart.js (for prediction graphs)

### Blockchain
- **Network**: Solana (Devnet → Testnet → Mainnet-beta)
- **Program**: Anchor Framework (Rust)
- **Wallet**: Phantom, Solflare integration

### Infrastructure
- **Database**: PostgreSQL 15+ (with TimescaleDB for time-series data)
- **Cache**: Redis 7+ (with Redis Streams for pub/sub)
- **Message Broker**: Apache Kafka 3.x (or Redpanda for easier setup)
- **Web Crawler**: Colly (Go) / Scrapy (Python microservice)
- **Monitoring**: Prometheus + Grafana
- **Logging**: Zap (structured logging)

---

## 🚀 MVP to Production Roadmap

### **Phase 1: MVP Foundation (Weeks 1-4)**

#### Goals
- Basic prediction game functionality
- Simple event creation and betting
- Solana wallet integration
- Core backend APIs

#### Deliverables

**Week 1-2: Project Setup & Core Backend**
- [ ] Initialize Go module and project structure
- [ ] Set up PostgreSQL database with initial schema
- [ ] Implement user authentication (JWT)
- [ ] Create basic REST API endpoints:
  - `POST /api/auth/register` - User registration
  - `POST /api/auth/login` - User login
  - `GET /api/events` - List prediction events
  - `POST /api/predictions` - Submit prediction
  - `GET /api/predictions/:id` - Get prediction details
- [ ] Set up Redis for session management
- [ ] Basic Solana wallet connection (read-only)

**Week 3: Frontend Foundation**
- [ ] React app initialization with Vite
- [ ] Wallet adapter integration (Phantom)
- [ ] Basic UI components:
  - Login/Register page
  - Event listing page
  - Prediction submission form
  - User dashboard
- [ ] API integration layer (axios/fetch)
- [ ] Basic routing (React Router)

**Week 4: Basic Blockchain Integration**
- [ ] Solana program development (Anchor):
  - Initialize program
  - Create prediction account structure
  - Submit prediction instruction
  - Settle prediction instruction
- [ ] Backend Solana integration:
  - Submit predictions to blockchain
  - Read prediction states
  - Basic transaction monitoring
- [ ] Testing on Solana Devnet

**Database Schema (MVP)**
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    wallet_address VARCHAR(44) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Events table
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    event_type VARCHAR(50), -- binary, multiple_choice, scalar
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    resolution_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, locked, resolved, cancelled
    resolution_source TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Predictions table
CREATE TABLE predictions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    event_id INTEGER REFERENCES events(id),
    outcome VARCHAR(50) NOT NULL,
    amount DECIMAL(20, 9) NOT NULL, -- SOL amount
    solana_tx_signature VARCHAR(88),
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, settled, failed
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, event_id, solana_tx_signature)
);

-- Indexes
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_predictions_user ON predictions(user_id);
CREATE INDEX idx_predictions_event ON predictions(event_id);
```

---

### **Phase 2: Real-time Features (Weeks 5-7)**

#### Goals
- Kafka integration for event streaming
- WebSocket for real-time updates
- Redis for user behavior tracking
- Enhanced UI with live data

#### Deliverables

**Week 5: Kafka Setup**
- [ ] Set up Kafka broker (local/Docker)
- [ ] Create topics:
  - `prediction.submitted`
  - `prediction.confirmed`
  - `event.created`
  - `event.resolved`
  - `user.activity`
- [ ] Implement Kafka producers in Go backend
- [ ] Implement Kafka consumers for data processing
- [ ] Event sourcing for prediction lifecycle

**Week 6: WebSocket & Real-time Updates**
- [ ] WebSocket server implementation in Go-Gin
- [ ] Real-time event feed on frontend
- [ ] Live prediction updates
- [ ] Active users counter
- [ ] Price/odds updates in real-time
- [ ] Toast notifications for events

**Week 7: User Behavior Tracking**
- [ ] Redis implementation for:
  - Page views tracking
  - Click events
  - Prediction patterns
  - Session duration
  - Frequently viewed events
- [ ] Behavioral analytics API endpoints
- [ ] User activity dashboard
- [ ] Personalized event recommendations (basic)

**Redis Data Structures**
```go
// User session
user:session:{user_id} -> Hash {
    "last_active": timestamp,
    "current_page": string,
    "wallet_connected": bool
}

// User behavior
user:behavior:{user_id}:views -> Sorted Set (timestamp, event_id)
user:behavior:{user_id}:predictions -> List [event_ids]
user:behavior:{user_id}:interests -> Hash {category: count}

// Real-time counters
event:{event_id}:active_viewers -> Set [user_ids]
global:active_users -> Set [user_ids]

// Rate limiting
ratelimit:{user_id}:{endpoint} -> String (count) with TTL
```

---

### **Phase 3: Advanced Features (Weeks 8-11)**

#### Goals
- Web crawler for event data
- Advanced prediction engine
- Market odds calculation
- Social features

#### Deliverables

**Week 8: Web Crawler Service**
- [ ] Design crawler architecture:
  - News APIs (NewsAPI, GDELT)
  - Sports data (ESPN API, The Odds API)
  - Financial data (Alpha Vantage, CoinGecko)
  - Weather data (OpenWeatherMap)
- [ ] Implement crawler service:
  - Scheduled scraping jobs
  - Data parsing and normalization
  - Event auto-creation pipeline
  - Duplicate detection
- [ ] Admin approval workflow for auto-generated events
- [ ] Crawler monitoring dashboard

**Week 9: Prediction Engine Enhancement**
- [ ] Market odds calculation (AMM-style)
- [ ] Dynamic pricing based on liquidity
- [ ] Prediction pools (Yes/No liquidity pools)
- [ ] Share-based prediction system
- [ ] Historical odds tracking
- [ ] Profit/Loss calculation
- [ ] Leaderboard system

**Week 10: Smart Contract Enhancements**
- [ ] Liquidity pool implementation
- [ ] Automated market maker (AMM) logic
- [ ] Oracle integration for event resolution
- [ ] Multi-outcome predictions
- [ ] Partial settlement support
- [ ] Emergency pause mechanism

**Week 11: Social Features**
- [ ] User profiles with prediction history
- [ ] Follow/Unfollow users
- [ ] Activity feed
- [ ] Comments on events
- [ ] Share predictions (with privacy controls)
- [ ] Achievement badges
- [ ] Referral system

**Additional Database Tables**
```sql
-- Leaderboard
CREATE TABLE leaderboard (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) UNIQUE,
    total_predictions INTEGER DEFAULT 0,
    correct_predictions INTEGER DEFAULT 0,
    accuracy_rate DECIMAL(5, 2),
    total_profit DECIMAL(20, 9),
    rank INTEGER,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Event sources (for crawler)
CREATE TABLE event_sources (
    id SERIAL PRIMARY KEY,
    source_name VARCHAR(100) NOT NULL,
    source_url TEXT,
    source_type VARCHAR(50), -- api, rss, scraper
    category VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    last_crawled TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- User interests (for personalization)
CREATE TABLE user_interests (
    user_id INTEGER REFERENCES users(id),
    category VARCHAR(50),
    interest_score INTEGER DEFAULT 0,
    PRIMARY KEY (user_id, category)
);
```

---

### **Phase 4: Security & Anti-Attack (Weeks 12-14)**

#### Goals
- Implement comprehensive security measures
- Prevent prediction manipulation attacks
- Rate limiting and abuse prevention
- Audit logging

#### Critical Security Measures

**1. Prediction Attack Prevention**

**Attack Vectors to Defend Against:**
- **Time-based attacks**: Submitting predictions right before event starts
- **Information asymmetry**: Using non-public information
- **Wash trading**: Creating fake volume with multiple accounts
- **Oracle manipulation**: Attempting to influence event resolution
- **Front-running**: MEV attacks on Solana transactions
- **Sybil attacks**: Multiple fake accounts for bonuses
- **Late prediction**: Exploiting time zone differences

**Mitigation Strategies:**

```go
// 1. Time-based Restrictions
type PredictionTimeGuard struct {
    MinTimeBeforeEvent time.Duration // e.g., 5 minutes
    MaxTimeBeforeEvent time.Duration // e.g., 30 days
}

// 2. Rate Limiting (Redis-based)
type RateLimiter struct {
    MaxPredictionsPerHour int // e.g., 50
    MaxPredictionsPerDay  int // e.g., 200
    MaxSameEventPredictions int // e.g., 1 or allow updates
}

// 3. Amount Limits
type AmountGuard struct {
    MinPredictionAmount float64 // e.g., 0.01 SOL
    MaxPredictionAmount float64 // e.g., 10 SOL (for new users)
    MaxDailyVolume      float64 // e.g., 50 SOL
}

// 4. Pattern Detection (Redis ML)
type BehaviorAnalyzer struct {
    DetectMultiAccounting  bool // IP, device fingerprinting
    DetectWashTrading      bool // Circular betting patterns
    DetectAbnormalPatterns bool // Sudden large bets, timing patterns
}

// 5. KYC Levels
type UserTier struct {
    Tier1 // Email verified - Low limits
    Tier2 // Phone verified - Medium limits
    Tier3 // KYC verified - High limits
}
```

**Implementation Checklist:**
- [ ] Prediction deadline enforcement (no bets after event starts)
- [ ] Exponential backoff for repeated predictions
- [ ] Device fingerprinting (FingerprintJS)
- [ ] IP-based rate limiting with Redis
- [ ] Captcha for suspicious activity (hCaptcha)
- [ ] Multi-account detection:
  - Same IP address analysis
  - Wallet funding pattern analysis
  - Similar prediction patterns
- [ ] Transaction monitoring:
  - Suspicious transaction patterns
  - Rapid deposits/withdrawals
  - Coordinated betting rings
- [ ] Admin alert system for flagged activities

**2. Blockchain Security**
- [ ] Program account validation (Anchor constraints)
- [ ] PDA (Program Derived Address) security
- [ ] Reentrancy guards
- [ ] Integer overflow protection
- [ ] Signer validation
- [ ] Compute budget optimization
- [ ] Transaction priority fees
- [ ] Slippage protection

**3. Backend Security**
- [ ] Input validation and sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS protection
- [ ] CSRF tokens
- [ ] Secure headers (Helmet.js equivalent)
- [ ] API authentication (JWT with refresh tokens)
- [ ] Role-based access control (RBAC)
- [ ] Secrets management (HashiCorp Vault / AWS Secrets Manager)
- [ ] Audit logging (all critical actions)

**4. Infrastructure Security**
- [ ] HTTPS/TLS everywhere
- [ ] Database encryption at rest
- [ ] Redis password authentication
- [ ] Kafka SSL/SASL authentication
- [ ] DDoS protection (Cloudflare)
- [ ] Web Application Firewall (WAF)
- [ ] Regular security scans (OWASP ZAP)
- [ ] Dependency vulnerability scanning (Snyk)

**Audit Log Schema**
```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50) NOT NULL, -- prediction_submitted, event_created, etc.
    resource_type VARCHAR(50),
    resource_id INTEGER,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);
```

---

### **Phase 5: Scalability & Optimization (Weeks 15-17)**

#### Goals
- Horizontal scaling preparation
- Performance optimization
- Caching strategies
- Database optimization

#### Deliverables

**Week 15: Database Optimization**
- [ ] Implement TimescaleDB for time-series data
- [ ] Database partitioning (predictions by month)
- [ ] Materialized views for leaderboards
- [ ] Query optimization and indexing
- [ ] Connection pooling (PgBouncer)
- [ ] Read replicas for analytics queries
- [ ] Database backup strategy

**Week 16: Caching Strategy**
- [ ] Multi-level caching:
  - L1: In-memory cache (go-cache)
  - L2: Redis cache
  - L3: CDN (Cloudflare)
- [ ] Cache warming strategies
- [ ] Cache invalidation patterns
- [ ] Event list caching
- [ ] User profile caching
- [ ] Static asset optimization

**Week 17: Microservices Preparation**
- [ ] Service decomposition design:
  - Auth service
  - Prediction service
  - Event service
  - Notification service
  - Analytics service
  - Crawler service
- [ ] API Gateway implementation (Kong / Traefik)
- [ ] Service mesh evaluation (Istio)
- [ ] Container orchestration (Docker + Kubernetes)
- [ ] Load balancing (Nginx / HAProxy)

---

### **Phase 6: Advanced Analytics & Personalization (Weeks 18-20)**

#### Goals
- Per-user event databases (MongoDB)
- Advanced analytics
- Machine learning for recommendations
- Personalized user experience

#### Deliverables

**Week 18: Per-User Event History (MongoDB)**
- [ ] MongoDB setup for document storage
- [ ] Schema design:
```javascript
// User event summary collection
{
    user_id: ObjectId,
    event_summaries: [
        {
            event_id: Number,
            event_title: String,
            prediction_outcome: String,
            predicted_at: Date,
            resolved_at: Date,
            result: String, // won, lost, pending
            profit_loss: Number,
            odds_at_prediction: Number,
            tags: [String],
            notes: String,
            similar_events: [Number] // AI-suggested
        }
    ],
    summary_stats: {
        total_events: Number,
        win_rate: Number,
        best_category: String,
        worst_category: String,
        total_profit: Number
    },
    updated_at: Date
}
```
- [ ] Background job to sync PostgreSQL → MongoDB
- [ ] API endpoints for user history queries
- [ ] Export user history (PDF/CSV)

**Week 19: Analytics Dashboard**
- [ ] Admin analytics:
  - Daily active users (DAU)
  - Total predictions volume
  - Revenue metrics
  - Event popularity
  - User retention cohorts
  - Churn prediction
- [ ] User analytics:
  - Personal performance metrics
  - Category-wise accuracy
  - Profit/loss graphs
  - Prediction timing analysis
  - Comparison with top users
- [ ] Data visualization (Recharts/D3.js)

**Week 20: ML Recommendations**
- [ ] Event recommendation engine:
  - Collaborative filtering
  - Content-based filtering
  - Hybrid approach
- [ ] Feature engineering:
  - User prediction history
  - Category preferences
  - Time-of-day patterns
  - Social connections
- [ ] Model training pipeline (Python microservice)
- [ ] Model serving (TensorFlow Serving / Seldon)
- [ ] A/B testing framework for recommendations

---

### **Phase 7: Production Readiness (Weeks 21-24)**

#### Goals
- Full production deployment
- Monitoring and observability
- Disaster recovery
- Compliance and legal

#### Deliverables

**Week 21: Monitoring & Observability**
- [ ] Prometheus metrics:
  - Request latency (p50, p95, p99)
  - Error rates
  - Active connections
  - Database query times
  - Kafka lag
  - Solana RPC response times
- [ ] Grafana dashboards:
  - System health overview
  - Application metrics
  - Business metrics (predictions/hour, revenue)
  - Blockchain metrics
- [ ] Distributed tracing (Jaeger / Zipkin)
- [ ] Log aggregation (ELK stack / Loki)
- [ ] Error tracking (Sentry)
- [ ] Uptime monitoring (Pingdom / UptimeRobot)
- [ ] PagerDuty / Opsgenie for alerts

**Week 22: Deployment & CI/CD**
- [ ] Dockerization:
  - Multi-stage builds
  - Optimized images
  - Security scanning
- [ ] Kubernetes manifests:
  - Deployments
  - Services
  - Ingress
  - ConfigMaps
  - Secrets
  - HPA (Horizontal Pod Autoscaler)
- [ ] CI/CD pipeline (GitHub Actions / GitLab CI):
  - Automated testing
  - Code linting
  - Security scanning
  - Build and push images
  - Deploy to staging
  - Deploy to production (manual approval)
- [ ] Blue-green deployment strategy
- [ ] Rollback procedures

**Week 23: Disaster Recovery & Backup**
- [ ] Database backup strategy:
  - Daily full backups
  - Hourly incremental backups
  - Point-in-time recovery testing
  - Cross-region replication
- [ ] Redis persistence (RDB + AOF)
- [ ] Kafka topic replication
- [ ] Disaster recovery plan documentation
- [ ] Incident response playbook
- [ ] Data retention policies
- [ ] GDPR compliance (right to be forgotten)

**Week 24: Legal & Compliance**
- [ ] Terms of Service
- [ ] Privacy Policy
- [ ] Cookie Policy
- [ ] Responsible Gaming features:
  - Self-exclusion
  - Deposit limits
  - Time limits
  - Reality checks
- [ ] Age verification (18+)
- [ ] Jurisdiction restrictions
- [ ] AML/KYC procedures (if required)
- [ ] Tax reporting (Form 1099 for US users if applicable)
- [ ] Gambling license consultation (jurisdiction-dependent)

---

## 🔒 Security Deep Dive

### Anti-Prediction Attack Strategies

#### 1. **Time Lock Mechanism**
```go
func ValidatePredictionTiming(event *Event, submittedAt time.Time) error {
    // Prevent predictions too close to event start
    minTimeBeforeEvent := 5 * time.Minute
    if event.StartTime.Sub(submittedAt) < minTimeBeforeEvent {
        return errors.New("predictions locked: event starting soon")
    }

    // Prevent predictions too far in advance (quality control)
    maxTimeBeforeEvent := 30 * 24 * time.Hour
    if submittedAt.Before(event.StartTime.Add(-maxTimeBeforeEvent)) {
        return errors.New("event not yet available for predictions")
    }

    return nil
}
```

#### 2. **Multi-Account Detection**
```go
type SybilDetector struct {
    redis *redis.Client
}

func (sd *SybilDetector) DetectMultiAccounting(userID int, ipAddress, deviceID string) (bool, error) {
    // Check IP address history
    key := fmt.Sprintf("ip:%s:users", ipAddress)
    userCount, err := sd.redis.SCard(ctx, key).Result()
    if err != nil {
        return false, err
    }

    if userCount > 5 { // More than 5 accounts from same IP
        sd.flagForReview(userID, "multiple_accounts_same_ip")
        return true, nil
    }

    // Check device fingerprint
    deviceKey := fmt.Sprintf("device:%s:users", deviceID)
    deviceUserCount, err := sd.redis.SCard(ctx, deviceKey).Result()
    if err != nil {
        return false, err
    }

    if deviceUserCount > 3 {
        sd.flagForReview(userID, "multiple_accounts_same_device")
        return true, nil
    }

    return false, nil
}
```

#### 3. **Wash Trading Detection**
```go
type WashTradingDetector struct {
    db *sql.DB
}

func (wtd *WashTradingDetector) AnalyzeUserNetwork(userID int) error {
    // Find users who frequently bet opposite sides of same events
    query := `
        WITH user_predictions AS (
            SELECT event_id, outcome FROM predictions WHERE user_id = $1
        ),
        opposite_predictions AS (
            SELECT p.user_id, COUNT(*) as opposite_count
            FROM predictions p
            JOIN user_predictions up ON p.event_id = up.event_id
            WHERE p.user_id != $1
            AND p.outcome != up.outcome
            GROUP BY p.user_id
        )
        SELECT user_id, opposite_count
        FROM opposite_predictions
        WHERE opposite_count > 10
    `

    rows, err := wtd.db.Query(query, userID)
    // If pattern detected, flag both accounts
    // ...
    return nil
}
```

#### 4. **Rate Limiting Implementation**
```go
type PredictionRateLimiter struct {
    redis *redis.Client
}

func (rl *PredictionRateLimiter) AllowPrediction(userID int) (bool, error) {
    hourKey := fmt.Sprintf("ratelimit:%d:hour:%s", userID, time.Now().Format("2006010215"))
    dayKey := fmt.Sprintf("ratelimit:%d:day:%s", userID, time.Now().Format("20060102"))

    // Increment counters
    hourCount, _ := rl.redis.Incr(ctx, hourKey).Result()
    rl.redis.Expire(ctx, hourKey, time.Hour)

    dayCount, _ := rl.redis.Incr(ctx, dayKey).Result()
    rl.redis.Expire(ctx, dayKey, 24*time.Hour)

    // Check limits
    if hourCount > 50 {
        return false, errors.New("hourly prediction limit exceeded")
    }
    if dayCount > 200 {
        return false, errors.New("daily prediction limit exceeded")
    }

    return true, nil
}
```

#### 5. **Oracle Manipulation Prevention**
```go
// Use multiple oracle sources for event resolution
type OracleResolver struct {
    sources []OracleSource
}

func (or *OracleResolver) ResolveEvent(eventID int) (string, error) {
    results := make(map[string]int)

    // Query multiple sources
    for _, source := range or.sources {
        result, err := source.GetResult(eventID)
        if err != nil {
            continue
        }
        results[result]++
    }

    // Require consensus from majority
    for outcome, count := range results {
        if count >= len(or.sources)/2+1 {
            return outcome, nil
        }
    }

    return "", errors.New("no consensus reached - manual review required")
}
```

---

## 📊 Database Scaling Strategy

### Partitioning Strategy
```sql
-- Partition predictions table by month
CREATE TABLE predictions (
    id BIGSERIAL NOT NULL,
    user_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    -- other fields
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE predictions_2024_01 PARTITION OF predictions
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE predictions_2024_02 PARTITION OF predictions
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- etc.

-- Automatic partition creation (use pg_partman extension)
```

### Read Replicas
```
Primary DB (Write) → Replica 1 (Read - Analytics)
                   → Replica 2 (Read - User Queries)
                   → Replica 3 (Read - Leaderboards)
```

---

## 🚀 Deployment Architecture

### Production Infrastructure (AWS Example)

```
┌─────────────────────────────────────────────────────────────┐
│                         CloudFlare CDN                       │
│                    (DDoS Protection + WAF)                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer (ALB)                       │
└────────┬────────────────────────────────────┬───────────────┘
         │                                    │
         ▼                                    ▼
┌──────────────────┐                 ┌──────────────────┐
│   ECS/EKS        │                 │   ECS/EKS        │
│   (Go Backend)   │                 │   (Go Backend)   │
│   Auto Scaling   │                 │   Auto Scaling   │
└────────┬─────────┘                 └────────┬─────────┘
         │                                    │
         └────────────────┬───────────────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
         ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ RDS Postgres │  │ ElastiCache  │  │     MSK      │
│  (Primary +  │  │   (Redis)    │  │   (Kafka)    │
│   Replicas)  │  │  Cluster     │  │   Cluster    │
└──────────────┘  └──────────────┘  └──────────────┘

┌──────────────────────────────────────────────────────────┐
│                  S3 (Static Assets)                       │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│              Solana RPC Nodes (Dedicated)                 │
│          (Mainnet-beta + Fallback Providers)             │
└──────────────────────────────────────────────────────────┘
```

---

## 📈 Performance Targets

### MVP (Phase 1)
- Response time: < 500ms (p95)
- Concurrent users: 100
- Predictions/second: 10
- Uptime: 95%

### Production (Phase 7)
- Response time: < 200ms (p95)
- Concurrent users: 10,000+
- Predictions/second: 1,000+
- Uptime: 99.9%
- Database queries: < 100ms (p95)
- Kafka lag: < 1 second
- WebSocket latency: < 50ms

---

## 🧪 Testing Strategy

### Unit Tests
- Go: `go test` with testify
- React: Jest + React Testing Library
- Solana: Anchor test framework

### Integration Tests
- API testing: Postman/Newman
- End-to-end: Playwright / Cypress
- Load testing: k6 / Locust

### Security Testing
- OWASP ZAP scans
- Dependency scanning: Snyk
- Smart contract audits: Certora / Trail of Bits
- Penetration testing (before production)

---

## 💰 Cost Estimation (Monthly)

### MVP Phase
- AWS/GCP: $200-500
- Solana Devnet: Free
- Kafka (Confluent Cloud): $100-200
- MongoDB Atlas: $50-100
- Domain + SSL: $20
- **Total**: ~$400-800/month

### Production Phase
- Cloud Infrastructure: $2,000-5,000
- Solana RPC (dedicated): $500-1,000
- Kafka: $500-1,000
- Databases: $500-1,500
- Monitoring: $200-300
- CDN: $100-300
- **Total**: ~$4,000-9,000/month (for moderate scale)

---

## 📋 Production Readiness Checklist

### Infrastructure
- [ ] Multi-region deployment
- [ ] Auto-scaling configured
- [ ] Load balancer health checks
- [ ] CDN configured
- [ ] SSL certificates installed
- [ ] Firewall rules configured
- [ ] VPC/network security

### Monitoring
- [ ] Prometheus + Grafana
- [ ] Error tracking (Sentry)
- [ ] Log aggregation
- [ ] Uptime monitoring
- [ ] Alert rules configured
- [ ] On-call rotation setup

### Security
- [ ] Security audit completed
- [ ] Penetration test passed
- [ ] Smart contract audit
- [ ] HTTPS enforced
- [ ] Secrets rotated
- [ ] Backup tested
- [ ] Disaster recovery plan

### Legal
- [ ] Terms of Service
- [ ] Privacy Policy
- [ ] GDPR compliance
- [ ] Age verification
- [ ] Jurisdiction restrictions
- [ ] Responsible gaming features

### Performance
- [ ] Load testing completed
- [ ] Database optimized
- [ ] Caching implemented
- [ ] Static assets optimized
- [ ] Query performance verified

---

## 🎓 Learning Resources

### Go + Gin
- [Gin Documentation](https://gin-gonic.com/docs/)
- [Effective Go](https://golang.org/doc/effective_go.html)

### Solana
- [Solana Cookbook](https://solanacookbook.com/)
- [Anchor Framework](https://www.anchor-lang.com/)
- [Solana Web3.js](https://solana-labs.github.io/solana-web3.js/)

### Kafka
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Confluent Tutorials](https://developer.confluent.io/)

### React
- [React Documentation](https://react.dev/)
- [Solana Wallet Adapter](https://github.com/solana-labs/wallet-adapter)

---

## 🗓️ Timeline Summary

| Phase | Duration | Key Milestone |
|-------|----------|---------------|
| Phase 1: MVP Foundation | 4 weeks | Basic prediction game working |
| Phase 2: Real-time Features | 3 weeks | Kafka + WebSocket live |
| Phase 3: Advanced Features | 4 weeks | Crawler + Social features |
| Phase 4: Security | 3 weeks | Anti-attack measures implemented |
| Phase 5: Scalability | 3 weeks | Performance optimized |
| Phase 6: Analytics | 3 weeks | ML recommendations live |
| Phase 7: Production | 4 weeks | Production deployment |
| **Total** | **24 weeks (~6 months)** | **Production-ready platform** |

---

## 🎯 Success Metrics

### User Metrics
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- User retention (Day 1, Day 7, Day 30)
- Average predictions per user

### Business Metrics
- Total Value Locked (TVL)
- Daily prediction volume
- Revenue (if applicable)
- User acquisition cost (UAC)

### Technical Metrics
- Uptime %
- Response time (p50, p95, p99)
- Error rate
- Solana transaction success rate

---

## 🔮 Future Enhancements (Post-MVP)

- Mobile apps (React Native)
- Telegram/Discord bot integration
- NFT rewards for top predictors
- DAO governance for event creation
- Cross-chain support (Ethereum, Polygon)
- Prediction pools/syndicates
- Copy trading features
- API marketplace for third-party integrations
- White-label solution for partners

---

**Last Updated**: 2025-11-16
**Version**: 1.0
**Status**: Initial Roadmap
