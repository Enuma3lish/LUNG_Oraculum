.PHONY: help setup run-api run-crawler run-worker test lint build clean docker-build docker-up docker-down migrate-up migrate-down migrate-create anchor-build anchor-test anchor-deploy deps

# Colors for terminal output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

# Variables
APP_NAME=lung-oraculum
VERSION?=0.1.0
BUILD_DIR=./build
GO_FILES=$(shell find . -type f -name '*.go' -not -path "./vendor/*")
GOBASE=$(shell pwd)
GOBIN=$(GOBASE)/bin

help: ## Show this help message
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${WHITE}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

## Setup & Installation

setup: ## Initial project setup
	@echo "Setting up LUNG Oraculum..."
	@cp .env.example .env || true
	@mkdir -p $(BUILD_DIR)
	@go mod download
	@echo "Setup complete! Edit .env file with your configuration."

deps: ## Download Go dependencies
	@echo "Downloading dependencies..."
	@go mod download
	@go mod tidy

install-tools: ## Install development tools
	@echo "Installing development tools..."
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@go install github.com/swaggo/swag/cmd/swag@latest
	@go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

## Development

run-api: ## Run API server
	@echo "Starting API server..."
	@go run cmd/api/main.go

run-crawler: ## Run web crawler service
	@echo "Starting crawler service..."
	@go run cmd/crawler/main.go

run-worker: ## Run background worker
	@echo "Starting background worker..."
	@go run cmd/worker/main.go

dev: ## Run in development mode with hot reload (requires air)
	@if ! command -v air > /dev/null; then \
		echo "Installing air..."; \
		go install github.com/cosmtrek/air@latest; \
	fi
	@air

## Building

build: build-api build-crawler build-worker ## Build all binaries

build-api: ## Build API server binary
	@echo "Building API server..."
	@CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/api cmd/api/main.go

build-crawler: ## Build crawler binary
	@echo "Building crawler service..."
	@CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/crawler cmd/crawler/main.go

build-worker: ## Build worker binary
	@echo "Building background worker..."
	@CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/worker cmd/worker/main.go

build-all-platforms: ## Build for multiple platforms
	@echo "Building for multiple platforms..."
	@GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/api-linux-amd64 cmd/api/main.go
	@GOOS=darwin GOARCH=amd64 go build -o $(BUILD_DIR)/api-darwin-amd64 cmd/api/main.go
	@GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/api-darwin-arm64 cmd/api/main.go
	@GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/api-windows-amd64.exe cmd/api/main.go

## Testing

test: ## Run all tests
	@echo "Running tests..."
	@go test -v -race -coverprofile=coverage.out ./...

test-coverage: test ## Run tests with coverage report
	@go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

test-unit: ## Run unit tests only
	@go test -v -short ./...

test-integration: ## Run integration tests
	@go test -v -run Integration ./...

bench: ## Run benchmarks
	@go test -bench=. -benchmem ./...

## Code Quality

lint: ## Run linter
	@echo "Running linter..."
	@golangci-lint run --timeout=5m

fmt: ## Format code
	@echo "Formatting code..."
	@go fmt ./...
	@gofmt -s -w .

vet: ## Run go vet
	@go vet ./...

## Database

migrate-up: ## Apply all database migrations
	@echo "Applying migrations..."
	@migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/lung_oraculum?sslmode=disable" up

migrate-down: ## Rollback last migration
	@echo "Rolling back migration..."
	@migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/lung_oraculum?sslmode=disable" down 1

migrate-force: ## Force set migration version (use with VERSION=N)
	@migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/lung_oraculum?sslmode=disable" force $(VERSION)

migrate-create: ## Create new migration file (use with NAME=migration_name)
	@echo "Creating migration: $(NAME)"
	@migrate create -ext sql -dir migrations -seq $(NAME)

