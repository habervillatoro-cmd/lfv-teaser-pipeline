# LFV Teaser Pipeline

Pipeline de producción controlada para generar candidatos de masterframes del teaser de **La Última Frontera Vieja** usando GitHub Actions + Gemini API.

## Estado

Este repositorio no aprueba imágenes automáticamente. Solo genera candidatos como artefactos para revisión humana.

## Regla central

Ningún personaje reconocible se considera canon hasta pasar revisión humana de Heber.

## Flujo

1. Guardar canon y prompts en este repo.
2. Ejecutar el workflow manual de GitHub Actions.
3. Descargar los artefactos generados.
4. Revisar continuidad visual.
5. Solo después de aprobación humana, subir a Drive como frame aprobado.

## Secreto requerido

Para generar imágenes, el repo necesita un secreto de GitHub Actions llamado:

```text
GEMINI_API_KEY
```

No se debe escribir la clave en archivos del repo ni en conversaciones.
