#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "branding"

SIZE = 1024
TEXT = "GTG"
SUBTEXT = "PUSH · PULL · DIPS"

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
        c = (
            _lerp(HERO1[0], HERO2[0], t),
            _lerp(HERO1[1], HERO2[1], t),
            _lerp(HERO1[2], HERO2[2], t),
        )
        draw.line([(0, y), (size, y)], fill=c)

    # Soft top-left highlight, subtle and simple.
    base = img.convert("RGBA")
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    odraw.ellipse(
        (-int(size * 0.35), -int(size * 0.35), int(size * 0.72), int(size * 0.72)),
        fill=(255, 255, 255, 44),
    )
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=int(size * 0.035)))
    return Image.alpha_composite(base, overlay).convert("RGBA")


def _load_font(font_size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    if bold:
        candidates = [
            "/System/Library/Fonts/Supplemental/Arial Black.ttf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/System/Library/Fonts/Supplemental/Helvetica.ttc",
        ]
    else:
        candidates = [
            "/System/Library/Fonts/Supplemental/Arial.ttf",
            "/System/Library/Fonts/Supplemental/Helvetica.ttc",
            "/System/Library/Fonts/Supplemental/Helvetica.ttf",
        ]

    for path in candidates:
        try:
            return ImageFont.truetype(path, font_size)
        except Exception:
            continue
    return ImageFont.load_default()


def _fit_font(
    draw: ImageDraw.ImageDraw,
    text: str,
    *,
    max_w: int,
    max_h: int,
    bold: bool,
    max_size: int = 900,
) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    lo, hi = 8, max_size
    best = _load_font(lo, bold=bold)

    while lo <= hi:
        mid = (lo + hi) // 2
        font = _load_font(mid, bold=bold)
        bbox = draw.textbbox((0, 0), text, font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        if w <= max_w and h <= max_h:
            best = font
            lo = mid + 1
        else:
            hi = mid - 1
    return best


def _draw_brand_frame(icon: Image.Image) -> None:
    draw = ImageDraw.Draw(icon)

    outer_pad = int(SIZE * 0.16)
    inner_pad = int(SIZE * 0.27)
    outer_radius = int(SIZE * 0.18)
    inner_radius = int(SIZE * 0.14)

    draw.rounded_rectangle(
        [outer_pad, outer_pad, SIZE - outer_pad, SIZE - outer_pad],
        radius=outer_radius,
        outline=(255, 255, 255, 90),
        width=int(SIZE * 0.012),
    )
    draw.rounded_rectangle(
        [inner_pad, inner_pad, SIZE - inner_pad, SIZE - inner_pad],
        radius=inner_radius,
        outline=(255, 255, 255, 70),
        width=int(SIZE * 0.010),
    )


def _draw_text_lockup(icon: Image.Image, *, include_subtext: bool) -> None:
    draw = ImageDraw.Draw(icon)

    text_max_w = int(SIZE * 0.56)
    text_max_h = int(SIZE * 0.22)
    gtg_font = _fit_font(
        draw,
        TEXT,
        max_w=text_max_w,
        max_h=text_max_h,
        bold=True,
    )
    gtg_bbox = draw.textbbox((0, 0), TEXT, font=gtg_font)
    gtg_w = gtg_bbox[2] - gtg_bbox[0]
    gtg_h = gtg_bbox[3] - gtg_bbox[1]

    gtg_x = (SIZE - gtg_w) // 2
    gtg_y = int(SIZE * 0.34)
    draw.text((gtg_x, gtg_y), TEXT, fill=WHITE, font=gtg_font)

    if not include_subtext:
        return

    # Keep subtitle in a dedicated high-contrast strip so readability survives downscaling.
    strip_margin_x = int(SIZE * 0.17)
    strip_h = int(SIZE * 0.115)
    strip_y = int(SIZE * 0.69)
    strip_radius = int(SIZE * 0.052)
    draw.rounded_rectangle(
        [strip_margin_x, strip_y, SIZE - strip_margin_x, strip_y + strip_h],
        radius=strip_radius,
        fill=(12, 61, 118, 205),
    )
    draw.rounded_rectangle(
        [strip_margin_x, strip_y, SIZE - strip_margin_x, strip_y + strip_h],
        radius=strip_radius,
        outline=(255, 255, 255, 76),
        width=int(SIZE * 0.006),
    )

    subtitle_font = _fit_font(
        draw,
        SUBTEXT,
        max_w=int(SIZE * 0.62),
        max_h=int(SIZE * 0.050),
        bold=True,
        max_size=86,
    )
    subtitle_bbox = draw.textbbox((0, 0), SUBTEXT, font=subtitle_font)
    subtitle_w = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_h = subtitle_bbox[3] - subtitle_bbox[1]
    subtitle_x = (SIZE - subtitle_w) // 2
    subtitle_y = strip_y + (strip_h - subtitle_h) // 2 - int(SIZE * 0.002)
    draw.text((subtitle_x, subtitle_y), SUBTEXT, fill=(255, 255, 255, 235), font=subtitle_font)


def _draw_adaptive_foreground(fg: Image.Image) -> None:
    draw = ImageDraw.Draw(fg)

    _draw_text_lockup(fg, include_subtext=True)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    icon = _make_vertical_gradient(SIZE)
    _draw_text_lockup(icon, include_subtext=True)
    icon.convert("RGB").save(OUT_DIR / "app_icon_1024.png", format="PNG", optimize=True)

    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_adaptive_foreground(fg)
    fg.save(OUT_DIR / "app_icon_adaptive_fg_1024.png", format="PNG", optimize=True)

    # Preview sizes for quick readability checks.
    icon_rgb = icon.convert("RGB")
    icon_rgb.resize((180, 180), Image.Resampling.LANCZOS).save(OUT_DIR / "preview_180.png")
    icon_rgb.resize((120, 120), Image.Resampling.LANCZOS).save(OUT_DIR / "preview_120.png")
    icon_rgb.resize((60, 60), Image.Resampling.LANCZOS).save(OUT_DIR / "preview_60.png")

    print("Generated:")
    print(f"- {OUT_DIR / 'app_icon_1024.png'}")
    print(f"- {OUT_DIR / 'app_icon_adaptive_fg_1024.png'}")
    print(f"- {OUT_DIR / 'preview_180.png'}")
    print(f"- {OUT_DIR / 'preview_120.png'}")
    print(f"- {OUT_DIR / 'preview_60.png'}")


if __name__ == "__main__":
    main()
