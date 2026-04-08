# Curved HUD Assets

`EZOhud` ya usa una arquitectura basada en `CT_TEXTURE` y recorte UV para las
barras curvas, similar al enfoque observado en `BanditsUserInterface`.

La especificacion completa del atlas esta en:

- [docs/curved_hud_atlas_spec.md](\\RZRNAS\Zuriplayer\Dev\EZOhud\docs\curved_hud_atlas_spec.md)
- [docs/curved_hud_atlas_template.svg](\\RZRNAS\Zuriplayer\Dev\EZOhud\docs\curved_hud_atlas_template.svg)

## Assets previstos

- `cone_atlas.dds`
- `arc_atlas.dds`
- base editable inicial:
  - [cone_atlas_concept.svg](\\RZRNAS\Zuriplayer\Dev\EZOhud\media\curved\cone_atlas_concept.svg)
- base limpia para exportacion:
  - [cone_atlas_export_base.svg](\\RZRNAS\Zuriplayer\Dev\EZOhud\media\curved\cone_atlas_export_base.svg)

## Estado actual

- El overlay usa de momento `EsoUI/Art/Miscellaneous/progressbar_genericfill.dds`
  como placeholder tecnico.
- La arquitectura runtime ya esta preparada para pasar a atlas curvo real sin
  reescribir el sistema.

## Siguiente paso

Diseñar y exportar los atlas `.dds` respetando la reticula y regiones UV
documentadas, y luego sustituir el placeholder por esos assets.

## Flujo recomendado

1. Ajustar [cone_atlas_concept.svg](\\RZRNAS\Zuriplayer\Dev\EZOhud\media\curved\cone_atlas_concept.svg)
2. Limpiar o retocar [cone_atlas_export_base.svg](\\RZRNAS\Zuriplayer\Dev\EZOhud\media\curved\cone_atlas_export_base.svg)
3. Exportar a `cone_atlas.dds`
4. Validar en juego
5. Repetir el proceso para `arc_atlas.dds`
