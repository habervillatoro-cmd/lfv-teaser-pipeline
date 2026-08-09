#!/usr/bin/env python3
"""
Genera candidatos de masterframes LFV con Gemini API.

Uso local:
    python scripts/generate_image_gemini.py --shot P04 --variants 2

En GitHub Actions:
    se ejecuta desde .github/workflows/generate_lfv_image.yml

Requiere:
    GEMINI_API_KEY como variable de entorno.
"""

from __future__ import annotations

import argparse
import base64
import datetime as dt
import mimetypes
import os
from pathlib import Path
from typing import List, Dict, Any

from google import genai

ROOT = Path(__file__).resolve().parents[1]

SHOT_PROMPTS = {
    "P04": ROOT / "prompts" / "p04_yaya_prompt.md",
    "P05": ROOT / "prompts" / "p05_gael_prompt.md",
}

CANON_FILES = [
    ROOT / "canon" / "visual_continuity_rules.md",
    ROOT / "canon" / "yaya_canon_visual_bloqueado.md",
    ROOT / "canon" / "gael_canon_visual_bloqueado.md",
]

REFERENCE_FILES = [
    ROOT / "refs" / "LFV_P01_MASTERFRAME_v001_20260808.png",
    ROOT / "refs" / "LFV_P02_MASTERFRAME_v001_20260808.png",
    ROOT / "refs" / "LFV_P03_MASTERFRAME_v001_20260808.png",
]

def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8").strip() if path.exists() else ""

def image_block(path: Path) -> Dict[str, Any]:
    mime_type = mimetypes.guess_type(str(path))[0] or "image/png"
    data = base64.b64encode(path.read_bytes()).decode("utf-8")
    return {"type": "image", "data": data, "mime_type": mime_type}

def build_prompt(shot: str, variant: int) -> str:
    shot_prompt = read_text(SHOT_PROMPTS[shot])
    canon = "\n\n".join(read_text(path) for path in CANON_FILES if path.exists())
    return f"""
PROYECTO: LA ÚLTIMA FRONTERA VIEJA
TAREA: Generar candidato visual para {shot}
VARIANTE: {variant}

REGLA DE PRODUCCIÓN:
Esta imagen es un candidato, no una aprobación final. Priorizar continuidad de personaje, edad, actuación y mundo visual por encima de belleza superficial.

CANON Y REGLAS:
{canon}

PROMPT DEL PLANO:
{shot_prompt}

CONTROL DE CALIDAD:
- Formato 16:9.
- Sin texto dentro de la imagen.
- Sin infografía.
- Sin estética publicitaria.
- Sin neón azul genérico.
- Si hay conflicto entre belleza y continuidad, gana continuidad.
""".strip()

def extract_image_bytes(interaction: Any) -> bytes:
    output_image = getattr(interaction, "output_image", None)
    if output_image is not None and getattr(output_image, "data", None):
        return base64.b64decode(output_image.data)
    for step in getattr(interaction, "steps", []) or []:
        if getattr(step, "type", None) == "model_output":
            for block in getattr(step, "content", []) or []:
                if getattr(block, "type", None) == "image" and getattr(block, "data", None):
                    return base64.b64decode(block.data)
    raise RuntimeError("No se encontró imagen en la respuesta de Gemini.")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--shot", required=True, choices=sorted(SHOT_PROMPTS.keys()))
    parser.add_argument("--variants", type=int, default=2)
    parser.add_argument("--model", default="gemini-3.1-flash-image")
    parser.add_argument("--image-size", default="1K", choices=["512", "1K", "2K", "4K"])
    args = parser.parse_args()

    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        raise RuntimeError("Falta GEMINI_API_KEY en variables de entorno o GitHub Secrets.")

    client = genai.Client(api_key=api_key)
    refs = [p for p in REFERENCE_FILES if p.exists()]
    if refs:
        print("Referencias encontradas:")
        for ref in refs:
            print(f" - {ref}")
    else:
        print("ADVERTENCIA: No hay imágenes en refs/. Se generará solo con canon textual.")

    timestamp = dt.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    out_dir = ROOT / "outputs" / args.shot
    out_dir.mkdir(parents=True, exist_ok=True)

    for variant in range(1, args.variants + 1):
        prompt = build_prompt(args.shot, variant)
        input_payload: List[Dict[str, Any]] = [image_block(ref) for ref in refs]
        input_payload.append({"type": "text", "text": prompt})

        interaction = client.interactions.create(
            model=args.model,
            input=input_payload,
            response_format={
                "type": "image",
                "mime_type": "image/png",
                "aspect_ratio": "16:9",
                "image_size": args.image_size,
            },
        )

        image_bytes = extract_image_bytes(interaction)
        out_path = out_dir / f"LFV_{args.shot}_candidate_v{variant:02d}_{timestamp}.png"
        out_path.write_bytes(image_bytes)
        prompt_path = out_dir / f"LFV_{args.shot}_candidate_v{variant:02d}_{timestamp}_prompt.txt"
        prompt_path.write_text(prompt, encoding="utf-8")
        print(f"Generado: {out_path}")

if __name__ == "__main__":
    main()
