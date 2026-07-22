# EZOhud

¿Prefieres inglés? Lee el [README en inglés](README.md).
EZOhud es un addon beta de HUD para The Elder Scrolls Online dentro de la familia de addons EZO. Su propósito actual es ofrecer indicadores visuales configurables para recursos del jugador, disponibilidad de ultimate, oportunidades de execute, seguimiento de Crux del arcanista, pequeños ajustes de posicionamiento para elementos nativos, tracker de misiones personalizado, sinergia personalizada, estado personalizado de búsqueda de grupo e historial de botín personalizado, manteniendo una implementación pequeña y fácil de probar.

Soporte, errores y sugerencias: <https://discord.gg/ekw8zUAcRm>

## Estado Beta

EZOhud está en calidad beta pública. El addon es utilizable para pruebas, pero el diseño, el aspecto visual, las opciones y el comportamiento de los indicadores todavía pueden cambiar. No debe considerarse un reemplazo final de suites de HUD maduras.

## Metadatos de versión

- Versión del addon: `0.1.104`
- AddOnVersion: `10104`
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
- Ocultación automática de las barras de atributos del jugador por defecto de ESO al activar el HUD de atributos personalizado, manteniendo disponible el ajuste manual.
- Modo de movimiento del HUD de atributos que permite mover las tres barras de recursos como un grupo.
- Selector de modelo del HUD de atributos con el diseño clásico dividido y una pila vertical más compacta alineada a la izquierda para Salud, Estamina y Magia.
- Ajustes de anchura de barra para Salud, Magia y Estamina.
- Selectores de color de recurso limitados a la familia de color de cada recurso.
- Umbrales de aviso por recurso que cambian los números del recurso y el fondo consumido a un tinte de alarma suave.
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
- Posicionamiento experimental de elementos nativos como anuncios centrales y consejos de combate activos con controles para aplicar posición, mostrar un tirador cada vez, ajustar desplazamiento X/Y, escala y restablecer.
- Tracker de Misiones Personalizado que puede ocultar el tracker nativo de misión enfocada de ESO en el HUD y mostrar un panel movible y escalable con estilo nativo, misión enfocada, objetivo actual, pistas opcionales, el keybind nativo de cambiar misión y un tooltip con el detalle completo de la misión al pasar el ratón.
- Interfaz de Sinergia Personalizada que oculta el aviso de sinergia nativo de ESO y usa una capa movible independiente.
- Etiqueta de Búsqueda de Grupo Personalizada que oculta el tracker nativo en pantalla del Buscador de actividades de ESO, mantiene categoría/estado compactos con estilo nativo y añade líneas menores alineadas a la izquierda para destino y duración de búsqueda/sigla de rol.
- Historial de Botín Personalizado que reemplaza por completo el sistema nativo del juego con un panel moderno alineado a la derecha, con memoria, revisión al pasar el ratón por la parte inferior, desplazamiento y tiempo de desvanecimiento ajustable.
- Gestión de visibilidad por escenas HUD para que los controles visuales estén pensados para el HUD normal y HUD UI, no para menús.
- Las ventanas de Historial de Botín personalizado, Tracker de Misiones personalizado, Búsqueda de Grupo personalizada y Sinergia personalizada quedan restringidas a escenas HUD para que los paneles nativos de menú sigan siendo accesibles.
- Localización en inglés y español con selección de idioma compartido de EZOCore, Automático, Inglés y Español.
- Opciones de debug en una sección de configuración separada, con salida opcional a LibDebugLogger y salida opcional a chat.
- Comando local `/ezohudcrux` para diagnóstico puntual de Crux.
- Restablecimiento de ajustes mediante el mecanismo de valores por defecto de LibAddonMenu.
- Integración nativa en `Ajustes > EZO` mediante EZOCore, conservando el panel estándar de LibAddonMenu como fallback independiente.

## Opciones Principales

