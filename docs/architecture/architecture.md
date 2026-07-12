# Architecture

This document describes the intended v1 architecture for Song Illuminator. It is a decision guide for implementation, not a complete package layout, GraphQL schema, or infrastructure specification.

## V1 Shape

Song Illuminator should start as a single deployable web application service.

The service should include:

- A Go backend.
- A React frontend.
- A GraphQL API over plain HTTP.
- Static frontend assets built from React and served by the Go backend from the same container.
- Provider integrations for the first real music and smart light providers.
- An in-process scheduler for beta sync sessions.

Application code should live under `app` so the product app is separate from existing runner infrastructure.

## API Direction

The frontend should communicate with the backend through GraphQL over plain HTTP.

GraphQL queries should serve dashboard-style reads:

- Current user/session state.
- Connected provider state.
- Available lights.
- Selected lights.
- Sync settings.
- Current sync status.
- Current song and attributed color.

GraphQL mutations should handle command-like actions:

- Begin provider connection.
- Disconnect provider.
- Select or deselect lights.
- Update settings.
- Start sync.
- Stop sync.

The React app should poll GraphQL for running sync status in v1. Subscriptions, server-sent events, and WebSockets are not v1 requirements.

## Persistence And Secrets

V1 should use Firestore for persistence because cost is important and the data model can start naturally as documents.

The initial document model should cover:

- Users anchored to a music provider identity.
- Provider connections.
- Selected individual lights.
- Sync settings.
- Sync sessions.
- Current or latest sync status.

Provider tokens should be encrypted at rest. OAuth client secrets and token encryption keys should live in Secret Manager.

Detailed Firestore collection names, document shapes, indexes, and encryption implementation should be specified later.

## Provider Direction

The first implementation should build toward real providers from the start. Spotify is the expected first music provider and Philips Hue is the expected first smart light provider.

The architecture should not rely on fake providers or local auth bypasses as the main implementation path. Test doubles may still be used in automated tests, but the product architecture should assume actual provider OAuth and provider APIs.

Provider-specific API details should stay behind music provider and smart light provider adapter boundaries.

## Sync Runtime

V1 sync should run through an in-process scheduler inside the single Go service.

The beta deployment should assume:

- One running app instance.
- Bounded sync sessions.
- User-visible sync status and errors.
- Firestore-backed sync session records for observability and future recovery.
- Beta reliability, not hard guaranteed background execution.

If the service restarts, an active sync session may be interrupted until durable recovery is designed. This is acceptable for the beta, but it must be revisited before broader launch.

## Deployment Direction

V1 should use deployment option 3: start with a single Cloud Run service and explicitly plan for a future worker split if the sync workload outgrows the simple shape.

The recommended v1 deployment is:

- One Cloud Run service for the Go backend, React assets, GraphQL API, and in-process scheduler.
- `min_instance_count = 1` while beta sync is expected to keep running.
- `max_instance_count = 1` to avoid multiple in-process schedulers competing during v1.
- CPU allocated while the instance is alive, not only while requests are being handled.
- Firestore for low-cost persistence.
- Secret Manager for OAuth secrets and encryption keys.

This keeps v1 low-ops and cost-conscious while supporting the hour-long sync experience well enough for beta use.

The existing runner-related infrastructure in this repository should not determine the product app deployment. It can be useful as repo context, but the application architecture should be evaluated on the product's own runtime needs.

## Deployment Tradeoffs

Cloud Run is the preferred v1 starting point because it is managed, container-based, and easy to pair with Firestore and Secret Manager.

The main tradeoff is background execution. An in-process scheduler inside Cloud Run is simple, but it depends on keeping an instance alive. Restarts, deployments, or platform lifecycle events may interrupt active sync until session recovery exists.

A small always-on VM would make the in-process scheduler easier to reason about, but it would add more operational responsibility: OS updates, process supervision, deployment mechanics, firewall configuration, and monitoring.

A separate worker from the start would give cleaner runtime boundaries, but it would add infrastructure and coordination complexity before the beta proves that the core experience is worth hardening.

## Future Worker Split

If sync reliability, scale, or operational clarity becomes more important, split the runtime into:

- A web/API service for React assets, GraphQL, OAuth callbacks, user settings, and sync commands.
- A dedicated worker runtime for sync execution.
- Firestore session records or leases to coordinate active sync work.

Possible future worker runtimes include:

- Cloud Run worker pool.
- Cloud Tasks or Pub/Sub coordinated workers.
- A small VM worker.
- Another dedicated background runtime if later constraints justify it.

The future split should preserve the same product model: one active music provider per sync session, selected individual lights as v1 targets, provider adapters behind application boundaries, and GraphQL as the frontend API.

