# Color Extraction

This document describes the first color behavior for Song Illuminator. It should guide product and implementation choices without locking in a specific image-processing algorithm.

## Direction

The default color mode should optimize for looking good in the room. Album artwork should inspire the light color, but the selected output color does not need to be the exact dominant color from the image.

The color system should be expandable from the start, even though v1 exposes only one practical mode.

## V1 Mode

V1 should show color mode as a selectable setting with only one initial option. This keeps the settings model ready for future modes while preserving a simple first user experience.

The initial mode should be a room-friendly album-cover color. It should aim to:

- Feel connected to the album artwork.
- Avoid colors that are too dark for useful lighting.
- Avoid muddy or visually unpleasant results.
- Respect the configured brightness.
- Produce stable color changes on song changes.

The exact extraction algorithm should be decided later after evaluating libraries, provider artwork formats, and test images.

## Fallback Behavior

If album artwork is missing or color extraction fails, the app should reuse the previous color at half of the current sync brightness rather than switching to an unrelated default color.

The UI should make it clear that the session is still active but using fallback color behavior.

If no previous color exists, the implementation may use a calm default fallback color. That default should be specified in a later implementation design.

## Future Modes

Future selectable modes may include:

- Exact dominant color, for users who want closer artwork accuracy.
- Palette cycle, where several colors from the artwork are used over time.
- Expressive mood, where the artwork is interpreted more creatively.
- Provider- or genre-aware behavior if it proves useful.

Future modes should fit the same high-level sync model: the music provider supplies track and artwork context, color extraction produces one or more light-ready colors, and smart light providers apply those colors to selected lights.

## Testing Examples

Later implementation docs should define representative test images and expected behavior for:

- Very dark covers.
- Black-and-white covers.
- Red-heavy covers.
- Bright pop covers.
- Pastel covers.
- Low-contrast artwork.
- Missing artwork.

The goal of testing is not perfect visual truth. The goal is to avoid surprising, harsh, or unusable room lighting.