EZOhud sigue el estilo de configuración de la familia EZO: cada sección de ajustes usa un icono informativo morado de 26 px en su cabecera. Pasa el cursor sobre la cabecera para ver el propósito y alcance general de la sección, y sobre cada campo individual para ver la ayuda específica de ese ajuste.

Cuando EZOCore está activo, el panel completo se dibuja dentro de `Ajustes > EZO` y no se duplica en la lista estándar de ajustes de Addons. Las superficies de Atributos, Ultimate, Execute, Crux, Tracker de Misiones personalizado, Sinergia personalizada, Búsqueda de Grupo personalizada e Historial de Botín personalizado se registran por separado en el modo compartido de disposición de interfaz. Sin EZOCore, las mismas opciones y controles locales temporales de movimiento siguen disponibles mediante el panel normal de LibAddonMenu. Los Ajustes de Interfaz Nativa solo se controlan desde ajustes y no son superficies del modo compartido de disposición.

Con EZOCore activo, EZOhud sigue la política familiar de guardado de preferencias EZO: los ajustes ordinarios del HUD usan el alcance seleccionado por cuenta o por personaje. Cuando el alcance es por personaje, la primera carga copia los ajustes existentes de cuenta de EZOhud al perfil de ese personaje. Sin EZOCore, EZOhud conserva su guardado histórico por cuenta.

- General: heredar el idioma compartido de EZOCore o seleccionar Automático, Inglés o Español localmente.
- HUD de atributos: activar barras personalizadas, ocultar automáticamente las barras vanilla al activar el HUD, elegir el modelo de barras, habilitar movimiento del HUD, definir alpha fuera de combate y ajustar tamaño, color y umbral de aviso por recurso.
- HUD de ultimate: activar indicadores, habilitar movimiento, elegir los slots visibles y definir el tamaño del icono.
- HUD de execute: activar aviso, habilitar movimiento y definir el tamaño del aviso.
- HUD de Crux: activar indicador, habilitar movimiento, ocultar sin Crux, definir tamaño del indicador y ajustar la separación de la barra.
- Ajustes de Interfaz Nativa: aplicar posicionamiento personalizado para anuncios centrales y consejos de combate activos nativos de ESO. Ajustar desplazamientos X/Y, cambiar la escala, mostrar un solo tirador verde cada vez y restablecer los valores. Al desactivar un ajuste de posición personalizada se restaura el anclaje nativo original de ese elemento durante la sesión.
- Tracker de Misiones Personalizado: activar el panel personalizado de misión enfocada, habilitar movimiento, ajustar escala y elegir si se muestran pistas opcionales. El panel refleja la misión enfocada de ESO, muestra un tooltip con el detalle completo de la misión al pasar el ratón y deja el cambio de misión por teclado/mando en el binding nativo `ASSIST_NEXT_TRACKED_QUEST`.
- Sinergia Personalizada: activar el aviso de sinergia personalizado, habilitar movimiento y ajustar la escala.
- Búsqueda de Grupo Personalizada: activar la etiqueta personalizada de estado del Buscador de actividades, habilitar movimiento y ajustar la escala. La etiqueta reemplaza solo el pequeño tracker de estado del HUD, no la ventana completa del buscador, y muestra una línea alineada a la izquierda con el destino y otra con duración de búsqueda y rol `DD`/`T`/`H` bajo las líneas con estilo nativo.
- Historial de Botín Personalizado: activar el panel de botín, habilitar movimiento y ajustar la escala y el tiempo que los objetos permanecen visibles antes de desvanecerse.
- Debug: activar registro de debug y, opcionalmente, reflejar la salida de debug en el chat.

## Límites de Seguridad

