# EZOhud

¿Prefieres inglés? Lee el [README en inglés](README.md).
EZOhud es un addon beta de HUD para The Elder Scrolls Online dentro de la familia de addons EZO. Su propósito actual es ofrecer indicadores visuales configurables para recursos del jugador, disponibilidad de ultimate, barras de habilidades personalizadas, oportunidades de execute, seguimiento de Crux del arcanista, pequeños ajustes de posicionamiento para elementos nativos, tracker de misiones personalizado, sinergia personalizada, estado personalizado de búsqueda de grupo e historial de botín personalizado, manteniendo una implementación pequeña y fácil de probar.

Soporte, errores y sugerencias: <https://discord.gg/ekw8zUAcRm>

## Estado Beta

EZOhud está en calidad beta pública. El addon es utilizable para pruebas, pero el diseño, el aspecto visual, las opciones y el comportamiento de los indicadores todavía pueden cambiar. No debe considerarse un reemplazo final de suites de HUD maduras.

## Metadatos de versión

- Versión del addon: `0.1.146`
- AddOnVersion: `10146`
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
- Ajustes de anchura de barra para Salud, Magia y Estamina, con tamaño máximo de 750.
- Bloqueo opcional de tamaño común para ambos modelos del HUD de atributos. Da a las tres barras exactamente la misma anchura máxima independientemente de los máximos de recurso y cambiar cualquier deslizador de Tamaño actualiza inmediatamente los otros dos.
- Selectores de color de recurso limitados a la familia de color de cada recurso.
- Umbrales de aviso por recurso que cambian los números del recurso y el fondo consumido a un tinte de alarma suave.
- Alpha fuera de combate para el HUD de atributos personalizado.
- Escalado de barras basado en el valor máximo de cada recurso, para que el recurso máximo dominante pueda verse más grande cuando el bloqueo de tamaño común está desactivado.
- Indicadores de HUD de ultimate para los slots de ultimate principal y secundaria.
- Modos de visualización de ultimate: principal, secundaria, ambas o solo barra no activa.
- Indicadores de ultimate movibles, con posiciones independientes para principal y secundaria.
- Ajuste de tamaño del icono de ultimate, barra de progreso, valor actual de ultimate, coste, estado de lista y estado de barra activa.
- Barras de Habilidades Personalizadas que muestran las barras principal y secundaria como un único bloque movible de dos filas, con una opción para ocultar la barra de habilidades nativa del HUD de ESO solo mientras está activa una barra de armas principal o secundaria normal. Las barras nativas temporales o propias de mecánicas permanecen visibles.
- Modos de visualización de Barras de Habilidades Personalizadas: desactivadas, principal, secundaria, ambas o solo barra activa.
- Barras de Habilidades Personalizadas horizontales y paralelas con iconos genéricos por categoría de arma, ocultación del icono de arma inactiva, ocultación opcional de habilidades de la fila secundaria cuando esa fila no está activa y tanto su tiempo de efecto nativo como sus acumulaciones llegan a cero, animación visual al usar slots, temporizadores nativos blancos más grandes y centrados con fuente negrita y contorno grueso, acumulaciones naranjas ampliadas en la esquina superior derecha, umbral proporcional configurable de aviso, un único juego opcional y escalable de etiquetas nativas debajo de la fila visible más baja, color compartido configurable para la barra de temporizador, tamaño de iconos hasta 96 px, separación, alpha de barra no activa, alpha de slot opacado, un porcentaje de disponibilidad de ultimate más pequeño y centrado independientemente con `%` más la lectura actual/coste debajo, opacidad reducida si no está listo, un modo opcional que sustituye el icono de ultimate activo sin cargar y ambas líneas de texto por una barra morada y opciones globales guardadas para opacar arma, habilidades 1-5 y ultimate. La fila principal permanece siempre completa, mientras las habilidades temporizadas de la secundaria siguen visibles hasta que termina su efecto nativo.
- Icono independiente del slot rápido activo para Barras de Habilidades Personalizadas, movible por separado y escalado con el mismo ajuste de tamaño de iconos. Cuando ESO informa de cooldown del slot rápido, el icono se atenúa, se rellena verticalmente conforme termina el cooldown y muestra el tiempo restante en vez del contador de objetos hasta que vuelve a estar listo.
- HUD de execute que analiza las habilidades de execute equipadas en la barra activa y muestra un aviso cuando el objetivo actual está dentro del umbral detectado.
- Umbrales de execute para habilidades conocidas, con detección adicional basada en el tooltip cuando está disponible.
- Aviso de execute movible y ajuste de tamaño del aviso.
- HUD de Crux del arcanista con contador de stacks, barra de duración restante, texto de tiempo, tamaño por defecto de 140 px, separación de barra por defecto de 25 px, ajuste de tamaño y ajuste de separación de barra.
- Visibilidad del HUD de Crux limitada a personajes arcanistas.
- Opción para ocultar el HUD de Crux cuando no hay stacks activos.
- Posicionamiento experimental de elementos nativos para anuncios centrales, consejos de combate activos y el aviso completo de muerte y resurrección, con controles para aplicar posición, una previsualización verde temporal de tres segundos, una casilla opcional de tirador de movimiento único, desplazamiento X/Y, escala y restablecimiento. El aviso de muerte se activa por defecto sobre la posición predeterminada de las Barras de Habilidades Personalizadas.
- Tracker de Misiones Personalizado que puede ocultar el tracker nativo de misión enfocada de ESO en el HUD y mostrar un panel movible y escalable con estilo nativo, misión enfocada, objetivo actual, pistas opcionales alineadas a la derecha, ocultación opcional en combate, el keybind nativo de cambiar misión y un tooltip con el detalle completo de la misión al pasar el ratón.
- Interfaz de Sinergia Personalizada que oculta el aviso de sinergia nativo de ESO y usa una capa movible independiente.
- Etiqueta de Búsqueda de Grupo Personalizada que oculta el tracker nativo en pantalla del Buscador de actividades de ESO, mantiene categoría/estado compactos con estilo nativo y añade líneas menores alineadas a la izquierda para actividad seleccionada o instancia, duración de búsqueda y roles visibles del grupo.
- Historial de Botín Personalizado que reemplaza por completo el sistema nativo del juego con un panel moderno alineado a la derecha, con memoria, revisión al pasar el ratón por la parte inferior, desplazamiento y tiempo de desvanecimiento ajustable.
- Gestión de visibilidad por escenas HUD para que los controles visuales estén pensados para el HUD normal y HUD UI, no para menús.
- Las ventanas de Barras de Habilidades Personalizadas, Historial de Botín personalizado, Tracker de Misiones personalizado, Búsqueda de Grupo personalizada y Sinergia personalizada quedan restringidas a escenas HUD para que los paneles nativos de menú sigan siendo accesibles.
- Localización en inglés y español con selección de idioma compartido de EZOCore, Automático, Inglés y Español, incluidos textos de reserva localizados para el HUD personalizado cuando ESO no expone una cadena nativa.
- Opciones de debug en una sección de configuración separada, con salida opcional a LibDebugLogger y salida opcional a chat.
- Comando local `/ezohudcrux` para diagnóstico puntual de Crux.
- Restablecimiento de ajustes mediante el mecanismo de valores por defecto de LibAddonMenu.
- Integración nativa en `Ajustes > EZO` mediante EZOCore, conservando el panel estándar de LibAddonMenu como fallback independiente.

