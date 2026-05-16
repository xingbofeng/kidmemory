# Interaction Gates

This skill should behave like an interactive picture-book director.

## Gate 1 - Story Brief

Show:

- core story question
- target age
- suggested length
- story promise

Ask:

> 这个故事核心问题和目标读者是否确认？

Do not proceed to page planning until confirmed.

## Gate 2 - Story Voice

Show 2-3 recommended voices from `presets.md`, with one recommended option first.

Ask:

> 你想用哪个故事口吻？

## Gate 3 - Visual System

Show 3-5 visual systems from `presets.md`, each with representative illustrator distillation file and best-fit use case.

Ask:

> 你想用哪个视觉系统？

## Gate 4 - Layout Rhythm

Show 2-3 recommended layout rhythms from `layout_presets.md`.

Ask:

> 你想用哪种排版节奏？

Do not default to one repeated page layout unless the user wants a primer/card style.

## Gate 5 - Page Plan

Show the whole page plan. Keep it compact:

- page title
- event
- image action
- display text

Ask:

> 这个分镜大纲和每页排版是否确认？要不要增删页或改重点？

## Gate 6 - Character Sheet

Generate only the protagonist/major character design first.

Ask:

> 这个人物形象是否确认？确认后我会用它贯穿后续页面。

Do not start pages before approval.

## Gate 7 - Page-by-Page Review

For every page:

1. generate no-text illustration
2. compose stable text locally
3. inspect visually
4. show the user the page
5. wait for approval before next page

Ask:

> 这一页是否通过？通过我继续下一页。

## Gate 8 - Cover

Show 3 title options if title is not already fixed.

Ask:

> 封面标题和画面是否确认？

## Gate 9 - Print Package

Show contact sheet and file list.

Ask:

> 页序和封面封底确认后，我再输出最终打印包。

## Exception

If the user explicitly says "全自动", "你自己审核", or "不要问我", the assistant may self-approve, but only one gate at a time unless full automation is explicitly requested.
