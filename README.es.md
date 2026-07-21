# EZOhud

¿Prefieres inglés? Lee el [README en inglés](README.md).
EZOhud es un addon beta de HUD para The Elder Scrolls Online dentro de la familia de addons EZO. Su propósito actual es ofrecer indicadores visuales configurables para recursos del jugador, disponibilidad de ultimate, oportunidades de execute, seguimiento de Crux del arcanista y pequeños ajustes de posicionamiento para elementos nativos (como el tracker de misiones, anuncios centrales, aviso de sinergia e historial de botín), manteniendo una implementación pequeña y fácil de probar.

Soporte, errores y sugerencias: <https://discord.gg/ekw8zUAcRm>

## Estado Beta

EZOhud está en calidad beta pública. El addon es utilizable para pruebas, pero el diseño, el aspecto visual, las opciones y el comportamiento de los indicadores todavía pueden cambiar. No debe considerarse un reemplazo final de suites de HUD maduras.

## Metadatos de versión

- Versión del addon: `0.1.53`
- AddOnVersion: `10053`
- APIVersion: `101049 101050`
- Estado: beta pública

## Requisitos

- The Elder Scrolls Online.
- `LibAddonMenu-2.0` es obligatorio para el panel de configuración.
- `LibChatMessage` es opcional y se usa para mensajes de chat más limpios cuando está disponible.
- `LibDebugLogger` es opcional y se usa por las opciones de debug cuando está disponible.
- `EZOCore` es opcional y proporciona el panel central `Ajustes > EZO`, la preferencia de idioma común de la familia EZO y el modo global o individual de disposición de interfaz cuando está instalado.

## Instalación

1. Descarga o clona este repositorio.
2. Coloca la carpeta `EZOhud` en el directorio de AddOns de ESO:
   `Documents/Elder Scrolls Online/live/AddOns/EZOhud`
3. Activa `EZOhud` desde la pantalla de AddOns de ESO.
4. Con EZOCore instalado, abre Ajustes > EZO > EZOhud. Sin EZOCore, usa Ajustes > Addons > EZOhud.

## Funciones Implementadas

- HUD de atributos para Salud, Magia y Estamina.
- Ocultación opcional de las barras de atributos del jugador por defecto de ESO.
- Modo de movimiento del HUD de atributos que permite mover las tres barras de recursos como un grupo.
- Ajustes de anchura de barra para Salud, Magia y Estamina.
- Selectores de color de recurso limitados a la familia de color de cada recurso.
- Umbrales de aviso por recurso que cambian solo los números del recurso a un color de alarma.
- Alpha fuera de combate para el HUD de atributos personalizado.
- Escalado de barras basado en el valor máximo de cada recurso, para que el recurso máximo dominante pueda verse más grande.
- Indicadores de HUD de ultimate para los slots de ultimate principal y secundaria.
- Modos de visualización de ultimate: principal, secundaria, ambas o solo barra no activa.
- Indicadores de ultimate movibles, con posiciones independientes para principal y secundaria.
- Ajuste de tamaño del icono de ultimate, barra de progreso, valor actual de ultimate, coste, estado de lista y estado de barra activa.
- HUD de execute que analiza las habilidades de execute equipadas en la barra activa y muestra un aviso cuando el objetivo actual está dentro del umbral detectado.
- Umbrales de execute para habilidades conocidas, con detección adicional basada en el tooltip cuando está disponible.
- Aviso de execute movible y ajuste de tamaño del aviso.
- HUD de Crux del arcanista con contador de stacks, barra de duración restante, texto de tiempo, ajuste de tamaño y ajuste de separación de barra.
- Visibilidad del HUD de Crux limitada a personajes arcanistas.
- Opción para ocultar el HUD de Crux cuando no hay stacks activos.
- Posicionamiento experimental de elementos nativos como el tracker de misiones, anuncios centrales, aviso de sinergia e historial de botín, con controles para activar, ajustar desplazamiento X/Y, escala y restablecer.
- Gestión de visibilidad por escenas HUD para que los controles visuales estén pensados para el HUD normal y HUD UI, no para menús.
- Localización en inglés y español con selección de idioma compartido de EZOCore, Automático, Inglés y Español.
- Opciones de debug en una sección de configuración separada, con salida opcional a LibDebugLogger y salida opcional a chat.
- Comando local `/ezohudcrux` para diagnóstico puntual de Crux.
- Restablecimiento de ajustes mediante el mecanismo de valores por defecto de LibAddonMenu.
- Integración nativa en `Ajustes > EZO` mediante EZOCore, conservando el panel estándar de LibAddonMenu como fallback independiente.

