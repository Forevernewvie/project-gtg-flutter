#!/usr/bin/env python3
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "branding"

SIZE = 1024
TEXT = "GTG"

# Matches app hero gradient colors (lib/core/gtg_colors.dart).
HERO1 = (0x0D, 0x4D, 0xA8)
HERO2 = (0x0D, 0x91, 0xD6)
WHITE = (255, 255, 255)


def _lerp(a: int, b: int, t: float) -> int:
    return int(round(a + (b - a) * t))


def _make_vertical_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), HERO1)
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        c = (_lerp(HERO1[0], HERO2[0], t), _lerp(HERO1[1], HERO2[1], t), _lerp(HERO1[2], HERO2[2], t))
        draw.line([(0, y), (size, y)], fill=c)

    # Subtle highlight for a more "premium" look (kept intentionally minimal).
    base = img.convert("RGBA")
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    odraw.ellipse(
        (-int(size * 0.25), -int(size * 0.25), int(size * 0.95), int(size * 0.95)),
        fill=(255, 255, 255, 36),
    )
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=int(size * 0.03)))
    return Image.alpha_composite(base, overlay).convert("RGB")


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


def _draw_loop_arrow(
    img: Image.Image,
    *,
    rgba: tuple[int, int, int, int],
    radius: int,
    stroke_width: int,
    theta_degrees: float,
    arrow_length: int,
    arrow_width: int,
) -> None:
    """
    Draw a loop (circle outline) with a small arrow head.

    - Coordinate system: (0,0) top-left; y increases downward.
    - theta_degrees: 0 at 3 o'clock (right), increasing clockwise.
    """
    if img.mode != "RGBA":
        raise ValueError("_draw_loop_arrow requires an RGBA image")

    cx = img.width / 2.0
    cy = img.height / 2.0

    draw = ImageDraw.Draw(img)
    bbox = (cx - radius, cy - radius, cx + radius, cy + radius)
    draw.ellipse(bbox, outline=rgba, width=stroke_width)

    theta = math.radians(theta_degrees)
    px = cx + radius * math.cos(theta)
    py = cy + radius * math.sin(theta)

    # Tangent direction for clockwise travel (increasing theta).
    tx = -math.sin(theta)
    ty = math.cos(theta)
    # Normal (perpendicular) for arrow base width.
    nx = -ty
    ny = tx

    tipx = px + tx * arrow_length
    tipy = py + ty * arrow_length
    basex = px - tx * (arrow_length * 0.45)
    basey = py - ty * (arrow_length * 0.45)
    half_w = arrow_width / 2.0
    leftx = basex + nx * half_w
    lefty = basey + ny * half_w
    rightx = basex - nx * half_w
    righty = basey - ny * half_w

    draw.polygon([(tipx, tipy), (leftx, lefty), (rightx, righty)], fill=rgba)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # iOS icon: subtle gradient background + loop motif + white "GTG".
    icon = _make_vertical_gradient(SIZE).convert("RGBA")
    _draw_loop_arrow(
        icon,
        rgba=(255, 255, 255, 84),
        radius=int(SIZE * 0.305),
        stroke_width=int(SIZE * 0.032),
        theta_degrees=312.0,
        arrow_length=int(SIZE * 0.060),
        arrow_width=int(SIZE * 0.070),
    )
    _draw_centered_text(icon, TEXT, color=WHITE, max_scale=0.64)  # ~18% safe margin each side
    icon.convert("RGB").save(OUT_DIR / "app_icon_1024.png", format="PNG", optimize=True)

    # Android adaptive foreground: transparent background + loop motif + white "GTG".
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_loop_arrow(
        fg,
        rgba=(255, 255, 255, 255),
        radius=int(SIZE * 0.275),
        stroke_width=int(SIZE * 0.030),
        theta_degrees=312.0,
        arrow_length=int(SIZE * 0.055),
        arrow_width=int(SIZE * 0.065),
    )
    _draw_centered_text(fg, TEXT, color=WHITE, max_scale=0.64)
    fg.save(OUT_DIR / "app_icon_adaptive_fg_1024.png", format="PNG", optimize=True)

    print("Generated:")
    print(f"- {OUT_DIR / 'app_icon_1024.png'}")
    print(f"- {OUT_DIR / 'app_icon_adaptive_fg_1024.png'}")


if __name__ == "__main__":
    main()
