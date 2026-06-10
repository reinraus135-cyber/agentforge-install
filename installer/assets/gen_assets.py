#!/usr/bin/env python3
"""Generate AgentForge installer brand assets (app icon + MUI bitmaps).

Reproduces the storefront anvil mark (site/public/favicon.svg) in the brand
palette so the Windows installer visually matches agentforge.army:
  - rounded square filled with the indigo -> ember "anvil" gradient
  - white anvil stroke + an ember spark dot

Outputs (written next to this script, in installer/assets/):
  AgentForge.ico   multi-size app/uninstall icon (16..256)
  welcome.bmp      164x314  MUI welcome + finish side panel (dark luxury)
  header.bmp       150x57   MUI inner-page header logo (on white)

Also drops PNG previews in /tmp for visual QA. Deterministic; re-run any time.
Brand source: site/src/layouts/Base.astro, site/src/styles/global.css.
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))

# --- Brand palette (hex from the Astro storefront tokens) ---
INDIGO    = (0x4F, 0x46, 0xE5)  # indigo-600  #4F46E5
INDIGO_L  = (0x7C, 0x82, 0xF5)  # indigo-400  #7C82F5
EMBER     = (0xF9, 0x73, 0x16)  # ember-500   #F97316
EMBER_L   = (0xFF, 0xB3, 0x5C)  # ember-300   #FFB35C
PAPER_50  = (0xFA, 0xFA, 0xF8)  # #FAFAF8
PAPER_300 = (0xD9, 0xD6, 0xCC)  # #D9D6CC
PAPER_400 = (0xA8, 0xA4, 0x98)  # #A8A498
PAPER_800 = (0x28, 0x27, 0x23)  # #282723
PAPER_900 = (0x1A, 0x19, 0x16)  # #1A1916
PAPER_950 = (0x11, 0x11, 0x10)  # #111110
WHITE     = (0xFF, 0xFF, 0xFF)

# Diagonal gradient stops, matching favicon.svg (offsets 0% / 50% / 110%).
STOPS = [(0.0, INDIGO), (0.5, INDIGO_L), (1.1, EMBER)]


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def grad_color(t):
    t = max(0.0, min(1.0, t))
    for i in range(len(STOPS) - 1):
        p0, c0 = STOPS[i]
        p1, c1 = STOPS[i + 1]
        if t <= p1 or i == len(STOPS) - 2:
            f = 0.0 if p1 == p0 else (t - p0) / (p1 - p0)
            return lerp(c0, c1, max(0.0, min(1.0, f)))
    return STOPS[-1][1]


def diagonal_gradient(w, h):
    """RGB image filled with the 135deg indigo->ember gradient."""
    img = Image.new("RGB", (w, h))
    px = img.load()
    denom = (w - 1) + (h - 1) or 1
    for y in range(h):
        for x in range(w):
            px[x, y] = grad_color((x + y) / denom)
    return img


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return m


def arc_pts(cx, cy, r, a0, a1, n=14):
    return [
        (cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)))
        for a in [a0 + (a1 - a0) * k / n for k in range(n + 1)]
    ]


def stroke_polyline(draw, pts, width, fill):
    """Round-capped, round-joined stroke (discs at vertices + thick segments)."""
    r = width / 2.0
    for x, y in pts:
        draw.ellipse([x - r, y - r, x + r, y + r], fill=fill)
    for i in range(len(pts) - 1):
        draw.line([pts[i], pts[i + 1]], fill=fill, width=int(round(width)))


def render_mark(px, ss=4, spark=True):
    """Anvil mark on the rounded-square gradient -> RGBA image px*px."""
    S = px * ss
    scale = S / 32.0  # favicon viewBox is 32

    grad = diagonal_gradient(S, S)
    mark = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    mark.paste(grad, (0, 0), rounded_mask((S, S), int(round(7 * scale))))

    d = ImageDraw.Draw(mark)
    w = 2.2 * scale

    def sp(pts):
        return [(x * scale, y * scale) for (x, y) in pts]

    # Anvil body: M7,14 H18 ~arc~ (22,18) H11 l-1,3 H21
    path_a = (
        [(7, 14), (18, 14)]
        + arc_pts(18, 18, 4, 270, 360)[1:]
        + [(11, 18), (10, 21), (21, 21)]
    )
    stroke_polyline(d, sp(path_a), w, WHITE + (255,))
    # Anvil base: M10,24 H18
    stroke_polyline(d, sp([(10, 24), (18, 24)]), w, WHITE + (255,))

    if spark:
        cx, cy, rr = 25 * scale, 8 * scale, 2.6 * scale
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=EMBER + (255,))

    return mark.resize((px, px), Image.LANCZOS)


# --- Fonts -------------------------------------------------------------------
_FONT_BOLD = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf",
]
_FONT_REG = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf",
]


def font(size, bold=False):
    for p in (_FONT_BOLD if bold else _FONT_REG):
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def text_w(draw, s, fnt):
    b = draw.textbbox((0, 0), s, font=fnt)
    return b[2] - b[0]


def fit_font(draw, text, max_w, cap, bold=False):
    """Largest font (<= cap px) whose rendered width fits max_w."""
    size = int(cap)
    while size > 6:
        f = font(size, bold)
        if text_w(draw, text, f) <= max_w:
            return f
        size -= 1
    return font(6, bold)


def soft_glow(size, center, radius, color, alpha):
    """A blurred radial glow as an RGBA layer."""
    g = Image.new("L", size, 0)
    d = ImageDraw.Draw(g)
    cx, cy = center
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=alpha)
    g = g.filter(ImageFilter.GaussianBlur(radius * 0.55))
    layer = Image.new("RGBA", size, color + (0,))
    layer.putalpha(g)
    return layer


# --- Welcome / finish side panel (164x314) -----------------------------------
def build_welcome():
    W, H, ss = 164, 314, 3
    cw, ch = W * ss, H * ss
    img = Image.new("RGB", (cw, ch), PAPER_950)

    # ambient depth: indigo glow upper, ember glow lower
    base = img.convert("RGBA")
    base = Image.alpha_composite(
        base, soft_glow((cw, ch), (cw * 0.30, ch * 0.30), cw * 0.55, INDIGO, 120)
    )
    base = Image.alpha_composite(
        base, soft_glow((cw, ch), (cw * 0.78, ch * 0.82), cw * 0.50, EMBER, 90)
    )
    img = base.convert("RGB")
    d = ImageDraw.Draw(img)

    # vignette edge
    vig = Image.new("L", (cw, ch), 0)
    ImageDraw.Draw(vig).rectangle([0, 0, cw - 1, ch - 1], outline=255, width=int(2 * ss))
    img.paste(PAPER_950, (0, 0), vig.filter(ImageFilter.GaussianBlur(ss)))

    margin = int(15 * ss)

    # mark
    mk = int(84 * ss)
    mark = render_mark(mk)
    mx = (cw - mk) // 2
    my = int(56 * ss)
    img.paste(mark, (mx, my), mark)

    # wordmark (auto-fit so it never clips the panel)
    word = "AgentForge"
    f_word = fit_font(d, word, cw - 2 * margin, 29 * ss, bold=True)
    wx = (cw - text_w(d, word, f_word)) // 2
    wy = my + mk + int(20 * ss)
    d.text((wx, wy), word, font=f_word, fill=PAPER_50)
    wh = d.textbbox((0, 0), word, font=f_word)[3]

    # tagline
    tag = "Pay once. Own your AI team."
    f_tag = fit_font(d, tag, cw - 2 * margin, 12 * ss, bold=False)
    tx = (cw - text_w(d, tag, f_tag)) // 2
    ty = wy + wh + int(12 * ss)
    d.text((tx, ty), tag, font=f_tag, fill=PAPER_400)

    # thin ember divider
    dl = int(26 * ss)
    dy = ty + int(28 * ss)
    d.line([(cw // 2 - dl, dy), (cw // 2 + dl, dy)], fill=EMBER, width=max(1, int(1.4 * ss)))

    # footer url
    f_url = font(int(10 * ss), bold=False)
    url = "agentforge.army"
    ux = (cw - text_w(d, url, f_url)) // 2
    d.text((ux, ch - int(26 * ss)), url, font=f_url, fill=PAPER_400)

    out = img.resize((W, H), Image.LANCZOS)
    out.save(os.path.join(HERE, "welcome.bmp"))
    out.save("/tmp/af_welcome_preview.png")


# --- Inner-page header logo (150x57, on white) -------------------------------
def build_header():
    W, H, ss = 150, 57, 4
    cw, ch = W * ss, H * ss
    img = Image.new("RGB", (cw, ch), WHITE)
    d = ImageDraw.Draw(img)

    mk = int(31 * ss)
    mark = render_mark(mk)
    pad = int(11 * ss)
    gap = int(8 * ss)
    right_pad = int(10 * ss)
    my = (ch - mk) // 2
    img.paste(mark, (pad, my), mark)

    word = "AgentForge"
    avail = cw - pad - mk - gap - right_pad
    f_word = fit_font(d, word, avail, 18 * ss, bold=True)
    wy = (ch - d.textbbox((0, 0), word, font=f_word)[3]) // 2
    d.text((pad + mk + gap, wy), word, font=f_word, fill=PAPER_900)

    out = img.resize((W, H), Image.LANCZOS)
    out.save(os.path.join(HERE, "header.bmp"))
    out.save("/tmp/af_header_preview.png")


# --- App icon ----------------------------------------------------------------
def build_icon():
    master = render_mark(256)
    sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    master.save(os.path.join(HERE, "AgentForge.ico"), format="ICO", sizes=sizes)
    master.save("/tmp/af_icon_preview.png")


if __name__ == "__main__":
    os.makedirs(HERE, exist_ok=True)
    build_icon()
    build_header()
    build_welcome()
    print("Assets written to", HERE)
    for n in ("AgentForge.ico", "header.bmp", "welcome.bmp"):
        p = os.path.join(HERE, n)
        print(f"  {n}: {os.path.getsize(p)} bytes")
