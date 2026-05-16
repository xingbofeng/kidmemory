from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


W, H = 1080, 1440
PAPER = (247, 243, 234)
INK = (31, 39, 50)
MUTED = (89, 96, 110)
CARD = (255, 252, 246)
CARD_BORDER = (224, 204, 174)
TRANSLUCENT_CARD = (255, 252, 246, 218)
TRANSLUCENT_SOFT = (255, 252, 246, 188)

FONT_DIR = Path("/System/Library/Fonts")
FONT_MEDIUM = FONT_DIR / "STHeiti Medium.ttc"
FONT_LIGHT = FONT_DIR / "STHeiti Light.ttc"


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def cover_fit(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    target_w, target_h = size
    scale = max(target_w / img.width, target_h / img.height)
    resized = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - target_w) // 2
    top = (resized.height - target_h) // 2
    return resized.crop((left, top, left + target_w, top + target_h))


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font_obj: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        current = ""
        for ch in paragraph:
            candidate = current + ch
            box = draw.textbbox((0, 0), candidate, font=font_obj)
            if box[2] - box[0] <= max_width:
                current = candidate
            else:
                if current:
                    lines.append(current)
                current = ch
        if current:
            lines.append(current)
    return lines


def compose_page(
    illustration_path: Path,
    output_path: Path,
    page_no: int,
    total_pages: int,
    title: str,
    body_lines: list[str],
    footer_label: str,
    layout: str,
) -> None:
    canvas = Image.new("RGB", (W, H), PAPER)
    illustration = Image.open(illustration_path).convert("RGB")
    title_font = font(FONT_MEDIUM, 50)
    body_font = font(FONT_LIGHT, 36)
    footer_font = font(FONT_LIGHT, 26)
    small_body_font = font(FONT_LIGHT, 32)

    def draw_text_block(
        draw: ImageDraw.ImageDraw,
        x: int,
        y: int,
        max_width: int,
        body_font_obj: ImageFont.FreeTypeFont,
        line_gap: int,
    ) -> None:
        yy = y
        for line in wrap_text(draw, "\n".join(body_lines), body_font_obj, max_width):
            draw.text((x, yy), line, font=body_font_obj, fill=MUTED)
            yy += line_gap

    if layout == "bottom-card":
        canvas.paste(cover_fit(illustration, (W, 980)), (0, 0))
        overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.rectangle((0, 900, W, H), fill=(247, 243, 234, 222))
        canvas = Image.alpha_composite(canvas.convert("RGBA"), overlay)
        draw = ImageDraw.Draw(canvas)

        card_x, card_y, card_w, card_h = 76, 960, 928, 335
        draw.rounded_rectangle(
            (card_x, card_y, card_x + card_w, card_y + card_h),
            radius=34,
            fill=CARD,
            outline=CARD_BORDER,
            width=3,
        )
        draw.text((card_x + 58, card_y + 46), title, font=title_font, fill=INK)
        draw.line((card_x + 58, card_y + 122, card_x + card_w - 58, card_y + 122), fill=(232, 219, 195), width=2)
        draw_text_block(draw, card_x + 58, card_y + 148, card_w - 116, body_font, 48)

    elif layout == "caption-strip":
        canvas = cover_fit(illustration, (W, H)).convert("RGBA")
        overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.rounded_rectangle((86, 1038, 994, 1248), radius=34, fill=TRANSLUCENT_CARD, outline=(224, 204, 174, 225), width=3)
        canvas = Image.alpha_composite(canvas, overlay)
        draw = ImageDraw.Draw(canvas)
        draw.text((140, 1072), title, font=title_font, fill=INK)
        draw_text_block(draw, 140, 1142, 800, small_body_font, 42)

    elif layout == "floating-cloud":
        canvas = cover_fit(illustration, (W, H)).convert("RGBA")
        overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.rounded_rectangle((92, 828, 840, 1220), radius=42, fill=TRANSLUCENT_CARD, outline=(224, 204, 174, 225), width=3)
        canvas = Image.alpha_composite(canvas, overlay)
        draw = ImageDraw.Draw(canvas)
        draw.text((150, 878), title, font=title_font, fill=INK)
        draw.line((150, 948, 782, 948), fill=(232, 219, 195), width=2)
        draw_text_block(draw, 150, 984, 632, small_body_font, 42)

    elif layout == "left-panel":
        panel_w = 356
        canvas.paste(cover_fit(illustration, (W - panel_w, H)), (panel_w, 0))
        overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.rectangle((0, 0, panel_w + 16, H), fill=(255, 252, 246, 236))
        canvas = Image.alpha_composite(canvas.convert("RGBA"), overlay)
        draw = ImageDraw.Draw(canvas)
        draw.text((48, 168), title, font=font(FONT_MEDIUM, 46), fill=INK)
        draw.line((48, 246, panel_w - 46, 246), fill=(232, 219, 195), width=2)
        draw_text_block(draw, 48, 292, panel_w - 94, font(FONT_LIGHT, 34), 48)

    elif layout == "top-title":
        canvas.paste(cover_fit(illustration, (W, 1060)), (0, 190))
        overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.rectangle((0, 0, W, 210), fill=(255, 252, 246, 236))
        od.rectangle((0, 1235, W, H), fill=(255, 252, 246, 224))
        canvas = Image.alpha_composite(canvas.convert("RGBA"), overlay)
        draw = ImageDraw.Draw(canvas)
        title_box = draw.textbbox((0, 0), title, font=font(FONT_MEDIUM, 58))
        draw.text(((W - (title_box[2] - title_box[0])) / 2, 78), title, font=font(FONT_MEDIUM, 58), fill=INK)
        draw_text_block(draw, 96, 1274, 888, small_body_font, 42)

    elif layout == "wordless":
        canvas = cover_fit(illustration, (W, H)).convert("RGBA")
        if title or body_lines:
            overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
            od = ImageDraw.Draw(overlay)
            od.rounded_rectangle((160, 1192, 920, 1288), radius=28, fill=TRANSLUCENT_SOFT)
            canvas = Image.alpha_composite(canvas, overlay)
            draw = ImageDraw.Draw(canvas)
            text = body_lines[0] if body_lines else title
            text_box = draw.textbbox((0, 0), text, font=small_body_font)
            draw.text(((W - (text_box[2] - text_box[0])) / 2, 1220), text, font=small_body_font, fill=MUTED)
        else:
            draw = ImageDraw.Draw(canvas)

    else:
        raise SystemExit(f"Unknown layout: {layout}")

    draw.text((76, 1360), f"{page_no:02d}/{total_pages:02d}", font=footer_font, fill=(139, 145, 156))
    if footer_label:
        draw.text((W - 76 - 112, 1360), footer_label, font=footer_font, fill=(139, 145, 156))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(output_path, quality=95)


def main() -> None:
    parser = argparse.ArgumentParser(description="Compose stable Chinese text onto a picture-book page image.")
    parser.add_argument("illustration")
    parser.add_argument("output")
    parser.add_argument("--page-no", type=int, required=True)
    parser.add_argument("--total-pages", type=int, default=8)
    parser.add_argument("--title", required=True)
    parser.add_argument("--body", action="append", default=[], help="Body line. Repeat for multiple lines.")
    parser.add_argument("--footer-label", default="")
    parser.add_argument(
        "--layout",
        default="bottom-card",
        choices=["bottom-card", "caption-strip", "floating-cloud", "left-panel", "top-title", "wordless"],
    )
    args = parser.parse_args()
    compose_page(
        Path(args.illustration),
        Path(args.output),
        args.page_no,
        args.total_pages,
        args.title,
        args.body,
        args.footer_label,
        args.layout,
    )


if __name__ == "__main__":
    main()
