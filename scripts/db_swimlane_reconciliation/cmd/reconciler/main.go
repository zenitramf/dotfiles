package main

import (
	"context"
	"log"
	"os"

	"db_swimlane_reconciliation/internal/api"

	"github.com/jackc/pgx/v5"
)

func main() {
	ctx := context.Background()

	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		log.Fatal("DATABASE_URL environment variable is required")
	}

	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer conn.Close(ctx)

	// TODO: import db_swimlane_reconciliation/internal/db after running `sqlc generate`
	// queries := db.New(conn)
	_ = conn

	baseURL := os.Getenv("SWIMLANE_API_URL")
	if baseURL == "" {
		log.Fatal("SWIMLANE_API_URL environment variable is required")
	}

	tenant := os.Getenv("SWIMLANE_CIM_TENANT")
	token := os.Getenv("SWIMLANE_API_KEY")

	client := api.NewClient(baseURL)
	_ = client

	log.Println("reconciler started")
}
