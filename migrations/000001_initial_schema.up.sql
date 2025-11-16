-- Initial database schema for LUNG Oraculum prediction platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    wallet_address VARCHAR(44) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(255) UNIQUE,
    tier INTEGER DEFAULT 0, -- 0: Basic, 1: Verified, 2: Premium
    is_active BOOLEAN DEFAULT true,
    is_admin BOOLEAN DEFAULT false,
    total_predictions INTEGER DEFAULT 0,
    correct_predictions INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Events table
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- sports, politics, crypto, weather, economics, entertainment
    event_type VARCHAR(50) NOT NULL, -- binary, multiple_choice, scalar
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    resolution_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, locked, resolved, cancelled
    resolution_source TEXT,
    winning_outcome VARCHAR(50),
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CHECK (end_time > start_time),
    CHECK (resolution_time >= end_time)
);

-- Event outcomes (for multiple choice events)
CREATE TABLE IF NOT EXISTS event_outcomes (
    id SERIAL PRIMARY KEY,
    event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
    label VARCHAR(100) NOT NULL,
    total_amount DECIMAL(20, 9) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(event_id, label)
);

-- Predictions table
CREATE TABLE IF NOT EXISTS predictions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
    outcome VARCHAR(50) NOT NULL,
    amount DECIMAL(20, 9) NOT NULL CHECK (amount > 0),
    shares DECIMAL(20, 9),
    solana_tx_signature VARCHAR(88) UNIQUE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, settled, failed
    payout DECIMAL(20, 9),
    profit_loss DECIMAL(20, 9),
    created_at TIMESTAMP DEFAULT NOW(),
    settled_at TIMESTAMP,
    CHECK (amount > 0)
);

-- Leaderboard table
CREATE TABLE IF NOT EXISTS leaderboard (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) UNIQUE,
    total_predictions INTEGER DEFAULT 0,
    correct_predictions INTEGER DEFAULT 0,
    accuracy_rate DECIMAL(5, 2) DEFAULT 0,
    total_profit DECIMAL(20, 9) DEFAULT 0,
    total_volume DECIMAL(20, 9) DEFAULT 0,
    rank INTEGER,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User interests (for personalization)
CREATE TABLE IF NOT EXISTS user_interests (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    interest_score INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    prediction_count INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, category)
);

-- Event sources (for crawler)
CREATE TABLE IF NOT EXISTS event_sources (
    id SERIAL PRIMARY KEY,
    source_name VARCHAR(100) NOT NULL,
    source_url TEXT,
    source_type VARCHAR(50) NOT NULL, -- api, rss, scraper
    category VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    last_crawled TIMESTAMP,
    error_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Audit logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id INTEGER,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- User sessions (for tracking active sessions)
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    device_id VARCHAR(100),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_activity TIMESTAMP DEFAULT NOW()
);

-- Flagged activities (security)
CREATE TABLE IF NOT EXISTS flagged_activities (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    flag_type VARCHAR(50) NOT NULL, -- multi_account, wash_trading, suspicious_pattern
    severity VARCHAR(20) DEFAULT 'medium', -- low, medium, high
    description TEXT,
    metadata JSONB,
    status VARCHAR(20) DEFAULT 'pending', -- pending, reviewed, resolved, false_positive
    reviewed_by INTEGER REFERENCES users(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX idx_users_wallet ON users(wallet_address);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_start_time ON events(start_time);
CREATE INDEX idx_events_created_by ON events(created_by);
CREATE INDEX idx_predictions_user ON predictions(user_id);
CREATE INDEX idx_predictions_event ON predictions(event_id);
CREATE INDEX idx_predictions_status ON predictions(status);
CREATE INDEX idx_predictions_tx ON predictions(solana_tx_signature);
CREATE INDEX idx_predictions_created_at ON predictions(created_at);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(token_hash);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);
CREATE INDEX idx_flagged_activities_user ON flagged_activities(user_id);
CREATE INDEX idx_flagged_activities_status ON flagged_activities(status);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for automatic updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_sources_updated_at BEFORE UPDATE ON event_sources
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update leaderboard stats
CREATE OR REPLACE FUNCTION update_leaderboard_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO leaderboard (user_id, total_predictions, correct_predictions, total_volume)
    VALUES (NEW.user_id, 1,
            CASE WHEN NEW.status = 'settled' AND NEW.profit_loss > 0 THEN 1 ELSE 0 END,
            NEW.amount)
    ON CONFLICT (user_id) DO UPDATE SET
        total_predictions = leaderboard.total_predictions + 1,
        correct_predictions = leaderboard.correct_predictions +
            CASE WHEN NEW.status = 'settled' AND NEW.profit_loss > 0 THEN 1 ELSE 0 END,
        total_volume = leaderboard.total_volume + NEW.amount,
        total_profit = leaderboard.total_profit + COALESCE(NEW.profit_loss, 0),
        accuracy_rate = CASE
            WHEN (leaderboard.total_predictions + 1) > 0
            THEN ROUND((leaderboard.correct_predictions +
                CASE WHEN NEW.status = 'settled' AND NEW.profit_loss > 0 THEN 1 ELSE 0 END)::NUMERIC
                / (leaderboard.total_predictions + 1)::NUMERIC * 100, 2)
            ELSE 0
        END,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update leaderboard when prediction is created/updated
CREATE TRIGGER update_leaderboard_on_prediction
    AFTER INSERT OR UPDATE ON predictions
    FOR EACH ROW
    EXECUTE FUNCTION update_leaderboard_stats();

-- Function to update user stats
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users SET
        total_predictions = total_predictions + 1,
        correct_predictions = correct_predictions +
            CASE WHEN NEW.status = 'settled' AND NEW.profit_loss > 0 THEN 1 ELSE 0 END,
        updated_at = NOW()
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update user stats
CREATE TRIGGER update_user_stats_on_prediction
    AFTER INSERT OR UPDATE ON predictions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_stats();

-- Insert default event sources
INSERT INTO event_sources (source_name, source_url, source_type, category, is_active) VALUES
    ('NewsAPI', 'https://newsapi.org/v2', 'api', 'politics', true),
    ('The Odds API', 'https://api.the-odds-api.com/v4', 'api', 'sports', true),
    ('CoinGecko', 'https://api.coingecko.com/api/v3', 'api', 'crypto', true),
    ('OpenWeatherMap', 'https://api.openweathermap.org/data/2.5', 'api', 'weather', true)
ON CONFLICT DO NOTHING;

-- Create a default admin user (wallet address should be updated)
INSERT INTO users (wallet_address, username, email, tier, is_admin) VALUES
    ('ADMIN_WALLET_ADDRESS_HERE', 'admin', 'admin@lungoraculum.com', 2, true)
ON CONFLICT DO NOTHING;
