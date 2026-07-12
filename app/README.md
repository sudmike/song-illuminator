# Song Illuminator application

This directory contains the product application: a Go HTTP service and a React frontend. The production container builds the frontend and serves its assets from the Go service.

## Local development

1. Run `go run ./cmd/server` from this directory.
2. Run `npm run dev` from `frontend` for the Vite development server.

The backend listens on port 8080 by default. Vite proxies `/graphql` and `/healthz` to it.

Configuration:

- `APP_ENV`: runtime environment (`development` by default).
- `PORT`: HTTP port (`8080` by default).
- `FIRESTORE_PROJECT_ID`: Google Cloud project containing Firestore; required in production.
- `STATIC_DIR`: compiled React asset directory (`frontend/dist` by default).

Application Default Credentials are used when Firestore is configured.

## Checks

Run `go test ./...` in this directory and `npm test`, `npm run lint`, and `npm run build` in `frontend`.