## Opciones Principales

EZOhud sigue el estilo de configuración de la familia EZO: cada sección de ajustes usa un icono informativo morado de 26 px en su cabecera. Pasa el cursor sobre la cabecera para ver el propósito y alcance general de la sección, y sobre cada campo individual para ver la ayuda específica de ese ajuste.

Cuando EZOCore está activo, el panel completo se dibuja dentro de `Ajustes > EZO` y no se duplica en la lista estándar de ajustes de Addons. Las superficies de Atributos, Ultimate, Barras de Habilidades Personalizadas, Execute, Crux, Tracker de Misiones personalizado, Sinergia personalizada, Búsqueda de Grupo personalizada, Historial de Botín personalizado y Ajustes de Interfaz Nativa se registran por separado en el modo compartido de disposición de interfaz. Sin EZOCore, las mismas opciones y controles locales temporales de movimiento siguen disponibles mediante el panel normal de LibAddonMenu.

Los controles maestros de activación aplazan el refresco de ajustes hasta que termina el callback actual de LAM. En el panel alojado por EZOCore esto solicita una reconstrucción forzada para que los controles dependientes recalculen inmediatamente su estado y no permanezcan visualmente en gris.

Con EZOCore activo, EZOhud sigue la política familiar de guardado de preferencias EZO: los ajustes ordinarios del HUD usan el alcance seleccionado por cuenta o por personaje. Cuando el alcance es por personaje, la primera carga copia los ajustes existentes de cuenta de EZOhud al perfil de ese personaje. Sin EZOCore, EZOhud conserva su guardado histórico por cuenta.

