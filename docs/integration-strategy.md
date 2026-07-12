# Integration Strategy

This document describes how Song Illuminator should think about music and smart light providers. It is a decision guide for the first implementation, not a provider-specific API contract.

## Direction

Song Illuminator should use provider adapter concepts from the start. Spotify and Philips Hue are the first concrete integrations, but the product and system should be shaped around replaceable music provider and smart light provider roles.

The goal is not to build a complex plugin platform in v1. The goal is to avoid hard-coding product behavior so deeply around the first integrations that future providers become awkward to add.

## Provider Roles

### Music Provider

A music provider supplies the playback context that drives sync.

The shared provider concept should include:

- Connection status.
- Current playback state.
- Current track title and artist.
- Album artwork metadata.
- Track identity sufficient to detect song changes.

Each sync session should follow exactly one active music provider. Users may connect more music providers later, but active-provider selection should be explicit rather than guessed automatically.

### Smart Light Provider

A smart light provider supplies controllable lights.

The shared provider concept should include:

- Connection status.
- Discoverable individual lights.
- Light identity and display name.
- Ability to set color.
- Ability to set brightness.
- Ability to report update success or failure.

V1 should target individual lights. Provider groups, rooms, zones, and scenes can be added later as higher-level selection features.

## Multiple Providers

The product should allow for one active music provider per sync session and, over time, selected lights across multiple smart light providers.

This means the sync session should conceptually have:

- One music source.
- One or more light targets.
- Light targets that may belong to different providers in later versions.

The first implementation can support only Spotify and Philips Hue if needed, but the documentation and boundaries should leave room for more providers.

## Adapter Expectations

Provider adapters should hide provider-specific API details from the rest of the application. Application-level flows should ask for playback, artwork, lights, and color updates in product terms.

Adapters may still expose provider-specific limits or unsupported capabilities where the product needs to make a user-visible decision. Unsupported capabilities should be hidden or shown as unavailable rather than silently failing.

## First Providers

Spotify is the expected first music provider. It should provide playback state, track metadata, and album artwork needed for color extraction.

Philips Hue is the expected first smart light provider. For the hosted app concept, Hue cloud OAuth is preferred over local bridge discovery so server-side sync can keep working when the browser is not on the local network.

## Later Documentation

Provider-specific docs should later define actual OAuth flows, endpoints, rate limits, data mapping, provider error codes, and capability differences.

