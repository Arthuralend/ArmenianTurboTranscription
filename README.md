<p align="center"><img src="assets/icon-1024.png" width="160" alt="Խ"></p>

# Armenian Turbo Transcription

Простая программа для macOS: превращает армянскую речь из аудио- и видеофайлов в текст.
Работает локально на вашем Mac, использует модель
[ditord/whisper-large-v3-turbo-armenian](https://huggingface.co/ditord/whisper-large-v3-turbo-armenian) —
Whisper Large V3 Turbo, дообученный на армянском (WER 15,3 %, CER 2,9 % на Common Voice 20).

## Требования

- Mac на Apple Silicon (M1 и новее), macOS 12+.
- **~5 ГБ свободного места**: приложение ~1,5 ГБ + модель 3,2 ГБ.
- Интернет — только один раз, при первой транскрибации (скачивается модель).
- Python, Xcode, Homebrew и ffmpeg **не нужны** — всё уже внутри приложения.

## Установка

1. Скачайте `ArmenianTranscription-macOS-standalone.zip` со страницы
   [**Releases**](https://github.com/Arthuralend/ArmenianTurboTranscription/releases/latest) и распакуйте.
2. Перенесите **Armenian Transcription.app** в «Программы».
3. Приложение не подписано, поэтому при первом открытии macOS его заблокирует.
   Откройте **Системные настройки → Конфиденциальность и безопасность** и нажмите **«Всё равно открыть»**.
   Или в Терминале:
   ```bash
   xattr -dr com.apple.quarantine "/Applications/Armenian Transcription.app"
   ```
4. При первой транскрибации скачивается модель (3,2 ГБ), дальше всё работает без интернета.

<details>
<summary>Лёгкая версия (1 МБ, ставит Python сама)</summary>

[`ArmenianTranscription-macOS.zip`](ArmenianTranscription-macOS.zip) — маленький архив, который при первом запуске
сам устанавливает [uv](https://github.com/astral-sh/uv), Python 3.12 и библиотеки (~1,5 ГБ, несколько минут).
</details>

## Использование

Нажмите **«Выбрать файл…»** и выберите одну или несколько записей
(mp3, m4a, wav, ogg, opus, flac, aac, mp4, mov, webm).
Текст появится в окне и сохранится рядом с файлом как `.txt`.

Из терминала:

```bash
zsh run.command запись.m4a другая.mp3
```

## Сборка из исходников

Автономная версия собирается автоматически в GitHub Actions при создании тега `v*`
(`.github/workflows/build-macos.yml`). Локально:

```bash
zsh build_standalone.sh   # автономное .app (нужен Python 3.12 с python.org)
zsh build_app.sh          # лёгкая версия
```

## Файлы

| Файл | Назначение |
|---|---|
| `transcribe.py` | программа (окно на Tkinter + режим командной строки) |
| `run.command` | запуск без сборки .app |
| `build_standalone.sh` | сборка автономного .app (PyInstaller) |
| `build_app.sh` | сборка лёгкой версии |
| `icon.png`, `assets/icon-1024.png` | иконка окна и приложения |

Журнал приложения: `~/Library/Logs/ArmenianTranscription.log`.

## Модель

Лицензия модели — Apache 2.0 (автор ditord).
