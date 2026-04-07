# Curved HUD Assets

`EZOhud` ya usa una arquitectura basada en `CT_TEXTURE` y recorte UV para las
barras curvas, similar al enfoque observado en `BanditsUserInterface`.

## Assets previstos

- `cone_atlas.dds`
- `arc_atlas.dds`

## Requisitos del atlas

- Un solo atlas por estilo.
- Regiones diferenciadas para:
  - salud centro
  - estamina izquierda
  - magia derecha
- Capas separables para:
  - fondo
  - relleno principal
  - brillo u overlay opcional

## Integracion tecnica

Cada segmento del HUD se rellena mediante:

- `SetTextureCoords(...)`
- ajuste de `SetWidth(...)` o `SetHeight(...)`
- reposicionamiento por ancla

El overlay actual usa `EsoUI/Art/Miscellaneous/progressbar_genericfill.dds`
como placeholder tecnico para validar el flujo de recorte UV hasta que existan
los `.dds` definitivos.
