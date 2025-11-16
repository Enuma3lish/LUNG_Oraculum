# Quick Start Guide - LUNG Oraculum

Get up and running with LUNG Oraculum in under 15 minutes!

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Go 1.21+**: [Download](https://golang.org/dl/)
- **Node.js 18+**: [Download](https://nodejs.org/)
- **Docker & Docker Compose**: [Download](https://www.docker.com/products/docker-desktop/)
- **Solana CLI**: [Install Guide](https://docs.solana.com/cli/install-solana-cli-tools)
- **Anchor**: [Install Guide](https://www.anchor-lang.com/docs/installation)
- **PostgreSQL Client** (optional, for manual DB access)

### Verify Installation

```bash
go version        # Should show 1.21 or higher
node --version    # Should show v18 or higher
docker --version  # Should show Docker version
solana --version  # Should show Solana CLI version
anchor --version  # Should show Anchor version
```

---

## 🚀 Method 1: Docker Quick Start (Recommended for Testing)

The fastest way to get everything running.

### Step 1: Clone and Configure

```bash
# Clone the repository
git clone <your-repo-url>
cd LUNG_Oraculum

# Copy environment template
cp .env.example .env

# Edit .env if needed (defaults work for local development)
nano .env  # or use your favorite editor
```

### Step 2: Start Infrastructure

```bash
# Start PostgreSQL, Redis, and Kafka
docker-compose up -d postgres redis kafka zookeeper

# Wait for services to be healthy (about 30 seconds)
docker-compose ps

# Apply database migrations
make migrate-up
```

### Step 3: Configure Solana (Devnet)

```bash
# Set to Devnet
solana config set --url devnet

# Create a new wallet (or use existing)
solana-keygen new --outfile ~/.config/solana/id.json

# Get some test SOL from faucet
solana airdrop 2

# Verify balance
solana balance
```

### Step 4: Deploy Solana Program

```bash
# Build the program
cd solana-program
anchor build

# Get the program ID
solana address -k target/deploy/prediction-keypair.json

# Update Anchor.toml and lib.rs with the program ID
# Edit: solana-program/Anchor.toml - update [programs.devnet]
# Edit: solana-program/programs/prediction/src/lib.rs - update declare_id!()

# Rebuild and deploy
anchor build
anchor deploy

# Copy the program ID to .env
# SOLANA_PROGRAM_ID=<your-program-id>
cd ..
```

### Step 5: Start Backend Services

```bash
# Install Go dependencies
make deps

# Run the API server
make run-api
```

The API should now be running at `http://localhost:8080`

### Step 6: Start Frontend

```bash
# Open a new terminal
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The frontend should open at `http://localhost:3000` or `http://localhost:5173`

### Step 7: Test the Application

Open your browser:
1. Navigate to `http://localhost:3000`
2. Connect your Phantom wallet (set to Devnet)
3. Browse available events
4. Make a test prediction

---

## 🛠️ Method 2: Manual Setup (For Development)

For developers who want more control.

### Step 1: Database Setup

```bash
# Start PostgreSQL (if not using Docker)
# macOS
brew services start postgresql@15

# Ubuntu/Debian
sudo systemctl start postgresql

# Create database
createdb lung_oraculum

# Or via psql
psql -U postgres
CREATE DATABASE lung_oraculum;
\q

# Apply migrations
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=lung_oraculum
export DB_USER=postgres
export DB_PASSWORD=your_password

make migrate-up
```

### Step 2: Redis Setup

```bash
# Start Redis (if not using Docker)
# macOS
brew services start redis

# Ubuntu/Debian
sudo systemctl start redis

# Verify
redis-cli ping  # Should return PONG
```

### Step 3: Kafka Setup

```bash
# Using Docker (recommended)
docker-compose up -d kafka zookeeper

# Or install locally (more complex)
# See: https://kafka.apache.org/quickstart
```

### Step 4: Configure Environment

```bash
# Copy and edit .env
cp .env.example .env

# Update with your local configuration
# DB_HOST=localhost
# DB_PORT=5432
# REDIS_HOST=localhost
# REDIS_PORT=6379
# KAFKA_BROKERS=localhost:9092
```

### Step 5: Build and Run

```bash
# Install Go dependencies
go mod download

# Run API server
make run-api

# In another terminal, run worker
make run-worker

# In another terminal, run crawler (optional)
make run-crawler
```

### Step 6: Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Create .env for frontend
cat > .env << EOF
VITE_API_URL=http://localhost:8080/api/v1
VITE_WS_URL=ws://localhost:8080/ws
VITE_SOLANA_NETWORK=devnet
EOF

# Start development server
npm run dev
```

---

## 🧪 Verify Installation

### 1. Check API Health

```bash
curl http://localhost:8080/health
# Expected: {"status":"ok"}
```

### 2. Check Database Connection

```bash
curl http://localhost:8080/api/v1/events
# Should return empty array or sample events
```

### 3. Test WebSocket

```javascript
// In browser console
const ws = new WebSocket('ws://localhost:8080/ws')
ws.onopen = () => console.log('Connected!')
ws.onmessage = (msg) => console.log('Message:', msg.data)
```

### 4. Check Solana Connection

```bash
# Get program info
solana program show <YOUR_PROGRAM_ID>
```

---

## 📊 Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | - |
| API | http://localhost:8080 | - |
| API Docs | http://localhost:8080/docs | - |
| Kafka UI | http://localhost:8090 | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin/admin |
| PostgreSQL | localhost:5432 | postgres/postgres |
| Redis | localhost:6379 | - |

---

## 🎯 Next Steps

### 1. Create a Test Event

Using the API:

```bash
# First, get an auth token (requires wallet signature)
# For now, create event directly in DB for testing

psql -U postgres -d lung_oraculum
INSERT INTO events (title, description, category, event_type, start_time, end_time, resolution_time, created_by)
VALUES (
  'Will Bitcoin reach $100k in 2024?',
  'Bitcoin price prediction for 2024',
  'crypto',
  'binary',
  NOW() + INTERVAL '1 day',
  NOW() + INTERVAL '365 days',
  NOW() + INTERVAL '366 days',
  1
);

# Verify
SELECT * FROM events;
\q
```

### 2. Make a Test Prediction

1. Open frontend at http://localhost:3000
2. Connect Phantom wallet (Devnet)
3. View the test event
4. Submit a prediction (requires test SOL)

### 3. Monitor Activity

```bash
# Watch API logs
make logs-api

# Watch Kafka messages
# Open http://localhost:8090

# Watch database
watch -n 2 'psql -U postgres -d lung_oraculum -c "SELECT COUNT(*) FROM predictions"'
```

---

## 🐛 Troubleshooting

### Database Connection Failed

```bash
# Check if PostgreSQL is running
docker-compose ps postgres
# or
pg_isready

# Check logs
docker-compose logs postgres

# Try connecting manually
psql -h localhost -U postgres -d lung_oraculum
```

### Redis Connection Failed

```bash
# Check if Redis is running
docker-compose ps redis

# Test connection
redis-cli ping

# Check logs
docker-compose logs redis
```

### Kafka Not Starting

```bash
# Kafka requires more memory
# Edit docker-compose.yml and increase memory limit

# Check Zookeeper first
docker-compose logs zookeeper

# Then check Kafka
docker-compose logs kafka

# Restart
docker-compose restart kafka
```

### Solana Program Deploy Failed

```bash
# Check you have enough SOL
solana balance

# Airdrop more test SOL
solana airdrop 2

# Check you're on Devnet
solana config get
# Should show: RPC URL: https://api.devnet.solana.com

# Clear and rebuild
cd solana-program
anchor clean
anchor build
anchor deploy
```

### Frontend Not Loading

```bash
# Check Node version
node --version  # Should be 18+

# Clear cache and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install

# Check .env exists
cat .env

# Start with verbose output
npm run dev -- --host
```

### API Server Won't Start

```bash
# Check port 8080 is not in use
lsof -i :8080

# Kill any process using the port
kill -9 <PID>

# Check environment variables
source .env
env | grep DB_

# Try with verbose logging
LOG_LEVEL=debug make run-api
```

---

## 🔍 Common Issues

### "Migration failed"
- Ensure database exists: `createdb lung_oraculum`
- Check database credentials in `.env`
- Drop and recreate: `make migrate-reset`

### "Kafka connection timeout"
- Kafka takes 30-60 seconds to start
- Wait and retry
- Check logs: `docker-compose logs kafka`

### "Wallet not detected"
- Install Phantom wallet extension
- Set Phantom to Devnet network
- Refresh browser

### "Transaction failed"
- Check you have SOL balance: `solana balance`
- Airdrop more: `solana airdrop 2`
- Check network: `solana config get`

---

## 📚 Learn More

- **Architecture**: See [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Roadmap**: See [ROADMAP.md](./ROADMAP.md)
- **API Docs**: Coming soon
- **Contributing**: Coming soon

---

## 🆘 Getting Help

1. **Check Documentation**: Review README.md and ARCHITECTURE.md
2. **Search Issues**: Check existing GitHub issues
3. **Ask Community**: Join our Discord (coming soon)
4. **Report Bug**: Create a GitHub issue with:
   - Steps to reproduce
   - Expected vs actual behavior
   - System info (OS, versions)
   - Logs

---

## 🎉 Success!

If you've made it this far, you should have:
- ✅ PostgreSQL, Redis, and Kafka running
- ✅ Database schema migrated
- ✅ Solana program deployed to Devnet
- ✅ API server running
- ✅ Frontend accessible
- ✅ Able to make test predictions

**Happy predicting!** 🔮

---

## 📝 Development Workflow

```bash
# Morning routine
docker-compose up -d        # Start infrastructure
make run-api &              # Start API
cd frontend && npm run dev  # Start frontend

# Make changes...

# Run tests
make test                   # Backend tests
cd frontend && npm test     # Frontend tests

# Before commit
make lint                   # Check code quality
make test                   # Run tests
git add .
git commit -m "Your message"

# End of day
docker-compose down         # Stop all services
```

---

**Last Updated**: 2025-11-16
