#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "branding"

SIZE = 1024
TEXT = "GTG"

# Matches app hero gradient colors (lib/core/gtg_colors.dart).
HERO1 = (0x0D, 0x4D, 0xA8)
HERO2 = (0x0D, 0x91, 0xD6)


def _lerp(a: int, b: int, t: float) -> int:
    return int(round(a + (b - a) * t))


def _make_vertical_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), HERO1)
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        c = (_lerp(HERO1[0], HERO2[0], t), _lerp(HERO1[1], HERO2[1], t), _lerp(HERO1[2], HERO2[2], t))
        draw.line([(0, y), (size, y)], fill=c)
    return img


def _load_font(font_size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Black.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, font_size)
        except Exception:
            continue
    return ImageFont.load_default()


def _fit_font(draw: ImageDraw.ImageDraw, text: str, max_w: int, max_h: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    lo, hi = 10, 900
    best = _load_font(lo)

    while lo <= hi:
        mid = (lo + hi) // 2
        font = _load_font(mid)
        bbox = draw.textbbox((0, 0), text, font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        if w <= max_w and h <= max_h:
            best = font
            lo = mid + 1
        else:
            hi = mid - 1
    return best


def _draw_centered_text(img: Image.Image, text: str, *, color: tuple[int, int, int], max_scale: float) -> None:
    draw = ImageDraw.Draw(img)
    max_w = int(round(img.width * max_scale))
    max_h = int(round(img.height * 0.40))
    font = _fit_font(draw, text, max_w=max_w, max_h=max_h)
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (img.width - w) // 2
    y = (img.height - h) // 2
    draw.text((x, y), text, fill=color, font=font)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # iOS icon: subtle gradient background + white "GTG".
    icon = _make_vertical_gradient(SIZE)
    _draw_centered_text(icon, TEXT, color=(255, 255, 255), max_scale=0.64)  # ~18% safe margin each side
    icon.save(OUT_DIR / "app_icon_1024.png", format="PNG", optimize=True)

    # Android adaptive foreground: transparent background + white "GTG".
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_centered_text(fg, TEXT, color=(255, 255, 255), max_scale=0.64)
    fg.save(OUT_DIR / "app_icon_adaptive_fg_1024.png", format="PNG", optimize=True)

    print("Generated:")
    print(f"- {OUT_DIR / 'app_icon_1024.png'}")
    print(f"- {OUT_DIR / 'app_icon_adaptive_fg_1024.png'}")


if __name__ == "__main__":
    main()
