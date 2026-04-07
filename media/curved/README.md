# Curved HUD Assets

`EZOhud` ya usa una arquitectura basada en `CT_TEXTURE` y recorte UV para las
barras curvas, similar al enfoque observado en `BanditsUserInterface`.

La especificacion completa del atlas esta en:

- [docs/curved_hud_atlas_spec.md](\\RZRNAS\Zuriplayer\Dev\EZOhud\docs\curved_hud_atlas_spec.md)
- [docs/curved_hud_atlas_template.svg](\\RZRNAS\Zuriplayer\Dev\EZOhud\docs\curved_hud_atlas_template.svg)

## Assets previstos

- `cone_atlas.dds`
- `arc_atlas.dds`

## Estado actual

- El overlay usa de momento `EsoUI/Art/Miscellaneous/progressbar_genericfill.dds`
  como placeholder tecnico.
- La arquitectura runtime ya esta preparada para pasar a atlas curvo real sin
  reescribir el sistema.

## Siguiente paso

Diseñar y exportar los atlas `.dds` respetando la reticula y regiones UV
documentadas, y luego sustituir el placeholder por esos assets.
