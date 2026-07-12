package storage

import (
	"context"
	"testing"
)

func TestFirestoreCanBeDisabledForLocalDevelopment(t *testing.T) {
	store, err := NewFirestore(context.Background(), "")
	if err != nil {
		t.Fatalf("create disabled Firestore: %v", err)
	}
	if store.Enabled() {
		t.Fatal("expected Firestore to be disabled")
	}
	if err := store.Close(); err != nil {
		t.Fatalf("close disabled Firestore: %v", err)
	}
}
