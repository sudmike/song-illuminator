package main

import (
	"context"
	"log"
	"os/signal"
	"syscall"

	"github.com/sudmike/song-illuminator/app/internal/app"
	"github.com/sudmike/song-illuminator/app/internal/config"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("load configuration: %v", err)
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	application, err := app.New(ctx, cfg)
	if err != nil {
		log.Fatalf("initialize application: %v", err)
	}
	defer application.Close()

	if err := application.Run(ctx); err != nil {
		log.Fatalf("run application: %v", err)
	}
}
