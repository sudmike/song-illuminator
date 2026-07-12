# Implementation Roadmap

This document turns the current Song Illuminator planning docs into a practical path toward the first coded version. It is meant to answer where implementation starts and how the first real beta should grow, without becoming a complete API, database, OAuth, or UI specification.

## Implementation Direction

Song Illuminator should begin as a single app under `app` with:

- A Go backend.
- A React frontend.
- Code-first GraphQL over plain HTTP.
- Firestore persistence from the start.
- A Docker-ready and Cloud Run-ready service shape from the first milestone.
- Real provider integrations as the product path, starting with Spotify and Philips Hue.

The first frontend can be plain and functional. It should make the app usable and understandable, but it does not need a design-heavy experience before the provider and sync foundations are proven.

## Milestone 1: App Scaffold

The first coding milestone should create the application foundation only.

It should include:

- Go service structure.
- React frontend structure.
- A code-first GraphQL endpoint.
- A health endpoint.
- Basic configuration loading.
- Firestore client wiring.
- Static asset serving plan for the React build.
- Dockerfile and Cloud Run-ready runtime assumptions.
- Boundary tests for core startup, configuration, GraphQL routing, and storage wiring where practical.

This milestone should prove that the app can run locally, expose the intended backend surfaces, serve or prepare to serve the frontend, and be packaged in the same general shape that Cloud Run will use later.

It should not include provider OAuth, playback polling, light discovery, or sync execution yet.

## Milestone 2: Music Provider Login

The next milestone should make Spotify the first concrete music provider and account anchor.

It should cover:

- Beginning a Spotify OAuth login.
- Handling the OAuth callback.
- Establishing the application session.
- Creating or loading the user account anchored to the Spotify identity.
- Storing encrypted provider tokens in Firestore.
- Refreshing tokens when needed.
- Exposing a basic viewer or current-user GraphQL read.

The implementation should still use music provider language in product and application concepts so later providers can fit behind the same model.

## Milestone 3: Music Playback Read Path

After login works, the app should read current playback from the active music provider.

It should expose enough data for the running sync view:

- Current song.
- Artist.
- Album name.
- Album art.
- Playback status.
- Provider availability or needs-attention status.

This milestone should focus on reliable reads and clear status before changing any lights.

## Milestone 4: Smart Light Provider Connection

The fourth milestone should introduce Philips Hue as the first concrete smart light provider.

It should cover:

- Beginning Hue cloud OAuth.
- Handling the OAuth callback.
- Storing encrypted provider tokens.
- Listing available individual lights.
- Selecting and deselecting individual lights for sync.
- Showing smart light provider connection state through GraphQL.

V1 should select individual lights only. Rooms, zones, groups, and provider-specific scenes remain future features.

## Milestone 5: Color And Manual Light Update

Before background sync, the app should prove the color and light-control path manually.

It should cover:

- Extracting one room-friendly color from the current album art.
- Showing the attributed color in the UI.
- Applying that color to selected lights through the smart light provider adapter.
- Applying fallback behavior by dimming the previous color to half of the current sync brightness when a new usable color cannot be produced.

The v1 color mode should optimize for looking good in the room rather than exact album-cover accuracy.

## Milestone 6: Sync Sessions

The final v1 milestone should connect the pieces into server-side sync sessions.

It should cover:

- Start sync and stop sync GraphQL mutations.
- An in-process scheduler inside the single Go service.
- Firestore-backed sync session records for observability and future recovery.
- A default sync duration of about one hour.
- A maximum sync duration of about four hours.
- Light updates on song changes, not continuous animation within a song.
- Graceful idle when playback is paused, private, unavailable, or otherwise not actionable.
- Needs-attention status for repeated provider failures, repeated light update failures, or authorization problems.
- Stop behavior that leaves the last attributed color active at half of the active sync brightness.

V1 sync should be beta reliable, not hard guaranteed. Service restarts may interrupt active sync until durable recovery or a future worker split is designed.

## Deployment Path

Deployment work should begin in milestone one through the app shape, Dockerfile, configuration strategy, and Cloud Run-ready assumptions.

Actual production deployment can wait until the app has useful provider behavior, but implementation should avoid local-only shortcuts that would need to be unwound later.

The v1 deployment target remains:

- One Cloud Run service.
- `min_instance_count = 1` during beta sync usage.
- `max_instance_count = 1` for the in-process scheduler.
- Always-allocated CPU while beta sync is expected to run.
- Firestore for persistence.
- Secret Manager for OAuth secrets and encryption keys.

## Testing Direction

Testing should begin with focused boundary coverage rather than broad end-to-end coverage.

Early tests should cover:

- Service startup and health behavior.
- Configuration loading and validation.
- GraphQL request handling.
- Session and auth boundaries once login exists.
- Provider adapter boundaries using test doubles.
- Storage behavior around user, connection, light selection, and sync session records.

Smoke checks should confirm the backend and frontend can build and run together as the milestones mature.

## Non-Goals For The First Coding Pass

The first implementation path should not include:

- Fake providers as the main product path.
- Local auth bypass as the main product path.
- Multiple active music providers in one sync session.
- Rooms, zones, or groups for light selection.
- Continuous animation within a song.
- Durable multi-instance scheduling.
- A separate worker service.
- GraphQL subscriptions, server-sent events, or WebSockets.
- Detailed provider-specific endpoint documentation inside this roadmap.

## Later Documentation

More specific docs should be created as implementation nears each area:

- GraphQL operations and types.
- Firestore document model.
- OAuth flows and token encryption.
- Provider adapter interfaces.
- Sync session state machine.
- React UI structure.
- Cloud Run deployment and secret configuration.
