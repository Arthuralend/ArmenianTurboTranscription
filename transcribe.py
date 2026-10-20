# /// script
# requires-python = ">=3.11,<3.13"
# dependencies = [
#     "torch>=2.4",
#     "transformers>=4.45,<5",
#     "av>=12",
#     "numpy",
# ]
# ///
"""Транскрибация армянской речи моделью ditord/whisper-large-v3-turbo-armenian.

Без аргументов открывает окно; с аргументами работает из терминала:
    uv run transcribe.py запись.mp3 [ещё.m4a ...]
Текст сохраняется рядом с аудио в файл с расширением .txt.
"""

import os
import sys
import threading
from pathlib import Path

os.environ.setdefault("PYTORCH_ENABLE_MPS_FALLBACK", "1")

MODEL_ID = "ditord/whisper-large-v3-turbo-armenian"
SAMPLE_RATE = 16000
AUDIO_TYPES = "*.mp3 *.m4a *.wav *.ogg *.opus *.flac *.aac *.mp4 *.mov *.webm"

_pipe = None


def load_audio(path):
    """Декодирует любой аудио/видеофайл в моно 16 кГц float32 (ffmpeg встроен в PyAV)."""
    import av
    import numpy as np

    chunks = []
    with av.open(str(path)) as container:
        resampler = av.AudioResampler(format="flt", layout="mono", rate=SAMPLE_RATE)
        for frame in container.decode(audio=0):
            for out in resampler.resample(frame):
                chunks.append(out.to_ndarray().reshape(-1))
        for out in resampler.resample(None):
            chunks.append(out.to_ndarray().reshape(-1))
    if not chunks:
        raise ValueError("В файле нет звуковой дорожки")
    return np.concatenate(chunks).astype(np.float32)


def get_pipeline(status=print):
    global _pipe
    if _pipe is None:
        import torch
        from transformers import pipeline

        devices = [("cpu", torch.float32)]
        if torch.backends.mps.is_available() and os.environ.get("TRANSCRIBE_DEVICE") != "cpu":
            devices.insert(0, ("mps", torch.float16))
        for device, dtype in devices:
            status(f"Загрузка модели ({device})… при первом запуске скачивается ~3,2 ГБ")
            try:
                _pipe = pipeline(
                    "automatic-speech-recognition",
                    model=MODEL_ID,
                    torch_dtype=dtype,
                    device=device,
                )
                break
            except RuntimeError:  # GPU (MPS) недоступен — пробуем CPU
                if device == "cpu":
                    raise
    return _pipe


def transcribe(path, status=print):
    pipe = get_pipeline(status)
    status(f"Декодирование: {Path(path).name}")
    audio = load_audio(path)
    minutes = len(audio) / SAMPLE_RATE / 60
    status(f"Распознавание ({minutes:.1f} мин)…")
    result = pipe(
        {"raw": audio, "sampling_rate": SAMPLE_RATE},
        chunk_length_s=30,
        batch_size=2,
        generate_kwargs={"language": "hy", "task": "transcribe"},
    )
    text = result["text"].strip()
    out = Path(path).with_suffix(".txt")
    out.write_text(text + "\n", encoding="utf-8")
    return text, out


def run_cli(paths):
    for p in paths:
        text, out = transcribe(p, status=lambda s: print(s, file=sys.stderr))
        print(text)
        print(f"→ сохранено: {out}", file=sys.stderr)


def run_gui():
    import tkinter as tk
    from tkinter import filedialog, messagebox, scrolledtext

    root = tk.Tk()
    root.title("Армянская транскрибация")
    root.geometry("720x520")
    icon = Path(__file__).with_name("icon.png")
    if icon.exists():
        root.iconphoto(True, tk.PhotoImage(file=str(icon)))

    top = tk.Frame(root)
    top.pack(fill="x", padx=12, pady=10)
    status_var = tk.StringVar(value="Выберите аудио- или видеофайл")
    text_box = scrolledtext.ScrolledText(root, wrap="word", font=("Helvetica", 15))
    text_box.pack(fill="both", expand=True, padx=12, pady=(0, 6))
    tk.Label(root, textvariable=status_var, anchor="w").pack(fill="x", padx=12, pady=(0, 10))

    def set_status(s):
        root.after(0, status_var.set, s)

    def worker(paths):
        try:
            for p in paths:
                text, out = transcribe(p, status=set_status)
                root.after(0, show_result, p, text)
                set_status(f"Готово. Сохранено: {out}")
        except Exception as e:
            set_status("Ошибка")
            root.after(0, messagebox.showerror, "Ошибка", str(e))
        finally:
            root.after(0, lambda: open_btn.config(state="normal"))

    def show_result(path, text):
        if len(text_box.get("1.0", "end").strip()):
            text_box.insert("end", "\n\n")
        text_box.insert("end", f"— {Path(path).name} —\n{text}")
        text_box.see("end")

    def choose():
        paths = filedialog.askopenfilenames(
            title="Аудиофайлы", filetypes=[("Аудио и видео", AUDIO_TYPES), ("Все файлы", "*")]
        )
        if paths:
            open_btn.config(state="disabled")
            threading.Thread(target=worker, args=(paths,), daemon=True).start()

    def copy_all():
        root.clipboard_clear()
        root.clipboard_append(text_box.get("1.0", "end").strip())
        status_var.set("Текст скопирован")

    open_btn = tk.Button(top, text="Выбрать файл…", command=choose)
    open_btn.pack(side="left")
    tk.Button(top, text="Копировать текст", command=copy_all).pack(side="left", padx=8)
    tk.Button(top, text="Очистить", command=lambda: text_box.delete("1.0", "end")).pack(side="left")

    root.mainloop()


if __name__ == "__main__":
    if sys.argv[1:] == ["--check"]:
        import av, torch, transformers  # noqa: F401  проверка, что зависимости установлены
        print("OK", torch.__version__, transformers.__version__)
    elif len(sys.argv) > 1:
        run_cli(sys.argv[1:])
    else:
        run_gui()
