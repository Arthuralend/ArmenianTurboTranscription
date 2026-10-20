#!/bin/zsh
# Собирает автономное «Armenian Transcription.app»: Python, PyTorch и библиотеки внутри,
# ничего ставить не нужно. Модель (~3,2 ГБ) скачивается при первой транскрибации.
# Нужен Python 3.12 с Tkinter (например, с python.org) на Mac с Apple Silicon.
set -euo pipefail
cd "$(dirname "$0")"
APP="Armenian Transcription.app"
PY="${PYTHON:-python3.12}"

rm -rf build dist .venv-build "$APP"
"$PY" -m venv .venv-build
source .venv-build/bin/activate
pip install --upgrade pip
pip install "torch>=2.4" "transformers>=4.45,<5" "av>=12" numpy "pyinstaller>=6.10"

ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s assets/icon-1024.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) assets/icon-1024.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o build-AppIcon.icns
rm -rf "$(dirname "$ICONSET")"

pyinstaller --noconfirm --windowed --name "Armenian Transcription" \
  --icon build-AppIcon.icns \
  --osx-bundle-identifier io.github.arthuralend.armenianturbotranscription \
  --add-data "icon.png:." \
  --collect-all transformers \
  --collect-all tokenizers \
  --collect-all av \
  --collect-data torch \
  --recursive-copy-metadata transformers \
  --copy-metadata torch \
  transcribe.py
rm -f build-AppIcon.icns

mv "dist/$APP" "$APP"
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 12.0" "$APP/Contents/Info.plist" 2>/dev/null || true
codesign --force --deep --sign - "$APP"
ditto -c -k --keepParent "$APP" "ArmenianTranscription-macOS-standalone.zip"
echo "Готово: $APP и ArmenianTranscription-macOS-standalone.zip"
