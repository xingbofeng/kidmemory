---
name: picturebook-maker
description: Use when turning a story, myth, fable, lesson, or child-facing idea into a consistent illustrated picture book with selectable story voice, visual system, page-by-page review, and print-ready packaging.
---

# Picturebook Maker

## Core Principle

Do not generate a pile of pretty pictures. Direct a book.

A picture book needs a story question, a consistent protagonist, one emotional action per page, reliable text layout, visual QA, and printable files.

## Hard Boundary

Never promise to imitate a living creator's exact writing or illustration style. If a user names a person, distill the reusable mechanism:

- Story voice becomes a narrative system.
- Illustrator reference becomes a visual system.
- Prompts must avoid "in the style of [artist]"; use material, composition, color, pacing, and emotional rules instead.

## Required Workflow

This skill is interactive by default. Do not produce the whole book in one pass unless the user explicitly asks for full automation.

Use confirmation gates. If any choice is unclear, pause with a concise recommendation and ask the user to confirm or choose.

1. **Story Question**
   Compress the story into one child-readable question.
   Example: "If darkness blocks the road, do you wait, or make a crack of light?"
   Gate: confirm the core story question with the user before page planning.

2. **Choose Story Voice**
   Ask or choose from presets:
   - `child-fable-reversal`: child viewpoint, object personification, short sentences, reality as a question.
   - `tender-growth-adventure`: quiet courage, everyday labor, nature as a character, no pure villain, growth through choice.
   - `curiosity-experiment`: names are not understanding, explain by concrete examples, make the child test and observe.
   Gate: ask the user to choose or approve the recommended story voice.

3. **Page Plan**
   Break the book into pages. Each page must have:
   - one event
   - one emotion
   - one image action
   - display text
   - continuity notes
   Gate: show the full page plan and ask the user to approve before generating any images.

4. **Choose Visual System**
   Ask or choose from presets in `templates/presets.md`, then load the matching illustrator distillation md under `references/illustrators/`. Use the md as material/composition guidance, not imitation.
   Gate: ask the user to choose or approve the visual system.

5. **Choose Layout Rhythm**
   Ask or choose from `templates/layout_presets.md`. A picture book should have a deliberate layout rhythm, not one repeated template by accident.
   Gate: ask the user to approve the layout rhythm before generating pages.

6. **Character Sheet First**
   Generate the protagonist before pages. Fix:
   face, body shape, colors, clothing, symbol marks, expression range, forbidden changes.
   Gate: show the character image and ask the user to approve it. Do not generate story pages until the protagonist is approved.

7. **Generate One Page At A Time**
   For each page:
   - generate an image without text
   - compose title/body locally with a stable font and selected layout mode
   - inspect the rendered page
   - show the page to the user
   - continue only after user approval or an explicit user instruction to self-approve

8. **Text Layout Rule**
   Do not rely on image generation for Chinese or long text. Use local composition scripts/PIL/PowerPoint/Canva after image generation.

9. **Print Package**
   Final outputs should include:
   - page PNGs
   - front/back cover PDF
   - interior PDF
   - combined proof PDF
   - bleed single-page PDF
   - contact sheet
   - zip package

## Page QA Gate

A page passes only if:

- text is complete and readable
- no overlap or clipping
- protagonist identity remains stable
- the page action is visible without explanation
- the emotional beat matches the page text
- the visual system is consistent with prior pages

## User Confirmation Gates

Default gate order:

1. story brief and core question
2. story voice selection
3. visual system selection
4. layout rhythm selection
5. page plan / storyboard
6. character sheet
7. each finished page
8. cover title and cover image
9. final print package contact sheet

Never skip gates 1-5 unless the user explicitly says to automate decisions.

If the user says "continue" after a page, generate only the next page.

If the user says "你自己审核", self-approve only the current gate, then continue one step. Do not silently complete the entire book.

## Default Output Structure

```text
picturebook-project/
  pages/
    00_cover.png
    01_page.png
    ...
    09_back_cover.png
  print/
    picturebook_print_single_pages_bleed.pdf
    picturebook_interior_pages_bleed.pdf
    picturebook_cover_front_back_bleed.pdf
    picturebook_combined_proof.pdf
    picturebook_contact_sheet.png
    picturebook_print_package.zip
  scripts/
    compose_picturebook_page.py
    compose_picturebook_cover.py
    build_print_package.py
```

## Common Mistakes

- **Direct artist imitation**: rewrite as a visual system.
- **Generating text inside image**: compose text locally.
- **Batch-generating all pages**: causes character drift.
- **No character sheet**: every page invents a new protagonist.
- **No print proof**: beautiful images may still fail as a book.

## Presets

Use `templates/presets.md` for story voice and visual system options.
Use `templates/layout_presets.md` for page layout rhythm options.

Use `references/illustrators/*.md` as the source of truth for visual personas. If a user asks for a new illustrator or picture-book creator, distill that person into a new md file first, then reference it from the visual menu.
