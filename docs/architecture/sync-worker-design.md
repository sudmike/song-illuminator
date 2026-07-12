# Sync Worker Design

This document describes the intended behavior of server-side sync sessions. It should guide the first worker implementation without prescribing a final queue, scheduler, or runtime technology.

## Direction

Music light sync should run in a backend worker or server-side session. It should not depend on an active browser tab.

This lets a user start sync, stop interacting with the app, and still have the room update for a bounded amount of time.

## Session Lifecycle

A sync session should move through clear lifecycle states:

- Starting.
- Running.
- Idle.
- Needs attention.
- Stopping.
- Stopped.
- Expired.

The default session duration should be one hour. The maximum session duration should be four hours.

A session should stop when:

- The user stops it.
- The configured duration expires.
- Required authorization can no longer be refreshed or recovered.
- The worker determines that continued sync would be unsafe or invalid.

## Sync Loop

The worker should track playback through the selected active music provider. It should update lights on song changes rather than continuously animating within a song.

The basic loop should:

1. Load the session configuration.
2. Confirm provider authorization and selected light targets.
3. Read current playback from the active music provider.
4. Detect whether the current track changed.
5. Resolve album artwork for the current track.
6. Extract or reuse a room-friendly color.
7. Apply the color and configured brightness to selected lights.
8. Report current song, color, and sync status for the UI.
9. Continue until stopped, expired, or degraded into an unrecoverable state.

The exact polling cadence should be decided in the implementation design after provider rate limits and API behavior are reviewed. It is an internal implementation detail for v1, not a user-facing setting. User-visible light changes should still happen on song changes.

## Idle Behavior

The worker should enter graceful idle when playback is paused, private, unavailable, or not associated with a usable track. Idle is for normal no-playback conditions, not repeated provider failures or authorization problems.

In idle:

- The worker should stop changing lights.
- The UI should show the current idle reason.
- The session should remain alive until stopped or expired.
- The worker should keep checking whether usable playback resumes.

## Failure Behavior

Transient provider or light update failures should be retried. If failures continue, the session should move into a needs-attention state instead of repeatedly changing lights or failing silently.

The first behavior should be retry then needs attention:

- Retry short-lived provider/API failures.
- Preserve the latest known song and color where useful.
- Stop issuing light updates after repeated failures.
- Show needs-attention status to the user.

Authorization failures should be handled separately from transient provider errors. If provider access cannot be refreshed or restored, the session should stop or require user attention. Detailed failure states such as auth failed or light update failed can be defined in later implementation docs.

## Stop Behavior

When the user stops sync, selected lights should remain on the last attributed color at half of the active sync brightness. The worker does not need to restore the previous light state in v1.

Future versions may add options to restore previous state, turn lights off, or apply a configured scene.

## Observability

The worker should make sync status understandable to both the user and the operator. Later implementation docs should define logs, metrics, and status events for session starts, stops, song changes, color extraction, provider failures, and light update failures.
