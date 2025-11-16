# System Architecture - LUNG Oraculum

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Component Design](#component-design)
3. [Data Flow](#data-flow)
4. [API Design](#api-design)
5. [Smart Contract Architecture](#smart-contract-architecture)
6. [Security Architecture](#security-architecture)
7. [Scalability Patterns](#scalability-patterns)

---

## Architecture Overview

### System Components

```
┌───────────────────────────────────────────────────────────────────┐
│                           Client Layer                             │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐             │
│  │   Web App   │  │  Mobile App  │  │  Admin      │             │
│  │  (React)    │  │ (Future)     │  │  Dashboard  │             │
│  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘             │
│         │                 │                  │                     │
│         └─────────────────┴──────────────────┘                     │
│                           │                                        │
└───────────────────────────┼────────────────────────────────────────┘
                            │
                    HTTPS/WSS + CORS
                            │
┌───────────────────────────┴────────────────────────────────────────┐
│                      API Gateway Layer                             │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Nginx / Kong / Traefik                                   │    │
│  │  - Rate Limiting                                          │    │
│  │  - Request Routing                                        │    │
│  │  - SSL Termination                                        │    │
│  │  - Load Balancing                                         │    │
│  └────────────────────────┬──────────────────────────────────┘    │
│                           │                                        │
└───────────────────────────┼────────────────────────────────────────┘
                            │
┌───────────────────────────┴────────────────────────────────────────┐
│                    Application Layer (Go-Gin)                      │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  Auth Service   │  │ Prediction Svc  │  │  Event Service  │  │
│  │                 │  │                 │  │                 │  │
│  │ - JWT Auth      │  │ - Validation    │  │ - CRUD          │  │
│  │ - Wallet Verify │  │ - Submission    │  │ - Resolution    │  │
│  │ - Session Mgmt  │  │ - Settlement    │  │ - Categories    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  User Service   │  │ Analytics Svc   │  │ Notification Svc│  │
│  │                 │  │                 │  │                 │  │
│  │ - Profile       │  │ - Metrics       │  │ - WebSocket     │  │
│  │ - Leaderboard   │  │ - Reports       │  │ - Push Notify   │  │
│  │ - Preferences   │  │ - Insights      │  │ - Email/SMS     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ Security Svc    │  │ Blockchain Svc  │  │  Crawler Svc    │  │
│  │                 │  │                 │  │                 │  │
│  │ - Rate Limit    │  │ - TX Monitor    │  │ - Event Fetch   │  │
│  │ - Anti-Attack   │  │ - Wallet Ops    │  │ - Data Parse    │  │
│  │ - Fraud Detect  │  │ - Program Calls │  │ - Auto-create   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                    │
└────┬────────────┬───────────────┬───────────────┬────────────┬────┘
     │            │               │               │            │
     ▼            ▼               ▼               ▼            ▼
┌─────────┐ ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ Postgres│ │  Redis   │  │  Kafka   │  │  Solana  │  │ MongoDB  │
│         │ │          │  │          │  │          │  │          │
│ Primary │ │ Cluster  │  │ Cluster  │  │ Mainnet  │  │ (Future) │
│ + Read  │ │          │  │          │  │          │  │          │
│ Replica │ │          │  │          │  │          │  │          │
└─────────┘ └──────────┘  └──────────┘  └──────────┘  └──────────┘
```

---

## Component Design

### 1. Backend Services Architecture (Hexagonal/Clean Architecture)

```
Project Structure:
lung-oraculum/
├── cmd/
│   ├── api/              # Main API server
│   │   └── main.go
│   ├── crawler/          # Web crawler service
│   │   └── main.go
│   └── worker/           # Background workers
│       └── main.go
├── internal/
│   ├── domain/           # Business logic (entities)
│   │   ├── user/
│   │   ├── event/
│   │   ├── prediction/
│   │   └── wallet/
│   ├── usecase/          # Application logic
│   │   ├── auth/
│   │   ├── prediction/
│   │   ├── event/
│   │   └── analytics/
│   ├── adapter/          # External adapters
│   │   ├── http/         # HTTP handlers (Gin)
│   │   ├── postgres/     # Database repo impl
│   │   ├── redis/        # Cache impl
│   │   ├── kafka/        # Message broker
│   │   └── solana/       # Blockchain adapter
│   ├── config/           # Configuration
│   └── middleware/       # HTTP middleware
├── pkg/                  # Shared packages
│   ├── logger/
│   ├── validator/
│   ├── jwt/
│   └── errors/
├── solana-program/       # Anchor program
│   ├── programs/
│   │   └── prediction/
│   ├── tests/
│   └── Anchor.toml
├── frontend/             # React app
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── store/
│   └── public/
├── migrations/           # SQL migrations
├── docker/               # Docker configs
├── k8s/                  # Kubernetes manifests
├── scripts/              # Utility scripts
└── docs/                 # Documentation
```

### 2. Domain Entities

```go
// internal/domain/user/user.go
package user

import "time"

type User struct {
    ID            int
    WalletAddress string
    Username      string
    Email         string
    Tier          UserTier
    IsActive      bool
    CreatedAt     time.Time
    UpdatedAt     time.Time
}

type UserTier int

const (
    TierBasic UserTier = iota
    TierVerified
    TierPremium
)

// internal/domain/event/event.go
package event

import "time"

type Event struct {
    ID               int
    Title            string
    Description      string
    Category         Category
    Type             EventType
    StartTime        time.Time
    EndTime          time.Time
    ResolutionTime   time.Time
    Status           EventStatus
    Outcomes         []Outcome
    ResolutionSource string
    CreatedBy        int
    CreatedAt        time.Time
}

type EventType string

const (
    EventTypeBinary       EventType = "binary"
    EventTypeMultiChoice  EventType = "multiple_choice"
    EventTypeScalar       EventType = "scalar"
)

type EventStatus string

const (
    StatusActive    EventStatus = "active"
    StatusLocked    EventStatus = "locked"
    StatusResolved  EventStatus = "resolved"
    StatusCancelled EventStatus = "cancelled"
)

type Category string

const (
    CategorySports     Category = "sports"
    CategoryPolitics   Category = "politics"
    CategoryCrypto     Category = "crypto"
    CategoryWeather    Category = "weather"
    CategoryEconomics  Category = "economics"
    CategoryEntertainment Category = "entertainment"
)

type Outcome struct {
    ID    int
    Label string
    Odds  float64
}

// internal/domain/prediction/prediction.go
package prediction

import "time"

type Prediction struct {
    ID               int
    UserID           int
    EventID          int
    Outcome          string
    Amount           float64
    Shares           float64
    SolanaTxSignature string
    Status           PredictionStatus
    CreatedAt        time.Time
    SettledAt        *time.Time
    ProfitLoss       *float64
}

type PredictionStatus string

const (
    StatusPending   PredictionStatus = "pending"
    StatusConfirmed PredictionStatus = "confirmed"
    StatusSettled   PredictionStatus = "settled"
    StatusFailed    PredictionStatus = "failed"
)
```

### 3. Use Cases (Application Logic)

```go
// internal/usecase/prediction/submit.go
package prediction

import (
    "context"
    "errors"
    "time"
)

type SubmitPredictionInput struct {
    UserID   int
    EventID  int
    Outcome  string
    Amount   float64
    DeviceID string
    IPAddress string
}

type SubmitPredictionUseCase struct {
    predictionRepo  PredictionRepository
    eventRepo       EventRepository
    solanaClient    SolanaClient
    kafkaProducer   KafkaProducer
    rateLimiter     RateLimiter
    securityService SecurityService
}

func (uc *SubmitPredictionUseCase) Execute(
    ctx context.Context,
    input SubmitPredictionInput,
) (*Prediction, error) {
    // 1. Validate user and event
    event, err := uc.eventRepo.GetByID(ctx, input.EventID)
    if err != nil {
        return nil, err
    }

    if event.Status != StatusActive {
        return nil, errors.New("event is not active")
    }

    // 2. Check timing constraints
    if time.Until(event.StartTime) < 5*time.Minute {
        return nil, errors.New("predictions locked - event starting soon")
    }

    // 3. Rate limiting
    allowed, err := uc.rateLimiter.AllowPrediction(ctx, input.UserID)
    if err != nil || !allowed {
        return nil, errors.New("rate limit exceeded")
    }

    // 4. Security checks
    suspicious, err := uc.securityService.DetectSuspiciousActivity(
        ctx,
        input.UserID,
        input.IPAddress,
        input.DeviceID,
    )
    if err != nil {
        return nil, err
    }
    if suspicious {
        return nil, errors.New("suspicious activity detected - verification required")
    }

    // 5. Submit to Solana blockchain
    txSignature, err := uc.solanaClient.SubmitPrediction(ctx, SolanaSubmitParams{
        UserWallet: input.UserID, // map to wallet
        EventID:    input.EventID,
        Outcome:    input.Outcome,
        Amount:     input.Amount,
    })
    if err != nil {
        return nil, err
    }

    // 6. Create prediction record
    prediction := &Prediction{
        UserID:            input.UserID,
        EventID:           input.EventID,
        Outcome:           input.Outcome,
        Amount:            input.Amount,
        SolanaTxSignature: txSignature,
        Status:            StatusPending,
        CreatedAt:         time.Now(),
    }

    if err := uc.predictionRepo.Create(ctx, prediction); err != nil {
        return nil, err
    }

    // 7. Publish event to Kafka
    uc.kafkaProducer.Publish(ctx, "prediction.submitted", prediction)

    return prediction, nil
}
```

---

## Data Flow

### Prediction Submission Flow

```
┌──────────┐
│  User    │
│ (React)  │
└────┬─────┘
     │ 1. Connect Wallet
     ▼
┌──────────────────┐
│ Wallet Adapter   │
│ (Phantom/etc)    │
└────┬─────────────┘
     │ 2. Request Signature
     ▼
┌──────────────────┐      3. POST /api/predictions     ┌───────────────┐
│  Frontend        ├──────────────────────────────────▶│  API Gateway  │
│  (React App)     │                                    │  (Nginx)      │
└──────────────────┘                                    └───────┬───────┘
                                                                │
                                                                ▼
                                                        ┌───────────────┐
                                                        │  Auth         │
                                                        │  Middleware   │
                                                        └───────┬───────┘
                                                                │ 4. Validate JWT
                                                                ▼
                                                        ┌───────────────┐
                                                        │ Prediction    │
                                                        │ Controller    │
                                                        └───────┬───────┘
                                                                │
                                                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      Prediction Use Case                                 │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ 5. Validate event exists and is active                          │    │
│  │ 6. Check timing (not too close to start)                        │    │
│  │ 7. Rate limiting check (Redis)                                  │    │
│  │ 8. Security check (multi-account detection)                     │    │
│  │ 9. Submit to Solana blockchain                                  │    │
│  │ 10. Save to PostgreSQL                                          │    │
│  │ 11. Publish to Kafka                                            │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────────┘
     │           │           │           │
     │           │           │           └──────────────┐
     │           │           │                          ▼
     │           │           │                  ┌───────────────┐
     │           │           │                  │  Kafka        │
     │           │           │                  │  Topic        │
     │           │           │                  └───────┬───────┘
     │           │           │                          │
     │           │           │                          ▼
     │           │           │                  ┌───────────────┐
     │           │           │                  │  Kafka        │
     │           │           │                  │  Consumer     │
     │           │           │                  └───────┬───────┘
     │           │           │                          │
     │           │           │                          ▼
     │           │           │                  ┌───────────────┐
     │           │           │                  │ WebSocket     │
     │           │           │                  │ Broadcast     │
     │           │           │                  └───────┬───────┘
     │           │           │                          │
     │           │           └────────┐                 ▼
     │           │                    ▼          ┌───────────────┐
     │           │            ┌───────────────┐  │  All          │
     │           │            │  Solana       │  │  Connected    │
     │           │            │  Program      │  │  Clients      │
     │           │            └───────┬───────┘  └───────────────┘
     │           │                    │
     │           │                    ▼
     │           │            ┌───────────────┐
     │           │            │  Blockchain   │
     │           │            │  Transaction  │
     │           │            └───────────────┘
     │           │
     │           ▼
     │   ┌───────────────┐
     │   │  PostgreSQL   │
     │   │  (Prediction) │
     │   └───────────────┘
     │
     ▼
┌───────────────┐
│  Redis        │
│  (Cache +     │
│   Behavior)   │
└───────────────┘
```

---

## API Design

### REST API Endpoints

```yaml
# Authentication
POST   /api/v1/auth/register          # Register new user
POST   /api/v1/auth/login             # Login with wallet signature
POST   /api/v1/auth/refresh           # Refresh JWT token
POST   /api/v1/auth/logout            # Logout

# Events
GET    /api/v1/events                 # List events (with filters)
GET    /api/v1/events/:id             # Get event details
POST   /api/v1/events                 # Create event (admin/verified users)
PUT    /api/v1/events/:id             # Update event
DELETE /api/v1/events/:id             # Cancel event
POST   /api/v1/events/:id/resolve     # Resolve event (admin)

# Predictions
POST   /api/v1/predictions            # Submit prediction
GET    /api/v1/predictions/:id        # Get prediction details
GET    /api/v1/predictions            # List user's predictions
PUT    /api/v1/predictions/:id        # Update prediction (before event start)

# Users
GET    /api/v1/users/me               # Get current user profile
PUT    /api/v1/users/me               # Update profile
GET    /api/v1/users/:id              # Get user profile (public)
GET    /api/v1/users/:id/predictions  # Get user's public predictions
GET    /api/v1/users/:id/stats        # Get user statistics

# Leaderboard
GET    /api/v1/leaderboard            # Global leaderboard
GET    /api/v1/leaderboard/:category  # Category leaderboard

# Analytics
GET    /api/v1/analytics/events/:id   # Event analytics (volume, odds)
GET    /api/v1/analytics/users/me     # Personal analytics

# Admin
GET    /api/v1/admin/users            # List all users
GET    /api/v1/admin/events           # Manage events
GET    /api/v1/admin/predictions      # View all predictions
GET    /api/v1/admin/audit-logs       # Audit logs
POST   /api/v1/admin/users/:id/ban    # Ban user
```

### API Request/Response Examples

```json
// POST /api/v1/predictions
// Request
{
  "event_id": 123,
  "outcome": "Yes",
  "amount": 1.5,
  "wallet_signature": "4Hj8kF..."
}

// Response
{
  "id": 456,
  "user_id": 789,
  "event_id": 123,
  "outcome": "Yes",
  "amount": 1.5,
  "shares": 1.47,
  "solana_tx_signature": "3nK7mP...",
  "status": "pending",
  "created_at": "2024-01-15T10:30:00Z"
}

// GET /api/v1/events?status=active&category=sports&limit=20&offset=0
// Response
{
  "events": [
    {
      "id": 123,
      "title": "Will Team A win the championship?",
      "description": "...",
      "category": "sports",
      "type": "binary",
      "start_time": "2024-02-01T20:00:00Z",
      "end_time": "2024-02-01T23:00:00Z",
      "status": "active",
      "outcomes": [
        {
          "label": "Yes",
          "odds": 1.85,
          "volume": 1250.5
        },
        {
          "label": "No",
          "odds": 2.10,
          "volume": 980.3
        }
      ],
      "total_volume": 2230.8,
      "participant_count": 157
    }
  ],
  "total": 45,
  "limit": 20,
  "offset": 0
}
```

### WebSocket Protocol

```javascript
// Client connects
const ws = new WebSocket('wss://api.lungoraculum.com/ws?token=JWT_TOKEN')

// Subscribe to events
ws.send(JSON.stringify({
  type: 'subscribe',
  channels: [
    'event.123',           // Specific event updates
    'predictions.global',  // All new predictions
    'user.789'            // User-specific notifications
  ]
}))

// Server messages
{
  type: 'prediction.submitted',
  channel: 'event.123',
  data: {
    event_id: 123,
    outcome: 'Yes',
    amount: 1.5,
    timestamp: '2024-01-15T10:30:00Z'
  }
}

{
  type: 'event.updated',
  channel: 'event.123',
  data: {
    event_id: 123,
    outcomes: [
      { label: 'Yes', odds: 1.83 },
      { label: 'No', odds: 2.12 }
    ]
  }
}

{
  type: 'notification',
  channel: 'user.789',
  data: {
    message: 'Your prediction on Event #123 has been settled',
    prediction_id: 456,
    profit_loss: 2.5
  }
}
```

---

## Smart Contract Architecture (Solana/Anchor)

### Program Accounts

```rust
// solana-program/programs/prediction/src/lib.rs

use anchor_lang::prelude::*;

declare_id!("YOUR_PROGRAM_ID");

#[program]
pub mod prediction {
    use super::*;

    pub fn initialize_event(
        ctx: Context<InitializeEvent>,
        event_id: u64,
        start_time: i64,
        end_time: i64,
    ) -> Result<()> {
        let event = &mut ctx.accounts.event;
        event.event_id = event_id;
        event.authority = ctx.accounts.authority.key();
        event.start_time = start_time;
        event.end_time = end_time;
        event.status = EventStatus::Active;
        event.total_yes_amount = 0;
        event.total_no_amount = 0;
        event.is_resolved = false;
        Ok(())
    }

    pub fn submit_prediction(
        ctx: Context<SubmitPrediction>,
        outcome: Outcome,
        amount: u64,
    ) -> Result<()> {
        let event = &ctx.accounts.event;
        let clock = Clock::get()?;

        // Validation
        require!(
            event.status == EventStatus::Active,
            ErrorCode::EventNotActive
        );
        require!(
            clock.unix_timestamp < event.start_time - 300, // 5 min before
            ErrorCode::PredictionLocked
        );

        let prediction = &mut ctx.accounts.prediction;
        prediction.user = ctx.accounts.user.key();
        prediction.event = ctx.accounts.event.key();
        prediction.outcome = outcome;
        prediction.amount = amount;
        prediction.timestamp = clock.unix_timestamp;
        prediction.is_settled = false;

        // Update event totals
        let event = &mut ctx.accounts.event;
        match outcome {
            Outcome::Yes => event.total_yes_amount += amount,
            Outcome::No => event.total_no_amount += amount,
        }

        Ok(())
    }

    pub fn settle_prediction(
        ctx: Context<SettlePrediction>,
        winning_outcome: Outcome,
    ) -> Result<()> {
        let event = &mut ctx.accounts.event;

        require!(
            ctx.accounts.authority.key() == event.authority,
            ErrorCode::Unauthorized
        );
        require!(!event.is_resolved, ErrorCode::AlreadyResolved);

        event.winning_outcome = Some(winning_outcome);
        event.is_resolved = true;
        event.status = EventStatus::Resolved;

        let prediction = &mut ctx.accounts.prediction;

        if prediction.outcome == winning_outcome {
            // Calculate payout based on AMM formula
            let total_pool = event.total_yes_amount + event.total_no_amount;
            let winning_pool = match winning_outcome {
                Outcome::Yes => event.total_yes_amount,
                Outcome::No => event.total_no_amount,
            };

            let payout = (prediction.amount as u128)
                .checked_mul(total_pool as u128)
                .unwrap()
                .checked_div(winning_pool as u128)
                .unwrap() as u64;

            prediction.payout = payout;
            prediction.is_settled = true;

            // Transfer payout to user
            // ... token transfer logic
        } else {
            prediction.payout = 0;
            prediction.is_settled = true;
        }

        Ok(())
    }
}

// Account structures
#[account]
pub struct Event {
    pub event_id: u64,
    pub authority: Pubkey,
    pub start_time: i64,
    pub end_time: i64,
    pub status: EventStatus,
    pub total_yes_amount: u64,
    pub total_no_amount: u64,
    pub winning_outcome: Option<Outcome>,
    pub is_resolved: bool,
}

#[account]
pub struct Prediction {
    pub user: Pubkey,
    pub event: Pubkey,
    pub outcome: Outcome,
    pub amount: u64,
    pub timestamp: i64,
    pub payout: u64,
    pub is_settled: bool,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone, PartialEq, Eq)]
pub enum EventStatus {
    Active,
    Locked,
    Resolved,
    Cancelled,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone, PartialEq, Eq)]
pub enum Outcome {
    Yes,
    No,
}

// Context structures
#[derive(Accounts)]
pub struct InitializeEvent<'info> {
    #[account(
        init,
        payer = authority,
        space = 8 + Event::INIT_SPACE,
        seeds = [b"event", event_id.to_le_bytes().as_ref()],
        bump
    )]
    pub event: Account<'info, Event>,
    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct SubmitPrediction<'info> {
    #[account(
        init,
        payer = user,
        space = 8 + Prediction::INIT_SPACE
    )]
    pub prediction: Account<'info, Prediction>,
    #[account(mut)]
    pub event: Account<'info, Event>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[error_code]
pub enum ErrorCode {
    #[msg("Event is not active")]
    EventNotActive,
    #[msg("Predictions are locked for this event")]
    PredictionLocked,
    #[msg("Unauthorized")]
    Unauthorized,
    #[msg("Event already resolved")]
    AlreadyResolved,
}
```

---

## Security Architecture

### Defense in Depth Layers

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Network Security                                   │
│ - CloudFlare DDoS Protection                                │
│ - WAF Rules                                                 │
│ - Rate Limiting (IP-based)                                  │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│ Layer 2: API Gateway                                        │
│ - SSL/TLS Termination                                       │
│ - Request Validation                                        │
│ - API Rate Limiting                                         │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│ Layer 3: Authentication & Authorization                     │
│ - JWT Validation                                            │
│ - Wallet Signature Verification                             │
│ - Role-Based Access Control                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│ Layer 4: Application Security                               │
│ - Input Validation                                          │
│ - SQL Injection Prevention                                  │
│ - XSS Protection                                            │
│ - CSRF Protection                                           │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│ Layer 5: Business Logic Security                            │
│ - Prediction Time Locks                                     │
│ - Multi-Account Detection                                   │
│ - Wash Trading Detection                                    │
│ - Behavioral Analysis                                       │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│ Layer 6: Data Security                                      │
│ - Encryption at Rest                                        │
│ - Encrypted Connections                                     │
│ - Secrets Management                                        │
│ - Audit Logging                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Scalability Patterns

### Horizontal Scaling Strategy

```
                    ┌──────────────┐
                    │ Load Balancer│
                    └───────┬──────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  API Server 1 │   │  API Server 2 │   │  API Server N │
│  (Stateless)  │   │  (Stateless)  │   │  (Stateless)  │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  PostgreSQL   │   │  Redis        │   │  Kafka        │
│  Primary      │   │  Cluster      │   │  Cluster      │
│      +        │   │  (3 nodes)    │   │  (3 brokers)  │
│  Read Replicas│   │               │   │               │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Caching Strategy

```
Request Flow:

1. Client Request
   ↓
2. Check L1 Cache (In-Memory, 1-5 min TTL)
   ↓ [miss]
3. Check L2 Cache (Redis, 5-60 min TTL)
   ↓ [miss]
4. Query Database
   ↓
5. Populate L2 Cache
   ↓
6. Populate L1 Cache
   ↓
7. Return Response

Cache Keys:
- event:{id}                  # Event details
- events:list:{filters}       # Event lists
- user:{id}:profile          # User profiles
- leaderboard:{category}     # Leaderboards
- predictions:{user_id}      # User predictions
```

---

**Last Updated**: 2025-11-16
**Version**: 1.0
