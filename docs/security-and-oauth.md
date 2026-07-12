# Security and OAuth

This document describes the trust and account direction for Song Illuminator. It is a decision guide for provider authorization, token handling, and user control.

## Direction

The first version should use provider login only rather than a separate Song Illuminator username and password. Users identify themselves through a connected music provider identity.

Open signup is allowed, so the product should treat security and consent seriously from the beginning even if the initial audience is mostly the creator and friends.

## Consent

Users should clearly understand which providers they are connecting and why. Authorization copy should explain that Song Illuminator needs provider access to read current music playback and control selected smart lights.

The product should avoid implying that all provider data is collected. The app should ask for the minimum permissions needed for the sync experience.

## Token Storage

Provider tokens should be encrypted at rest from the first beta. Token storage should support refresh flows where providers allow them, because server-side sync depends on continued access while the user is not actively interacting with the browser.

Later implementation docs should specify:

- Encryption approach.
- Key management.
- Token refresh timing.
- Token expiry handling.
- Provider-specific scopes.
- Development and production secret handling.

## Provider Disconnect

Disconnecting a provider should revoke provider access where possible and delete stored local tokens.

If a provider does not support programmatic revocation or revocation fails, the UI should still delete local credentials and explain that the user may also need to revoke access from the provider account settings.

Disconnecting a required provider should stop active sync sessions that depend on it.

## Account Model

Provider login only is the first identity model. The v1 account should be anchored to the user's music provider identity, with Spotify as the expected first account anchor.

This keeps onboarding simpler and matches the product's music-led experience, but it means later provider expansion needs a clear way to attach multiple provider connections to the same user. If Song Illuminator later adds non-music login, changes the account anchor, or supports account merging, that change will need migration planning.

## Open Signup Guardrails

Because open signup is allowed, the system should have basic guardrails:

- Clear consent and disconnect behavior.
- Encrypted provider tokens.
- Bounded sync sessions.
- Reasonable limits on background work.
- User-visible provider error states.
- Operator visibility into repeated failures.

This does not require a full public SaaS support model in v1, but it does require the beta to avoid casual handling of credentials and background provider access.

## Later Documentation

Provider-specific OAuth docs should later define exact authorization URLs, callback behavior, scopes, token refresh flows, revocation support, and local development setup.
