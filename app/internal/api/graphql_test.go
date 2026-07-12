package api

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestGraphQLServiceInfo(t *testing.T) {
	handler, err := NewGraphQL("test", false)
	if err != nil {
		t.Fatalf("create handler: %v", err)
	}
	req := httptest.NewRequest(http.MethodPost, "/graphql", strings.NewReader(`{"query":"{ serviceInfo { name environment firestoreEnabled } }"}`))
	res := httptest.NewRecorder()
	handler.ServeHTTP(res, req)
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	if !strings.Contains(res.Body.String(), `"environment":"test"`) {
		t.Fatalf("unexpected response: %s", res.Body.String())
	}
}