migrate-reset: ## Reset database (drop and recreate)
	@echo "Resetting database..."
	@migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/lung_oraculum?sslmode=disable" drop -f
	@migrate -path migrations -database "postgresql://postgres:postgres@localhost:5432/lung_oraculum?sslmode=disable" up

db-seed: ## Seed database with test data
	@echo "Seeding database..."
	@go run scripts/seed.go

## Docker

docker-build: ## Build Docker images
	@echo "Building Docker images..."
	@docker-compose build

docker-up: ## Start all services with Docker Compose
	@echo "Starting services..."
	@docker-compose up -d

docker-up-full: ## Start all services including optional ones
	@echo "Starting all services..."
	@docker-compose --profile full --profile monitoring up -d

docker-down: ## Stop all Docker services
	@echo "Stopping services..."
	@docker-compose down

docker-logs: ## View Docker logs
	@docker-compose logs -f

docker-clean: ## Remove all containers, volumes, and images
	@echo "Cleaning up Docker resources..."
	@docker-compose down -v --rmi all

## Solana/Anchor

anchor-build: ## Build Solana program
	@echo "Building Solana program..."
	@cd solana-program && anchor build

anchor-test: ## Test Solana program
	@echo "Testing Solana program..."
	@cd solana-program && anchor test

anchor-deploy: ## Deploy Solana program (check Anchor.toml for network)
	@echo "Deploying Solana program..."
	@cd solana-program && anchor deploy

anchor-deploy-devnet: ## Deploy to Solana Devnet
	@echo "Deploying to Devnet..."
	@cd solana-program && anchor deploy --provider.cluster devnet

anchor-localnet: ## Start local Solana validator
	@echo "Starting local Solana validator..."
	@solana-test-validator

## Frontend

frontend-install: ## Install frontend dependencies
	@echo "Installing frontend dependencies..."
	@cd frontend && npm install

frontend-dev: ## Run frontend in development mode
	@echo "Starting frontend dev server..."
	@cd frontend && npm run dev

frontend-build: ## Build frontend for production
	@echo "Building frontend..."
	@cd frontend && npm run build

frontend-test: ## Run frontend tests
	@echo "Running frontend tests..."
	@cd frontend && npm test

## Production

prod-build: ## Build production-ready binaries
	@echo "Building for production..."
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
		-ldflags="-w -s -X main.Version=$(VERSION) -X main.BuildTime=$(shell date -u +%Y%m%d.%H%M%S)" \
		-o $(BUILD_DIR)/api-prod cmd/api/main.go

k8s-deploy: ## Deploy to Kubernetes
	@echo "Deploying to Kubernetes..."
	@kubectl apply -f k8s/

k8s-delete: ## Delete Kubernetes resources
	@kubectl delete -f k8s/

## Utilities

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@rm -f coverage.out coverage.html
	@go clean

gen-swagger: ## Generate Swagger documentation
	@echo "Generating Swagger docs..."
	@swag init -g cmd/api/main.go -o docs/swagger

gen-mocks: ## Generate mocks for testing
	@echo "Generating mocks..."
	@go generate ./...

logs-api: ## View API logs
	@docker-compose logs -f api

logs-db: ## View database logs
	@docker-compose logs -f postgres

logs-redis: ## View Redis logs
	@docker-compose logs -f redis

logs-kafka: ## View Kafka logs
	@docker-compose logs -f kafka

health-check: ## Check health of all services
	@echo "Checking service health..."
	@curl -f http://localhost:8080/health || echo "API: DOWN"
	@docker-compose ps

## Git

git-hooks: ## Install git hooks
	@echo "Installing git hooks..."
	@cp -f scripts/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git hooks installed!"

## Monitoring

metrics: ## Open Prometheus metrics
	@open http://localhost:9090

grafana: ## Open Grafana dashboard
	@open http://localhost:3001

kafka-ui: ## Open Kafka UI
	@open http://localhost:8090

all: clean deps build test ## Clean, build, and test everything

.DEFAULT_GOAL := help
