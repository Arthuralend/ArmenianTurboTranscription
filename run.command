#!/bin/zsh
# Двойной клик в Finder запускает программу. Первый запуск ставит uv, Python и библиотеки.
cd "$(dirname "$0")"
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  echo "Устанавливаю uv (менеджер Python)…"
  curl -LsSf https://astral.sh/uv/install.sh | sh || exit 1
fi
exec uv run --python 3.12 --script transcribe.py "$@"
