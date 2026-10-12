#!/usr/bin/env bash
# Composites raw App Store screenshots (store/*.png) into branded marketing
# frames with Arabic captions (store-framed/*.png), at 1320x2868 (6.9").
#
# Arabic shaping is done by Pango (HarfBuzz) via ImageMagick, using the repo's
# bundled IBM Plex Sans Arabic font so it doesn't depend on system fonts.
set -u
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

SRC_DIR="${1:-store}"
OUT_DIR="${2:-store-framed}"
FONTS_DIR="MYAIM/Resources/Fonts"
BRAND="#5B3FBF"
CW=1320
CH=2868
SHOT_W=1020
CAP_MAXW=1150

mkdir -p "$OUT_DIR"
mkdir -p "$HOME/.fonts"
cp "$FONTS_DIR"/*.ttf "$HOME/.fonts/" 2>/dev/null || true
fc-cache -f "$HOME/.fonts" >/dev/null 2>&1 || true

# librsvg renders the Arabic caption (shaped via HarfBuzz); IM composites.
command -v rsvg-convert >/dev/null 2>&1 || brew install librsvg >/dev/null 2>&1 || true

echo "=== tools ==="
magick -version | head -1 || true
rsvg-convert --version 2>/dev/null || echo "WARNING: rsvg-convert missing"
fc-list 2>/dev/null | grep -i "Plex Sans Arabic" | head -1 || echo "WARNING: font missing"

caption_for() {
  case "$1" in
    01-home*)      echo "كل الأكاديميات والمدرّبين في مكان واحد" ;;
    02-discover*)  echo "اكتشف الأقرب إليك وقارن بسهولة" ;;
    03-service*)   echo "تفاصيل واضحة وأسعار شفافة" ;;
    04-payment*)   echo "ادفع بأمان عبر التحويل أو رمز QR" ;;
    05-requests*)  echo "تأكيد الحجوزات بضغطة واحدة" ;;
    06-chat*)      echo "تواصل مباشر مع الأكاديمية — نصاً وصوتاً" ;;
    07-dashboard*) echo "لوحة متكاملة لإدارة أكاديميتك" ;;
    08-splash*)    echo "حدّد هدفك… ونكمّل الطريق معك" ;;
    *)             echo "ماي إيم — رحلتك نحو تطوير ذاتك" ;;
  esac
}

for f in "$SRC_DIR"/*.png; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  cap=$(caption_for "$name")
  echo "=== framing $name :: $cap ==="
  tmp=$(mktemp -d)

  # Caption via librsvg → PNG (Arabic shaped by HarfBuzz), then trim + fit.
  cat > "$tmp/cap.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="2200" height="260">
<text x="1100" y="165" font-family="IBM Plex Sans Arabic" font-weight="600" font-size="56" fill="#FFFFFF" text-anchor="middle" direction="rtl" xml:lang="ar">${cap}</text>
</svg>
SVG
  if rsvg-convert "$tmp/cap.svg" -o "$tmp/cap_raw.png" 2>/dev/null; then
    magick "$tmp/cap_raw.png" -trim +repage -resize ${CAP_MAXW}x\> "$tmp/cap.png" || echo "  caption trim FAILED"
  else
    echo "  caption render FAILED"
  fi

  # Screenshot resized.
  magick "$f" -resize ${SHOT_W}x "$tmp/shot.png" || echo "  shot resize FAILED"

  echo "  files: $(ls -la "$tmp" | awk 'NR>2{print $9"="$5}' | tr '\n' ' ')"

  # Brand canvas, then place screenshot (lower) and caption (top).
  magick -size ${CW}x${CH} "xc:${BRAND}" "$tmp/base.png"
  [ -f "$tmp/shot.png" ] && \
    magick "$tmp/base.png" "$tmp/shot.png" -gravity south -geometry +0+120 -composite "$tmp/base.png"
  [ -f "$tmp/cap.png" ] && \
    magick "$tmp/base.png" "$tmp/cap.png" -gravity north -geometry +0+190 -composite "$tmp/base.png"
  cp "$tmp/base.png" "$OUT_DIR/$name"
  echo "  OUT size: $(ls -la "$OUT_DIR/$name" | awk '{print $5}') bytes"
  rm -rf "$tmp"
done

echo "=== framed output ==="
magick identify -format '%f %wx%h %b\n' "$OUT_DIR"/*.png 2>/dev/null || ls -la "$OUT_DIR"
