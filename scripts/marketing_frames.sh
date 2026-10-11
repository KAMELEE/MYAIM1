#!/usr/bin/env bash
# Composites raw App Store screenshots (store/*.png) into branded marketing
# frames with Arabic captions (store-framed/*.png), at 1320x2868 (6.9").
#
# Arabic shaping is done by Pango (HarfBuzz) via ImageMagick, using the repo's
# bundled IBM Plex Sans Arabic font so rendering doesn't depend on system fonts.
set -u

SRC_DIR="${1:-store}"
OUT_DIR="${2:-store-framed}"
FONTS_DIR="MYAIM/Resources/Fonts"
BRAND="#5B3FBF"
CANVAS_W=1320
CANVAS_H=2868
SHOT_W=1000
RADIUS=44

mkdir -p "$OUT_DIR"

# Install bundled fonts so fontconfig/Pango can find "IBM Plex Sans Arabic".
mkdir -p "$HOME/.fonts"
cp "$FONTS_DIR"/*.ttf "$HOME/.fonts/" 2>/dev/null || true
fc-cache -f "$HOME/.fonts" >/dev/null 2>&1 || true

echo "=== ImageMagick / Pango check ==="
magick -version | head -2 || true
magick -list format 2>/dev/null | grep -i pango || echo "WARNING: no pango delegate"
fc-list 2>/dev/null | grep -i "Plex Sans Arabic" | head -4 || echo "WARNING: IBM Plex not in fontconfig"

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
  echo "framing $name :: $cap"

  tmp=$(mktemp -d)
  # 1) Resize screenshot and round its corners.
  magick "$f" -resize ${SHOT_W}x "$tmp/shot.png"
  W=$(magick identify -format '%w' "$tmp/shot.png")
  H=$(magick identify -format '%h' "$tmp/shot.png")
  magick -size ${W}x${H} xc:none \
    -draw "roundrectangle 0,0,$((W-1)),$((H-1)),$RADIUS,$RADIUS" "$tmp/mask.png"
  magick "$tmp/shot.png" "$tmp/mask.png" -alpha off -compose CopyOpacity -composite "$tmp/rounded.png"

  # 2) Arabic caption via Pango (auto-shaped, RTL), wrapped to 1120px.
  magick -background none -define pango:align=center \
    -size 1120x \
    pango:"<span font_desc='IBM Plex Sans Arabic Bold 46' foreground='#FFFFFF'>${cap}</span>" \
    "$tmp/caption.png" 2>>frames.log

  # 3) Compose onto the brand canvas.
  magick -size ${CANVAS_W}x${CANVAS_H} "xc:${BRAND}" \
    "$tmp/caption.png" -gravity north -geometry +0+175 -composite \
    "$tmp/rounded.png"  -gravity south -geometry +0+110 -composite \
    "$OUT_DIR/$name"

  rm -rf "$tmp"
done

echo "=== framed output ==="
magick identify -format '%f %wx%h\n' "$OUT_DIR"/*.png 2>/dev/null || ls -la "$OUT_DIR"
