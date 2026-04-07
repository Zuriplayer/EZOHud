# EZOhud

Addon de Elder Scrolls Online para experimentar y desarrollar componentes de HUD
dentro de la familia EZO.

## Objetivo

- Prototipar elementos de HUD reutilizables.
- Mantener una base limpia para iterar rapido.
- Facilitar una posible integracion futura en `EZOTools`.
- Seguir la arquitectura base de `EZOTools` como addon EZO de referencia.

## Estructura

- `EZOhud.txt`: manifiesto del addon.
- `EZOhud.lua`: arranque y registro del ciclo de carga.
- `modules/i18n.lua`: aplicacion de cadenas localizadas al estilo de `EZOTools`.
- `modules/`: logica modular del addon.
- `lang/`: textos localizados.

## Desarrollo local

El addon esta pensado para cargarse en ESO mediante un symlink desde:

`C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns\EZOhud`