- General: heredar el idioma compartido de EZOCore o seleccionar Automático, Inglés o Español localmente.
- HUD de atributos: activar barras personalizadas, ocultar automáticamente las barras vanilla al activar el HUD, elegir el modelo de barras, bloquear opcionalmente las tres barras al mismo Tamaño y anchura máxima exacta, habilitar movimiento del HUD, definir alpha fuera de combate y ajustar tamaño hasta 750, color y umbral de aviso por recurso.
- HUD de ultimate: activar indicadores, habilitar movimiento, elegir los slots visibles y definir el tamaño del icono.
- Barras de Habilidades Personalizadas: activar copias visuales de las barras de habilidades, ocultar opcionalmente la barra de habilidades nativa del HUD de ESO solo para barras de armas principal/secundaria normales manteniendo visibles las barras nativas temporales o propias de mecánicas, elegir filas visibles, mover por separado el bloque unido de barras y el icono de slot rápido activo, ajustar tamaño/separación/alpha de iconos, ocultar opcionalmente las habilidades de la fila secundaria cuando esa fila no está activa y su tiempo de efecto nativo y sus acumulaciones estén a cero manteniendo completa la principal, activar temporizadores nativos más grandes con fuente negrita y contorno y acumulaciones naranjas en la esquina superior derecha, sustituir el icono y los valores de ultimate activo por una barra de carga hasta que llegue al 100%, elegir el color compartido de la barra de temporizador y el umbral proporcional de aviso, elegir etiquetas de tecla desactivadas/automáticas/teclado/mando solo debajo de la fila visible más baja y elegir slots lógicos opacados globalmente. Ultimate muestra de otro modo un porcentaje centrado con `%` y una lectura menor actual/coste debajo; el icono del slot rápido activo refleja el cooldown nativo de ESO con relleno vertical y etiqueta de tiempo restante.
- HUD de execute: activar aviso, habilitar movimiento y definir el tamaño del aviso.
- HUD de Crux: activar indicador, habilitar movimiento, ocultar sin Crux, definir tamaño del indicador y ajustar la separación de la barra.
- Ajustes de Interfaz Nativa: aplicar posicionamiento personalizado para anuncios centrales, consejos de combate activos (Liberarse, Interrumpir, Esquivar) y el aviso completo de muerte y resurrección nativos de ESO. El aviso de muerte mantiene las solicitudes de resurrección, opciones de revivir o liberar, cuentas atrás y resumen de muerte de ESO sobre la posición predeterminada de las Barras de Habilidades Personalizadas. Al aplicar o cambiar una posición se muestra su previsualización verde durante tres segundos; activa la casilla del tirador de movimiento para mantener visible un único tirador hasta desactivarlo. Los mismos modos de movimiento están disponibles mediante los controles compartidos de disposición de EZOCore. Ajustar desplazamientos X/Y, cambiar la escala y restablecer los valores. Al desactivar un ajuste de posición personalizada se restaura el anclaje nativo original de ese elemento durante la sesión.
- Tracker de Misiones Personalizado: activar el panel personalizado de misión enfocada, elegir si se oculta en combate, habilitar movimiento, ajustar escala y elegir si se muestran pistas opcionales. El panel refleja la misión enfocada de ESO, muestra las pistas como líneas separadas alineadas a la derecha, eleva el tooltip con el detalle completo de la misión por encima del tracker al pasar el ratón y deja el cambio de misión por teclado/mando en el binding nativo `ASSIST_NEXT_TRACKED_QUEST`.
- Sinergia Personalizada: activar el aviso de sinergia personalizado, habilitar movimiento y ajustar la escala.
- Búsqueda de Grupo Personalizada: activar la etiqueta personalizada de estado del Buscador de actividades, habilitar movimiento y ajustar la escala. La etiqueta reemplaza solo el pequeño tracker de estado del HUD, no la ventana completa del buscador, y muestra líneas alineadas a la izquierda con actividad seleccionada o instancia actual, duración de búsqueda y roles visibles del grupo. Mientras estás en cola etiqueta la actividad solicitada como `Selección`; solo etiqueta una actividad final/actual como `Instancia` cuando ESO expone ese id de actividad LFG, y si no lo expone mantiene la instancia pendiente en vez de reutilizar una solicitud de cola potencialmente engañosa. En búsquedas de mazmorra con roles muestra la composición visible del grupo como `T 0/1 H 1/1 DD 1/2` para que se vea qué falta sin afirmar que conoce roles ocultos del matchmaking.
- Historial de Botín Personalizado: activar el panel de botín, habilitar movimiento y ajustar la escala y el tiempo que los objetos permanecen visibles antes de desvanecerse.
- Debug: activar registro de debug y, opcionalmente, reflejar la salida de debug en el chat.

