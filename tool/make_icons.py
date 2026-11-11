#!/usr/bin/env python3
"""Render gradll's web icons from the in-app brand mark: the Iconsax Plus
bold "teacher" glyph in white on the blue → indigo gradient (GtBrand.blue →
GtBrand.indigo). Run from the repo root: python3 tool/make_icons.py
"""
import glob
import os
from PIL import Image, ImageDraw, ImageFont

BLUE = (0x01, 0x66, 0xF4)
INDIGO = (0x14, 0x00, 0x5A)
GLYPH = chr(0xEC24)  # IconsaxPlusBold.teacher
FONT = glob.glob(os.path.expanduser(
    '~/.pub-cache/hosted/pub.dev/iconsax_plus-*/fonts/IconsaxPlusBold.ttf'))[-1]
SS = 4  # supersampling


def gradient(n):
    img = Image.new('RGB', (n, n))
    px = img.load()
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2 * (n - 1))
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(BLUE, INDIGO))
    return img


def icon(size, *, rounded, glyph_frac):
    n = size * SS
    img = gradient(n).convert('RGBA')
    font = ImageFont.truetype(FONT, round(n * glyph_frac))
    d = ImageDraw.Draw(img)
    l, t, r, b = d.textbbox((0, 0), GLYPH, font=font)
    d.text(((n - (r - l)) / 2 - l, (n - (b - t)) / 2 - t), GLYPH, font=font, fill='white')
    if rounded:
        mask = Image.new('L', (n, n), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, n - 1, n - 1), radius=n * 0.3, fill=255)
        img.putalpha(mask)
    return img.resize((size, size), Image.LANCZOS)


out = {
    'web/favicon.png': icon(32, rounded=True, glyph_frac=0.62),
    'web/icons/Icon-192.png': icon(192, rounded=True, glyph_frac=0.55),
    'web/icons/Icon-512.png': icon(512, rounded=True, glyph_frac=0.55),
    # Maskable: full bleed, glyph inside the 80% safe zone.
    'web/icons/Icon-maskable-192.png': icon(192, rounded=False, glyph_frac=0.45),
    'web/icons/Icon-maskable-512.png': icon(512, rounded=False, glyph_frac=0.45),
    # iOS rounds the corners itself and shows transparency as black.
    'web/icons/apple-touch-icon.png': icon(180, rounded=False, glyph_frac=0.5),
}
for path, img in out.items():
    img.save(path, optimize=True)
    print(path, img.size)
