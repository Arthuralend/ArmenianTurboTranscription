#!/bin/zsh
# Собирает «Armenian Transcription.app» из transcribe.py и assets/icon-1024.png.
# Нужны только штатные утилиты macOS (sips, iconutil, ditto).
set -euo pipefail
cd "$(dirname "$0")"
APP="Armenian Transcription.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s assets/icon-1024.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) assets/icon-1024.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$(dirname "$ICONSET")"

cp transcribe.py icon.png "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Armenian Transcription</string>
  <key>CFBundleDisplayName</key><string>Armenian Transcription</string>
  <key>CFBundleIdentifier</key><string>io.github.arthuralend.armenianturbotranscription</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>launcher</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

cat > "$APP/Contents/MacOS/launcher" <<'LAUNCH'
#!/bin/zsh
RES="$(cd "$(dirname "$0")/../Resources" && pwd)"
LOG="$HOME/Library/Logs/ArmenianTranscription.log"
MARK="$HOME/Library/Application Support/ArmenianTranscription/ready"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
exec >>"$LOG" 2>&1
echo "=== $(date) ==="

notify() { osascript -e "display notification \"$1\" with title \"Armenian Transcription\""; }
fail() { osascript -e "display alert \"Armenian Transcription\" message \"$1\n\nЖурнал: ~/Library/Logs/ArmenianTranscription.log\" as critical"; exit 1; }

if ! command -v uv >/dev/null 2>&1; then
  notify "Первый запуск: устанавливаю uv…"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh || fail "Не удалось установить uv. Проверьте интернет."
fi
if [[ ! -f "$MARK" ]]; then
  notify "Первый запуск: ставлю Python и библиотеки (~1,5 ГБ), это займёт несколько минут"
  uv run --python 3.12 --script "$RES/transcribe.py" --check || fail "Не удалось установить зависимости. Нужно ~6 ГБ свободного места."
  mkdir -p "$(dirname "$MARK")" && touch "$MARK"
fi
exec uv run --python 3.12 --script "$RES/transcribe.py"
LAUNCH
chmod +x "$APP/Contents/MacOS/launcher"

ditto -c -k --norsrc --noextattr --noqtn --keepParent "$APP" "ArmenianTranscription-macOS.zip"
echo "Готово: $APP и ArmenianTranscription-macOS.zip"
