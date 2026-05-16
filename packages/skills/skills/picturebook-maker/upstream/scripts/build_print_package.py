from __future__ import annotations

import argparse
import zipfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PAPER = (247, 243, 234)
MUTED = (92, 99, 112)
FONT_LIGHT = Path("/System/Library/Fonts/STHeiti Light.ttc")


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_LIGHT), size=size)


def cover_fit(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    target_w, target_h = size
    scale = max(target_w / img.width, target_h / img.height)
    resized = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - target_w) // 2
    top = (resized.height - target_h) // 2
    return resized.crop((left, top, left + target_w, top + target_h))


def load_pages(pages_dir: Path) -> list[Path]:
    pages = sorted(p for p in pages_dir.glob("*.png") if not p.name.startswith("."))
    if not pages:
        raise SystemExit(f"No PNG pages found in {pages_dir}")
    return pages


def save_pdf(page_paths: list[Path], output: Path, size: tuple[int, int]) -> None:
    images = [cover_fit(Image.open(p).convert("RGB"), size).convert("RGB") for p in page_paths]
    output.parent.mkdir(parents=True, exist_ok=True)
    images[0].save(output, "PDF", resolution=300.0, save_all=True, append_images=images[1:])


def make_contact_sheet(page_paths: list[Path], output: Path) -> None:
    thumb_w, thumb_h = 270, 360
    cols = 5
    rows = (len(page_paths) + cols - 1) // cols
    gutter = 28
    top = 58
    sheet = Image.new("RGB", (cols * thumb_w + (cols + 1) * gutter, rows * (thumb_h + 52) + top + gutter), PAPER)
    draw = ImageDraw.Draw(sheet)
    label_font = font(24)
    for idx, path in enumerate(page_paths):
        r, c = divmod(idx, cols)
        x = gutter + c * (thumb_w + gutter)
        y = top + r * (thumb_h + 52)
        sheet.paste(cover_fit(Image.open(path).convert("RGB"), (thumb_w, thumb_h)), (x, y))
        draw.text((x, y + thumb_h + 12), path.stem, font=label_font, fill=MUTED)
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, quality=95)


def make_zip(project_dir: Path, output: Path) -> None:
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(project_dir.rglob("*")):
            if path.is_file() and path.name != output.name and path.name != ".DS_Store":
                zf.write(path, path.relative_to(project_dir.parent))


def main() -> None:
    parser = argparse.ArgumentParser(description="Build picture-book print PDFs and package zip from page PNGs.")
    parser.add_argument("project_dir")
    parser.add_argument("--print-width", type=int, default=1875)
    parser.add_argument("--print-height", type=int, default=2475)
    args = parser.parse_args()

    project_dir = Path(args.project_dir)
    pages_dir = project_dir / "pages"
    print_dir = project_dir / "print"
    page_paths = load_pages(pages_dir)

    save_pdf(page_paths, print_dir / "picturebook_print_single_pages_bleed.pdf", (args.print_width, args.print_height))
    save_pdf(page_paths, print_dir / "picturebook_combined_proof.pdf", (1800, 2400))
    make_contact_sheet(page_paths, print_dir / "picturebook_contact_sheet.png")
    make_zip(project_dir, print_dir / "picturebook_print_package.zip")


if __name__ == "__main__":
    main()