## Límites de Seguridad

- EZOhud es únicamente visual.
- No lanza habilidades, no pulsa teclas, no automatiza rotaciones, no bloquea, no esquiva, no interrumpe, no selecciona objetivos ni toma decisiones de juego.
- Los indicadores de execute, ultimate, barras de habilidades personalizadas, recursos y Crux son solo informativos.
- Los ajustes de interfaz nativa solo reanclan y escalan los elementos nativos de ESO; no los reemplazan ni alteran su comportamiento principal.
- El Tracker de Misiones Personalizado es solo informativo. Puede ocultar el tracker nativo de misión enfocada mientras está activado y mostrar detalles estilo diario en un tooltip al pasar el ratón, pero no añade atajos, abandona, comparte, selecciona, cambia ni automatiza acciones de misión; el keybind nativo de cambiar misión de ESO sigue siendo responsable de cambiar la misión enfocada.
- Las Barras de Habilidades Personalizadas son solo informativas. Cuando se solicita, pueden ocultar visualmente la barra de habilidades nativa del HUD de ESO para barras de armas principal/secundaria normales; las barras nativas temporales o propias de mecánicas permanecen visibles. No lanzan habilidades, no cambian armas, no usan objetos del slot rápido, no activan keybinds ni automatizan rotaciones. Los temporizadores de efectos, acumulaciones, visibilidad de slots secundarios, porcentaje/valores actual-coste o barra de carga de ultimate y cooldowns del slot rápido siguen únicamente los datos nativos de slot que expone ESO; los slots sin datos nativos de temporizador quedan en blanco. Las etiquetas de tecla son solo visuales y siguen los atajos actuales de ESO cuando están activadas.
- La Búsqueda de Grupo Personalizada es solo informativa. Puede ocultar el tracker nativo en pantalla del Buscador de actividades mientras está activada, pero no pone en cola, abandona, acepta, rechaza ni automatiza acciones del buscador de grupo. Los detalles de instancia y roles quedan limitados a los datos del Buscador de actividades y roles de grupo que expone la API de interfaz de ESO.
- Las superficies de Barras de Habilidades Personalizadas, Historial de Botín personalizado, Tracker de Misiones personalizado, Búsqueda de Grupo personalizada y Sinergia personalizada se ocultan fuera de las escenas HUD normales, y el Historial de Botín personalizado solo captura el mouse mientras su modo de movimiento está activo.
- Los modos de movimiento son ayudas temporales de posicionamiento de UI y se reinician con `/reloadui` o al salir; las posiciones guardadas del HUD permanecen.
- EZOhud no añade atajos de teclado ni gestión de input y está pensado para mantener compatibilidad con juego en teclado y gamepad.
- Las herramientas de debug son solo diagnósticas y deberían permanecer desactivadas durante el juego normal salvo que se esté investigando un problema.

## Notas de Prueba

Comprobaciones recomendadas para la beta:

