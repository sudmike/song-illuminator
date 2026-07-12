# Product Requirements

This document describes the first useful Song Illuminator beta from a product perspective. It should guide implementation decisions without becoming a full UI specification.

## Audience

The first beta is primarily for the creator and friends. It should be usable by real people in real homes, but it does not need broad-market onboarding polish yet.

Open signup is allowed, so the product should still behave responsibly with accounts, provider permissions, and background sync limits. The experience should feel safe, understandable, and easy to stop.

## V1 Goal

The first version should prove that provider-backed music-to-light sync is compelling and extensible.

V1 should optimize for provider flexibility rather than treating the first music and light integrations as the permanent shape of the product. Spotify and Philips Hue are the expected first providers, but user-facing language and product concepts should use broader terms like music provider and smart light provider.

## Happy Path

1. The user opens Song Illuminator.
2. The user signs in through a supported provider.
3. The user connects one active music provider.
4. The user connects one smart light provider.
5. The user selects individual lights for sync.
6. The user reviews core settings.
7. The user starts sync.
8. The app shows the current song, artist, album art, selected color, and sync status.
9. On each song change, the selected lights update to a room-friendly album-cover color.
10. The user stops sync, and the lights remain on the last color at half of the active sync brightness.

## Core User Flows

### Connect Providers

Users should be able to connect the providers needed for a sync session. For the first implementation, Spotify is the expected music provider and Philips Hue is the expected smart light provider.

Connection states should be clear:

- Not connected.
- Connecting.
- Connected.
- Needs attention.
- Disconnected.

### Select Lights

V1 should support selecting individual lights only. Rooms, groups, and zones can be introduced later once the provider model and basic sync experience are proven.

The selection UI should make it clear which provider each light belongs to if multiple smart light providers are supported later.

### Configure Sync

The initial settings should stay small:

- Selected lights.
- Brightness.
- Color mode.
- Sync enabled or disabled.

Color mode should appear as a selectable setting even if there is only one available option in v1. This keeps the UI shape ready for future modes without adding early complexity.

### Run Sync

The running sync view should emphasize the music and color experience:

- Current song.
- Artist.
- Album art.
- Attributed color.
- Sync status.
- Start or stop control.

Provider health and device update details can be present, but they should not dominate the main experience unless something needs user attention.

### Stop Sync

When sync stops, the app should leave the lights on the last attributed color at half of the active sync brightness. This is the intended v1 stop behavior and should be described as part of the product experience.

Later versions may add restore previous state or apply scene behavior, but those are not required for v1.

## V1 Non-Goals

V1 does not need:

- Multiple active music providers in one sync session.
- Group, room, or zone selection.
- Continuous animation within a song.
- Advanced scene creation.
- Exact provider feature parity.
- Detailed sync history for users.
- A full public SaaS support model.

## Acceptance Criteria

The beta experience is successful when a user can connect providers, select individual lights, start sync, see the current song and color, have lights update on song changes, and stop sync with the final color left at half of the active sync brightness.
