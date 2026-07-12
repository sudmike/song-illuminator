package app

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestHealthEndpoint(t *testing.T) {
	dir := t.TempDir()
	res := httptest.NewRecorder()
	newRouter(dir, http.NotFoundHandler()).ServeHTTP(res, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if res.Code != http.StatusOK || res.Body.String() != `{"status":"ok"}` {
		t.Fatalf("status=%d body=%q", res.Code, res.Body.String())
	}
}

func TestSPAHandlerServesIndexForClientRoute(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "index.html"), []byte("app shell"), 0o600); err != nil {
		t.Fatal(err)
	}
	res := httptest.NewRecorder()
	spaHandler(dir).ServeHTTP(res, httptest.NewRequest(http.MethodGet, "/settings", nil))
	if res.Code != http.StatusOK || res.Body.String() != "app shell" {
		t.Fatalf("status=%d body=%q", res.Code, res.Body.String())
	}
}