- EZOhud es únicamente visual.
- No lanza habilidades, no pulsa teclas, no automatiza rotaciones, no bloquea, no esquiva, no interrumpe, no selecciona objetivos ni toma decisiones de juego.
- Los indicadores de execute, ultimate, recursos y Crux son solo informativos.
- Los ajustes de interfaz nativa solo reanclan y escalan los elementos nativos de ESO; no los reemplazan ni alteran su comportamiento principal.
- El Tracker de Misiones Personalizado es solo informativo. Puede ocultar el tracker nativo de misión enfocada mientras está activado y mostrar detalles estilo diario en un tooltip al pasar el ratón, pero no añade atajos, abandona, comparte, selecciona, cambia ni automatiza acciones de misión; el keybind nativo de cambiar misión de ESO sigue siendo responsable de cambiar la misión enfocada.
- La Búsqueda de Grupo Personalizada es solo informativa. Puede ocultar el tracker nativo en pantalla del Buscador de actividades mientras está activada, pero no pone en cola, abandona, acepta, rechaza ni automatiza acciones del buscador de grupo.
- Las superficies de Historial de Botín personalizado, Tracker de Misiones personalizado, Búsqueda de Grupo personalizada y Sinergia personalizada se ocultan fuera de las escenas HUD normales, y el Historial de Botín personalizado solo captura el mouse mientras su modo de movimiento está activo.
- Los modos de movimiento son ayudas temporales de posicionamiento de UI y se reinician con `/reloadui` o al salir; las posiciones guardadas del HUD permanecen.
- EZOhud no añade atajos de teclado ni gestión de input y está pensado para mantener compatibilidad con juego en teclado y gamepad.
- Las herramientas de debug son solo diagnósticas y deberían permanecer desactivadas durante el juego normal salvo que se esté investigando un problema.

## Notas de Prueba

Comprobaciones recomendadas para la beta:

- Probar en personajes arcanistas y no arcanistas para confirmar que la visibilidad del HUD de Crux es correcta.
- Probar HUD normal, HUD UI, menús, puntos de campeón, Tales of Tribute y otras escenas que no sean HUD.
- Probar paneles nativos de configuración como Habilidades y Ajustes con el Historial de Botín personalizado activado para confirmar que los paneles del HUD no los bloquean.
- Probar Tracker de Misiones Personalizado con varias misiones rastreadas, `T` / cambiar misión en teclado y el botón equivalente de mando para confirmar que el panel personalizado sigue la misión enfocada nativa sin romper el cambio. Pasar el ratón sobre el panel personalizado en HUD UI para confirmar que el tooltip muestra título, metadatos de nivel/repetible cuando estén disponibles, texto de misión y tareas actuales.
- Probar Búsqueda de Grupo Personalizada mientras estás en cola para una mazmorra u otra actividad del Buscador de actividades, durante ready check y al completarse la cola para confirmar que el tracker nativo se oculta, el texto de categoría/estado con estilo nativo se actualiza, aparecen las líneas alineadas a la izquierda de destino y duración/rol, la etiqueta se puede arrastrar en modo movimiento y desaparece fuera de escenas HUD.
- Probar el comportamiento en combate y el alpha fuera de combate.
- Probar que al activar el HUD de atributos de EZOhud se ocultan automáticamente las barras vanilla de ESO, y que el ajuste manual de barras vanilla sigue aplicándose después.
- Probar cada modo de visualización de ultimate y el estado de barra activa/inactiva.
- Probar el aviso de execute con habilidades de execute conocidas en la barra activa.
- Probar los modos de idioma compartido de EZOCore, Inglés, Español y Automático.
- Probar la ruta `Ajustes > EZO` con EZOCore y el fallback estándar de Addons sin él.
- Probar distintas resoluciones y valores de escala de UI.
- Probar `/reloadui` después de mover elementos del HUD.
- Probar el posicionamiento de elementos nativos con UI de teclado y gamepad para anuncios centrales y consejos de combate activos.

Al informar de problemas de diseño o comportamiento, incluye la versión del addon, versión de API de ESO, clase del personaje, modo de idioma, ajustes activos y una captura de pantalla.

## Notas del Repositorio

- `AGENTS.md` se ignora intencionadamente y se mantiene local para instrucciones de agentes de desarrollo.
- Esta preparación del repositorio no genera ZIP, artefacto de release ni anuncio en Discord.

## Licencia

EZOhud se publica bajo la [licencia MIT](LICENSE).
