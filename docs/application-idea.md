# Song Illuminator Application Idea
  
Song Illuminator is a hosted web application that connects a user's music listening activity with smart lights. When sync is active, the app follows the song currently playing through a connected music provider, extracts a color from the album cover, and applies that color to selected smart lights.

The first version is intended for a small beta audience. It should be polished enough for real use, but the goal is still to validate the core experience before committing to detailed product, architecture, and operations decisions. Spotify and Philips Hue are the expected first music and smart light integrations, but the product should be described and shaped so additional providers can be added later.

## Product Goal

The application should make music feel present in the room without requiring constant user attention. A user connects a music provider and a smart light provider, chooses which lights participate, starts sync, and then lets the app keep the room aligned with their music.

During sync, the user should be able to see:

- The current playback state.
- The song and artist being tracked.
- The album artwork or related metadata.
- The color currently attributed to the song.
- Whether the selected lights were updated successfully.

## Core User Journey

1. The user opens the web app.
2. The user connects their music provider account.
3. The user connects their smart light provider account.
4. The user selects one or more lights, rooms, or zones to control.
5. The user adjusts core sync settings.
6. The user starts music light sync.
7. The app tracks provider playback and updates the selected lights based on the album cover color.
8. The user can stop sync at any time.

The main interaction surface should stay focused on connection status, selected lights, sync state, current song, attributed color, and a small set of settings.

## Sync Behavior

Sync should be powered by a backend worker or server-side session rather than depending on an active browser tab. This lets the experience continue while the user is not interacting with the app.

The sync session should:

- Poll or otherwise track the user's current playback through the connected music provider.
- Detect song changes and playback state changes.
- Fetch or reuse album artwork metadata.
- Extract a color from the album cover.
- Apply the selected color to the chosen smart lights.
- Keep running for a configurable duration, defaulting to about one hour.
- Stop when the user explicitly stops sync, when authorization fails, or when the configured duration expires.

If playback is paused, private, unavailable, or otherwise not actively producing a usable track, the app should enter a graceful idle state. In that state, it should stop changing the lights, show the current status clearly, and keep the sync session alive until the user stops it or the session times out.

## Initial Settings

The first useful version should include only the settings needed to shape the core experience:

- Selected lights, rooms, or zones.
- Brightness.
- Update interval.
- Color mode.
- Sync enabled or disabled.

These settings should be easy to understand and safe to change while sync is active where practical.

## Color Extraction

The color system should be designed as an expandable part of the product.

The likely default mode is a dominant pleasant color: extract a representative color from the album cover, then adjust it so it works well as room lighting. This may mean avoiding colors that are too dim, muddy, overly harsh, or visually uncomfortable.

Future selectable modes can include:

- Exact dominant color, for users who want the closest match to the cover art.
- Palette cycling, where the app rotates through several colors from the album artwork during the track.
- Additional mood-aware or genre-aware modes if they prove useful later.

The initial idea document should not prescribe a specific color extraction algorithm. That should be covered later in a dedicated technical design.

## Provider Connections

Music providers and smart light providers should be treated as user-owned integrations requiring clear consent and revocation.

For the first hosted web app concept, Spotify is the expected first music provider and Philips Hue is the expected first smart light provider. Philips Hue should use Hue cloud OAuth rather than relying on local bridge discovery. This keeps the first version aligned with a server-side sync model and makes the experience usable even when the browser is not on the same local network as the Hue bridge.

The provider model should leave room for future music providers, smart light providers, and multiple connected light ecosystems. Later versions may let a user connect more than one smart light provider and choose lights across those providers for a single sync session.

Later documentation should define the OAuth flows, token storage model, refresh behavior, error handling, and account disconnect behavior.

## Major System Responsibilities

At a high level, the application will need:

- A web interface for account connection, light selection, settings, and sync controls.
- A backend API for user sessions, integration state, selected lights, settings, and sync lifecycle commands.
- A background sync worker or equivalent server-side process for long-running music light sync.
- Music provider integration for playback state and album artwork metadata, starting with Spotify.
- Smart light provider integration for discovering controllable lights and applying color updates, starting with Philips Hue.
- A color extraction component that turns album artwork into one or more light-friendly colors.
- Observability for sync status, failures, authorization problems, and light update outcomes.

## Future Documentation

This document is intentionally broad. More specific docs should be created later for:

- Product requirements and user flows.
- UI structure and interaction states.
- Music provider OAuth and playback tracking, starting with Spotify.
- Smart light provider OAuth, light discovery, and color updates, starting with Philips Hue.
- Token storage and account security.
- Sync worker lifecycle and scheduling.
- Color extraction algorithms and color modes.
- Data model and API contracts.
- Deployment, configuration, monitoring, and operational limits.
