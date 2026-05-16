# Layout Presets

Picture books should not default to one fixed layout for every page. Choose a layout rhythm before production, then vary page layouts intentionally.

## Core Layout Menu

### L1 - Classic Bottom Story Card

Use when text is moderately long or readability is the top priority.

Structure:
- upper 65-70% illustration
- lower text card
- page number footer

Best for:
Chinese text, educational stories, first drafts, print proofing.

Risk:
Can feel like flashcards if used on every page.

Script mode:
`--layout bottom-card`

### L2 - Full-Bleed Caption Strip

Use when the picture should dominate and text is short.

Structure:
- full-page illustration
- translucent caption strip near bottom
- no heavy card

Best for:
action pages, emotional pauses, cinematic scenes.

Risk:
Needs calmer image area behind text.

Script mode:
`--layout caption-strip`

### L3 - Floating Text Cloud

Use when the illustration has natural empty space.

Structure:
- full-page illustration
- small rounded floating text bubble placed in top/bottom/side negative space

Best for:
funny pages, toy dialogue, surprise moments, pages with strong white space.

Risk:
Can cover action if image is crowded.

Script mode:
`--layout floating-cloud`

### L4 - Left Text Panel

Use when the page needs a quieter reading lane and the art has a strong vertical action.

Structure:
- left 30% text panel
- right 70% illustration

Best for:
dialogue, reflective pages, pages where action happens on one side.

Risk:
Less immersive; not good for wide group scenes.

Script mode:
`--layout left-panel`

### L5 - Top Title + Bottom Whisper

Use when the title is part of the page rhythm and body text should feel like a small aside.

Structure:
- title at top
- illustration in the center
- one or two short lines at bottom

Best for:
chapter-like page turns, poetic repetition, page openings.

Risk:
Cannot hold long text.

Script mode:
`--layout top-title`

### L6 - Wordless or Almost Wordless

Use when the image can carry the story.

Structure:
- full-page illustration
- optional tiny footer or one short line

Best for:
big emotional moments, page-turn reveals, silent consequences.

Risk:
Requires very clear image action.

Script mode:
`--layout wordless`

## Recommended Layout Rhythms

### Stable Beginner Rhythm

For first-time projects:

```text
Pages 1-2: bottom-card
Pages 3-4: caption-strip
Page 5: floating-cloud
Page 6: bottom-card
Page 7: wordless or top-title
Page 8: caption-strip
```

### Lively Humor Rhythm

For mischievous-child stories:

```text
Page 1: caption-strip
Page 2: floating-cloud
Page 3: caption-strip
Page 4: left-panel
Page 5: bottom-card
Page 6: top-title
Page 7: floating-cloud
Page 8: caption-strip
```

### Quiet Poetic Rhythm

For fables and myths:

```text
Page 1: top-title
Page 2: bottom-card
Page 3: floating-cloud
Page 4: wordless
Page 5: caption-strip
Page 6: bottom-card
Page 7: wordless
Page 8: top-title
```

## QA Rules

- Do not choose layouts only for variety. Layout must serve the page action.
- If text is over 4 lines, use `bottom-card` or `left-panel`.
- If the illustration has no clean negative space, avoid `floating-cloud`.
- If the page is a big emotional turn, consider `wordless` or `caption-strip`.
- Contact sheet should show rhythm: not every page should have the same text block unless the user wants a primer/card style.
