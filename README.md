<p align="center"><img src="assets/icon-1024.png" width="160" alt="Խ"></p>

# Armenian Turbo Transcription

Простая программа для macOS: превращает армянскую речь из аудио- и видеофайлов в текст.
Работает локально на вашем Mac, использует модель
[ditord/whisper-large-v3-turbo-armenian](https://huggingface.co/ditord/whisper-large-v3-turbo-armenian) —
Whisper Large V3 Turbo, дообученный на армянском (WER 15,3 %, CER 2,9 % на Common Voice 20).

## Требования

- Mac на Apple Silicon (M1 и новее), macOS 12+. На Intel тоже запустится, но медленно (на CPU).
- **~6 ГБ свободного места**: модель 3,2 ГБ + Python и PyTorch ~1,5 ГБ.
- Интернет при первом запуске.
- Xcode, Homebrew и ffmpeg **не нужны**.

## Установка

1. Скачайте [`ArmenianTranscription-macOS.zip`](ArmenianTranscription-macOS.zip) и распакуйте.
2. Перенесите **Armenian Transcription.app** в «Программы».
3. Приложение не подписано, поэтому при первом открытии macOS его заблокирует.
   Откройте **Системные настройки → Конфиденциальность и безопасность** и нажмите **«Всё равно открыть»**.
   Или в Терминале:
   ```bash
   xattr -dr com.apple.quarantine "/Applications/Armenian Transcription.app"
   ```
4. Первый запуск длится несколько минут: устанавливаются [uv](https://github.com/astral-sh/uv), Python 3.12 и библиотеки.
   Модель (3,2 ГБ) скачивается при первой транскрибации.

## Использование

Нажмите **«Выбрать файл…»** и выберите одну или несколько записей
(mp3, m4a, wav, ogg, opus, flac, aac, mp4, mov, webm).
Текст появится в окне и сохранится рядом с файлом как `.txt`.

Из терминала:

```bash
zsh run.command запись.m4a другая.mp3
```

## Сборка из исходников

```bash
zsh build_app.sh
```

Скрипт собирает `Armenian Transcription.app` и zip-архив, используя только штатные утилиты macOS.

## Файлы

| Файл | Назначение |
|---|---|
| `transcribe.py` | программа (окно на Tkinter + режим командной строки) |
| `run.command` | запуск без сборки .app |
| `build_app.sh` | сборка .app и zip |
| `icon.png`, `assets/icon-1024.png` | иконка окна и приложения |

Журнал приложения: `~/Library/Logs/ArmenianTranscription.log`.

## Модель

Лицензия модели — Apache 2.0 (автор ditord).