- Probar en personajes arcanistas y no arcanistas para confirmar que la visibilidad del HUD de Crux es correcta.
- Probar HUD normal, HUD UI, menús, puntos de campeón, Tales of Tribute y otras escenas que no sean HUD.
- Probar paneles nativos de configuración como Habilidades y Ajustes con el Historial de Botín personalizado activado para confirmar que los paneles del HUD no los bloquean.
- Probar Tracker de Misiones Personalizado con varias misiones rastreadas, `T` / cambiar misión en teclado y el botón equivalente de mando para confirmar que el panel personalizado sigue la misión enfocada nativa sin romper el cambio. Pasar el ratón sobre el panel personalizado en HUD UI para confirmar que el tooltip se dibuja por encima del tracker y muestra título, metadatos de nivel/repetible cuando estén disponibles, texto de misión y tareas actuales. Confirmar que las pistas opcionales siguen alineadas a la derecha cuando se muestra una o dos líneas.
- Probar Búsqueda de Grupo Personalizada mientras estás en cola para una mazmorra u otra actividad del Buscador de actividades, durante ready check y al completarse la cola para confirmar que el tracker nativo se oculta, el texto de categoría/estado con estilo nativo se actualiza, la actividad seleccionada no se etiqueta como instancia final, la instancia final/actual aparece solo cuando ESO la expone, aparecen las líneas alineadas a la izquierda de duración y roles visibles del grupo, los conteos de roles cambian al entrar/salir miembros o cambiar roles, la etiqueta se puede arrastrar en modo movimiento y desaparece fuera de escenas HUD.
- Probar el comportamiento en combate y el alpha fuera de combate.
- Probar que al activar el HUD de atributos de EZOhud se ocultan automáticamente las barras vanilla de ESO, y que el ajuste manual de barras vanilla sigue aplicándose después.
- Probar el bloqueo de tamaño común de atributos en ambos modelos con máximos distintos de Salud, Magia y Estamina. Confirmar que las tres bases mantienen la misma anchura, que sus rellenos siguen mostrando el porcentaje de cada recurso y que cambiar cualquier deslizador de Tamaño actualiza inmediatamente los otros dos tanto en Ajustes > EZO como en el panel LAM independiente sin necesitar `/reloadui`.
- Probar cada modo de visualización de ultimate y el estado de barra activa/inactiva.
- Probar Barras de Habilidades Personalizadas con modos principal, secundaria, ambas y solo activa. Confirmar que el toggle maestro activa inmediatamente los ajustes dependientes tanto en Ajustes > EZO como en el panel LAM independiente sin dejarlos visualmente en gris; ambas filas permanecen paralelas y se mueven juntas como un bloque; los iconos de arma cambian al cambiar de arma; solo el icono de arma activa queda visible con marco violeta; el resaltado de fila activa sigue los cambios de barra; los slots usados parpadean al activarse; los slots opacados se aplican a ambas filas salvo cuando un temporizador nativo está activo; los temporizadores usan números blancos centrados más grandes, en negrita y con contorno grueso y siguen siendo legibles con el tamaño de icono predeterminado de 42 px; las acumulaciones ampliadas aparecen en naranja arriba a la derecha; activar la ocultación a cero elimina solo los slots de habilidades 1-5 de la secundaria mientras esa fila está inactiva y tanto el tiempo nativo restante como las acumulaciones están a cero, mientras la fila principal permanece siempre completa; se aplican el color compartido y el umbral de aviso; Desactivadas mantiene el diseño compacto y Automático/Teclado/Mando muestra un solo juego de etiquetas bajo la fila secundaria cuando se ven ambas, o bajo la única fila visible en los demás modos; el icono de slot rápido sigue moviéndose de forma independiente, muestra objetos cuando está listo, cambia a tiempo restante durante el cooldown de poción/bebida y se rellena verticalmente; ultimate muestra normalmente un porcentaje más pequeño, centrado independientemente, con `%`, fuente negrita y contorno y una lectura actual/coste menor debajo; al activar la opción de ultimate activo al 100% el icono activo sin cargar y ambas líneas se sustituyen por una barra morada, reaparecen al 100% y la fila inactiva no cambia; la barra nativa se oculta/restaura con su ajuste para barras principal/secundaria normales; y al entrar en una barra temporal o propia de una mecánica se restaura la barra nativa hasta volver a una barra de armas normal.
- Probar el aviso de execute con habilidades de execute conocidas en la barra activa.
- Probar los modos de idioma compartido de EZOCore, Inglés, Español y Automático.
- Probar la ruta `Ajustes > EZO` con EZOCore y el fallback estándar de Addons sin él. Cambiar cada ajuste maestro de desactivado a activado y confirmar que sus controles dependientes quedan disponibles inmediatamente sin cerrar ni reabrir el panel.
- Probar distintas resoluciones y valores de escala de UI.
- Probar `/reloadui` después de mover elementos del HUD.
- Probar el posicionamiento de elementos nativos con UI de teclado y gamepad para anuncios centrales, consejos de combate activos y el aviso completo de muerte y resurrección. Confirma que aplicar una posición muestra una previsualización verde durante unos tres segundos y que Activar tirador de movimiento y los controles compartidos de disposición de EZOCore mantienen visible solo el tirador seleccionado. Con las Barras de Habilidades Personalizadas activas, muere y acepta una solicitud de resurrección de grupo; confirma que el aviso queda sobre las barras, sus botones nativos funcionan y desactivar el posicionamiento personalizado restaura el anclaje predeterminado.

Al informar de problemas de diseño o comportamiento, incluye la versión del addon, versión de API de ESO, clase del personaje, modo de idioma, ajustes activos y una captura de pantalla.

## Notas del Repositorio

- `AGENTS.md` se ignora intencionadamente y se mantiene local para instrucciones de agentes de desarrollo.
- Esta preparación del repositorio no genera ZIP, artefacto de release ni anuncio en Discord.

## Licencia

EZOhud se publica bajo la [licencia MIT](LICENSE).
