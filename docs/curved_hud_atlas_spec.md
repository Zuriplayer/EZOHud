# EZOhud Curved HUD Atlas Spec

## Objetivo

Definir un atlas propio para `EZOhud` que permita representar las barras de:

- salud centrada
- estamina a la izquierda
- magia a la derecha

sin ocupar el centro exacto de la pantalla y manteniendo una silueta unica de
HUD.

## Filosofia visual

- La salud es el ancla central.
- Estamina y magia son alas laterales del mismo sistema.
- La forma debe dejar libre el nucleo del reticulo.
- La franja inferior queda reservada para la barra de habilidades vanilla.

## Entrega de assets

Se preveen dos atlas:

- `media/curved/cone_atlas.dds`
- `media/curved/arc_atlas.dds`
- Guia tecnica:
  - [curved_hud_atlas_template.svg](curved_hud_atlas_template.svg)
- Concepto inicial de produccion:
  - [cone_atlas_concept.svg](../media/curved/cone_atlas_concept.svg)
- Base limpia de exportacion:
  - [cone_atlas_export_base.svg](../media/curved/cone_atlas_export_base.svg)

Resolucion recomendada inicial:

- `1024x512`

Esto deja suficiente densidad para pruebas y permite subdividir regiones sin
perder definicion.

## Plantilla visual

Existe una plantilla editable del atlas en:

- [curved_hud_atlas_template.svg](curved_hud_atlas_template.svg)

Su objetivo no es ser el arte final, sino fijar:

- reticula
- regiones UV
- jerarquia visual
- curvas guia para las alas laterales y el nucleo de salud

Existe ademas una primera base visual mas cercana a produccion en:

- [cone_atlas_concept.svg](../media/curved/cone_atlas_concept.svg)

Ese fichero ya incorpora una propuesta de:

- silueta del nucleo de salud
- alas laterales
- jerarquia de pesos visuales
- zonas de reserva para FX e iconos

Existe tambien una base mas limpia para exportacion directa:

- [cone_atlas_export_base.svg](../media/curved/cone_atlas_export_base.svg)

Ese fichero elimina etiquetas tecnicas y sirve como punto de partida mas cercano
al `.dds` final.

## Reticula del atlas

La recomendacion es dividir conceptualmente el atlas en 8 columnas x 4 filas.

Columnas UV:

- `0.000`
- `0.125`
- `0.250`
- `0.375`
- `0.500`
- `0.625`
- `0.750`
- `0.875`
- `1.000`

Filas UV:

- `0.000`
- `0.250`
- `0.500`
- `0.750`
- `1.000`

## Regiones propuestas

### Salud centro

- Fondo base:
  - `u1=0.250 u2=0.500 v1=0.000 v2=1.000`
- Relleno superior:
  - `u1=0.375 u2=0.500 v1=0.000 v2=0.500`
- Relleno inferior:
  - `u1=0.375 u2=0.500 v1=0.500 v2=1.000`

### Estamina izquierda

- Fondo principal:
  - `u1=0.000 u2=0.125 v1=0.000 v2=0.667`
- Relleno principal:
  - `u1=0.125 u2=0.250 v1=0.000 v2=0.667`
- Fondo secundario:
  - `u1=0.000 u2=0.125 v1=0.667 v2=1.000`
- Relleno secundario:
  - `u1=0.125 u2=0.250 v1=0.667 v2=1.000`

### Magia derecha

- Fondo principal:
  - `u1=0.500 u2=0.625 v1=0.000 v2=0.667`
- Relleno principal:
  - `u1=0.625 u2=0.750 v1=0.000 v2=0.667`
- Fondo secundario:
  - `u1=0.500 u2=0.625 v1=0.667 v2=1.000`
- Relleno secundario:
  - `u1=0.625 u2=0.750 v1=0.667 v2=1.000`

### Reservas adicionales

- `u1=0.750 u2=0.875 v1=0.000 v2=1.000`
  Uso previsto: brillos, overlays de impacto o acentos.
- `u1=0.875 u2=1.000 v1=0.000 v2=1.000`
  Uso previsto: iconografia auxiliar o variantes futuras.

## Direccion de llenado

Para la primera version:

- Salud: llenado vertical de abajo arriba.
- Estamina: llenado vertical de abajo arriba.
- Magia: llenado vertical de abajo arriba.

Si el arte final pide comportamiento distinto, `EZOhud` ya admite conceptualmente
direcciones `left`, `right` y `up`.

## Capas recomendadas por pieza

Cada pieza del atlas deberia prever visualmente:

- capa base oscura integrada en el propio atlas
- zona de relleno legible con borde limpio
- espacio para highlight o glow

## Restricciones de arte

- No usar brillo excesivo.
- Evitar transparencias demasiado finas que se pierdan sobre suelos claros.
- El centro de salud debe ser mas legible que las alas laterales.
- Estamina y magia deben compartir forma, diferenciandose principalmente por color.

## Integracion runtime

`EZOhud` actualiza el llenado con:

- `SetTextureCoords(...)`
- ajuste de ancho o alto del control de relleno
- anclaje por segmento

Por tanto, el atlas debe soportar recorte limpio sin depender de deformacion
dinamica compleja.

## Decision actual

La tecnica final elegida para `EZOhud` es:

- `CT_TEXTURE`
- atlas por estilo
- recorte UV
- layout parametrico desde Lua

No se usara `CT_STATUSBAR` como base del HUD final curvo.
