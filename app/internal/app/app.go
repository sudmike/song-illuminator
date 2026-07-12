package app

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/sudmike/song-illuminator/app/internal/api"
	"github.com/sudmike/song-illuminator/app/internal/config"
	"github.com/sudmike/song-illuminator/app/internal/storage"
)

type App struct {
	server    *http.Server
	firestore *storage.Firestore
}

func New(ctx context.Context, cfg config.Config) (*App, error) {
	store, err := storage.NewFirestore(ctx, cfg.FirestoreProjectID)
	if err != nil {
		return nil, fmt.Errorf("initialize Firestore: %w", err)
	}
	graphqlHandler, err := api.NewGraphQL(cfg.Environment, store.Enabled())
	if err != nil {
		_ = store.Close()
		return nil, fmt.Errorf("initialize GraphQL: %w", err)
	}

	mux := newRouter(cfg.StaticDir, graphqlHandler)

	return &App{server: &http.Server{
		Addr: ":" + cfg.Port, Handler: mux,
		ReadHeaderTimeout: 5 * time.Second, IdleTimeout: 60 * time.Second,
	}, firestore: store}, nil
}

func newRouter(staticDir string, graphqlHandler http.Handler) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	mux.Handle("/graphql", graphqlHandler)
	mux.Handle("/", spaHandler(staticDir))
	return mux
}

func (a *App) Run(ctx context.Context) error {
	errCh := make(chan error, 1)
	go func() {
		log.Printf("Song Illuminator listening on %s", a.server.Addr)
		errCh <- a.server.ListenAndServe()
	}()
	select {
	case err := <-errCh:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return err
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		return a.server.Shutdown(shutdownCtx)
	}
}

func (a *App) Close() error { return a.firestore.Close() }
