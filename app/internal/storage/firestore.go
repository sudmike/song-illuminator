package storage

import (
	"context"

	"cloud.google.com/go/firestore"
)

type Firestore struct {
	client *firestore.Client
}

func NewFirestore(ctx context.Context, projectID string) (*Firestore, error) {
	if projectID == "" {
		return &Firestore{}, nil
	}
	client, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		return nil, err
	}
	return &Firestore{client: client}, nil
}

func (f *Firestore) Enabled() bool { return f.client != nil }

func (f *Firestore) Close() error {
	if f.client == nil {
		return nil
	}
	return f.client.Close()
}
