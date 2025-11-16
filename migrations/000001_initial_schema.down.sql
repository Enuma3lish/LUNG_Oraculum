-- Rollback initial schema

-- Drop triggers
DROP TRIGGER IF EXISTS update_leaderboard_on_prediction ON predictions;
DROP TRIGGER IF EXISTS update_user_stats_on_prediction ON predictions;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_events_updated_at ON events;
DROP TRIGGER IF EXISTS update_event_sources_updated_at ON event_sources;

-- Drop functions
DROP FUNCTION IF EXISTS update_leaderboard_stats();
DROP FUNCTION IF EXISTS update_user_stats();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop indexes
DROP INDEX IF EXISTS idx_users_wallet;
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_events_status;
DROP INDEX IF EXISTS idx_events_category;
DROP INDEX IF EXISTS idx_events_start_time;
DROP INDEX IF EXISTS idx_events_created_by;
DROP INDEX IF EXISTS idx_predictions_user;
DROP INDEX IF EXISTS idx_predictions_event;
DROP INDEX IF EXISTS idx_predictions_status;
DROP INDEX IF EXISTS idx_predictions_tx;
DROP INDEX IF EXISTS idx_predictions_created_at;
DROP INDEX IF EXISTS idx_audit_logs_user;
DROP INDEX IF EXISTS idx_audit_logs_action;
DROP INDEX IF EXISTS idx_audit_logs_created;
DROP INDEX IF EXISTS idx_user_sessions_user;
DROP INDEX IF EXISTS idx_user_sessions_token;
DROP INDEX IF EXISTS idx_user_sessions_expires;
DROP INDEX IF EXISTS idx_flagged_activities_user;
DROP INDEX IF EXISTS idx_flagged_activities_status;

-- Drop tables (in reverse order of dependencies)
DROP TABLE IF EXISTS flagged_activities;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS event_sources;
DROP TABLE IF EXISTS user_interests;
DROP TABLE IF EXISTS leaderboard;
DROP TABLE IF EXISTS predictions;
DROP TABLE IF EXISTS event_outcomes;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

-- Drop extensions
DROP EXTENSION IF EXISTS "uuid-ossp";