## Opciones Principales

EZOhud sigue el estilo de configuración de la familia EZO: cada sección de ajustes usa un icono informativo morado de 26 px en su cabecera. Pasa el cursor sobre la cabecera para ver el propósito y alcance general de la sección, y sobre cada campo individual para ver la ayuda específica de ese ajuste.

Cuando EZOCore está activo, el panel completo se dibuja dentro de `Ajustes > EZO` y no se duplica en la lista estándar de ajustes de Addons. Las superficies de Atributos, Ultimate, Execute y Crux se registran por separado en el modo compartido de disposición de interfaz. Sin EZOCore, las mismas opciones y controles locales temporales de movimiento siguen disponibles mediante el panel normal de LibAddonMenu. La prueba del tracker nativo de misiones solo se controla desde ajustes y no es una superficie del modo compartido de disposición.

- General: heredar el idioma compartido de EZOCore o seleccionar Automático, Inglés o Español localmente.
- HUD de atributos: activar barras personalizadas, ocultar barras vanilla, habilitar movimiento del HUD, alpha fuera de combate, y tamaño, color y umbral de aviso por recurso.
- HUD de ultimate: activar indicadores, habilitar movimiento, elegir los slots visibles y definir el tamaño del icono.
- HUD de execute: activar aviso, habilitar movimiento y definir el tamaño del aviso.
- HUD de Crux: activar indicador, habilitar movimiento, ocultar sin Crux, definir tamaño del indicador y ajustar la separación de la barra.
- Ajustes de Interfaz Nativa: activar el reposicionamiento de elementos nativos de ESO (tracker de misiones, anuncios centrales, sinergia e historial de botín). Ajustar desplazamientos X/Y, cambiar la escala y restablecer los valores.
- Debug: activar registro de debug y, opcionalmente, reflejar la salida de debug en el chat.

## Límites de Seguridad

- EZOhud es únicamente visual.
- No lanza habilidades, no pulsa teclas, no automatiza rotaciones, no bloquea, no esquiva, no interrumpe, no selecciona objetivos ni toma decisiones de juego.
- Los indicadores de execute, ultimate, recursos y Crux son solo informativos.
- Los ajustes de interfaz nativa solo reanclan y escalan los elementos nativos de ESO; no los reemplazan ni alteran su comportamiento principal.
- Los modos de movimiento son ayudas temporales de posicionamiento de UI y se reinician con `/reloadui` o al salir; las posiciones guardadas del HUD permanecen.
- EZOhud no añade atajos de teclado ni gestión de input y está pensado para mantener compatibilidad con juego en teclado y gamepad.
- Las herramientas de debug son solo diagnósticas y deberían permanecer desactivadas durante el juego normal salvo que se esté investigando un problema.

## Notas de Prueba

Comprobaciones recomendadas para la beta:

- Probar en personajes arcanistas y no arcanistas para confirmar que la visibilidad del HUD de Crux es correcta.
- Probar HUD normal, HUD UI, menús, puntos de campeón, Tales of Tribute y otras escenas que no sean HUD.
- Probar el comportamiento en combate y el alpha fuera de combate.
- Probar la ocultación de las barras de atributos de EZOhud independientemente de la ocultación de las barras vanilla de ESO.
- Probar cada modo de visualización de ultimate y el estado de barra activa/inactiva.
- Probar el aviso de execute con habilidades de execute conocidas en la barra activa.
- Probar los modos de idioma compartido de EZOCore, Inglés, Español y Automático.
- Probar la ruta `Ajustes > EZO` con EZOCore y el fallback estándar de Addons sin él.
- Probar distintas resoluciones y valores de escala de UI.
- Probar `/reloadui` después de mover elementos del HUD.
- Probar el posicionamiento de los elementos nativos con UI de teclado y gamepad para todos los elementos personalizados.

Al informar de problemas de diseño o comportamiento, incluye la versión del addon, versión de API de ESO, clase del personaje, modo de idioma, ajustes activos y una captura de pantalla.

## Notas del Repositorio

- `AGENTS.md` se ignora intencionadamente y se mantiene local para instrucciones de agentes de desarrollo.
- Esta preparación del repositorio no genera ZIP, artefacto de release ni anuncio en Discord.

## Licencia

EZOhud se publica bajo la [licencia MIT](LICENSE).
