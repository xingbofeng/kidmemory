# picturebook-maker (KidMemory vendor)

Upstream source:
- https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker

Local layout:
- `upstream/`: vendored upstream files
- `extensions/generate_pollinations_image.mjs`: KidMemory Pollinations extension (prompt-only)

KidMemory constraints:
- No arbitrary shell execution from skill runtime.
- Pollinations requests must be prompt-only; do not upload child photos.
- If Pollinations fails or times out, skip cover and continue the export flow.
