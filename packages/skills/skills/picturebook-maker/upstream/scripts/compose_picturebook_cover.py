from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


W, H = 1080, 1440
INK = (25, 34, 45)
MUTED = (98, 105, 118)
GOLD = (181, 112, 20)
CARD = (255, 252, 246, 222)

FONT_DIR = Path("/System/Library/Fonts")
FONT_MEDIUM = FONT_DIR / "STHeiti Medium.ttc"
FONT_LIGHT = FONT_DIR / "STHeiti Light.ttc"


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def cover_fit(img: Image.Image) -> Image.Image:
    scale = max(W / img.width, H / img.height)
    resized = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - W) // 2
    top = (resized.height - H) // 2
    return resized.crop((left, top, left + W, top + H))


def centered(draw: ImageDraw.ImageDraw, text: str, y: int, font_obj: ImageFont.FreeTypeFont, fill) -> None:
    box = draw.textbbox((0, 0), text, font=font_obj)
    draw.text(((W - (box[2] - box[0])) / 2, y), text, font=font_obj, fill=fill)


def compose_cover(
    illustration_path: Path,
    output_path: Path,
    title_line_1: str,
    title_line_2: str,
    subtitle: str,
    bottom_line: str,
    imprint: str,
) -> None:
    base = cover_fit(Image.open(illustration_path).convert("RGB")).convert("RGBA")
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rounded_rectangle((70, 54, 1010, 420), radius=44, fill=CARD)
    if bottom_line:
        od.rounded_rectangle((174, 1254, 906, 1342), radius=30, fill=(255, 252, 246, 180))
    canvas = Image.alpha_composite(base, overlay)
    draw = ImageDraw.Draw(canvas)

    centered(draw, title_line_1, 94, font(FONT_MEDIUM, 74), INK)
    centered(draw, title_line_2, 186, font(FONT_MEDIUM, 70), INK)
    draw.line((250, 308, 830, 308), fill=(218, 180, 114), width=3)
    centered(draw, subtitle, 334, font(FONT_LIGHT, 34), GOLD)
    if bottom_line:
        centered(draw, bottom_line, 1272, font(FONT_LIGHT, 34), MUTED)
    if imprint:
        centered(draw, imprint, 1370, font(FONT_LIGHT, 26), GOLD)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(output_path, quality=95)


def main() -> None:
    parser = argparse.ArgumentParser(description="Compose title and subtitle onto a picture-book cover image.")
    parser.add_argument("illustration")
    parser.add_argument("output")
    parser.add_argument("--title-line-1", required=True)
    parser.add_argument("--title-line-2", required=True)
    parser.add_argument("--subtitle", default="")
    parser.add_argument("--bottom-line", default="")
    parser.add_argument("--imprint", default="")
    args = parser.parse_args()
    compose_cover(
        Path(args.illustration),
        Path(args.output),
        args.title_line_1,
        args.title_line_2,
        args.subtitle,
        args.bottom_line,
        args.imprint,
    )


if __name__ == "__main__":
    main()

