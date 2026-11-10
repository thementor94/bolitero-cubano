# Recon Map: Boliteros - La Bolita Cubana & Loterías (`com.devlotto.boliteros`)

Scope: Reverse engineering funcional, arquitectónico y de flujos UX de la aplicación líder de pronósticos, resultados y charada de la Bolita Cubana (devlotto), para construir una alternativa moderna, offline-first, sin fricción publicitaria y de alto rendimiento.  
For: Comunidad de jugadores y aficionados de la Bolita Cubana y loterías de EE.UU. (Florida, Georgia, New York).  
Date: 2026-11-09  

---

## 1. Fuentes de Reconocimiento

| # | Fuente | URL / Identificador | Notas |
|---|---|---|---|
| 1 | Google Play Store | `https://play.google.com/store/apps/details?id=com.devlotto.boliteros` | Capturas oficiales, descripción detallada, metadatos y fichas de actualización. |
| 2 | Portal Web Oficial | `https://boliteros.com` | Feed de datos, tablas de resultados y estructura de endpoints web. |
| 3 | Repositorios & Reseñas de Usuarios | AppBrain, Uptodown, comentarios de Play Store | Registro de fallos habituales (saturación en horas pico, exceso de anuncios, lentitud sin conexión). |

---

## 2. Core Loop (Bucle Principal de Valor)

> **Consultar al instante los números ganadores de los sorteos diarios (Florida Mediodía/Noche), interpretar sueños o eventos mediante la Charada Cubana, y proyectar jugadas futuras con algoritmos tradicionales (pirámides, cruces y tablas de atrasos) con cero latencia.**

---

## 3. Inventario de Pantallas (Screen Inventory)

| ID | Pantalla | Ruta / Acceso | Propósito | Componentes Clave | Estados Observados |
|---|---|---|---|---|---|
| **S01** | **Pizarra de Resultados (Home)** | Tab 1 / Inicio | Vista principal con los últimos sorteos del día y desglose de la bolita. | Tarjetas de sorteo (Florida Día/Noche, Georgia, NY), indicador de estado (en vivo / oficial), desglose (Fijo, Centena, Corridos, Parlé). | Cargando, actualizado, sin conexión, error de feed. |
| **S02** | **Detalle e Historial de Sorteo** | Clic en tarjeta de sorteo en S01 | Ver histórico de sorteos por fecha o estado específico. | Selector de calendario, lista cronológica, filtro por turno (Mediodía/Noche/Extra). | Lleno, vacío (fecha sin sorteo), filtrado. |
| **S03** | **Diccionario de la Charada** | Tab 2 / Menú lateral | Búsqueda bidireccional entre números (1-100) y significados tradicionales / sueños. | Barra de búsqueda predictiva, switch Charada Tradicional vs. Mixta/Moderna, lista alfabética y cuadrícula numérica. | Búsqueda con resultados, sin coincidencias, modal de detalle con sinónimos. |
| **S04** | **Generador de Pirámide Numérica** | Tab Herramientas / Métodos | Cálculo de la pirámide por suma modular para Pick 3 y Pick 4. | Selector Pick 3 / Pick 4, input de fecha o número base, pirámide SVG/gráfica renderizada en niveles, botón copiar números resultantes. | Estado inicial con números del día, cálculo personalizado. |
| **S05** | **Cruz de la Suerte** | Tab Herramientas / Métodos | Cálculo astronómico-numerológico en forma de cruz basado en el día actual o fecha elegida. | Matriz gráfica en forma de cruz, selector de fecha, lista de combinaciones y pares resultantes sugeridos. | Fecha actual por defecto, cálculo manual. |
| **S06** | **Tabla de los Dioses & Atómico 49** | Tab Herramientas / Fórmulas | Mapeo de equivalencias matemáticas según el número ganador anterior. | Input de número fijo salidor (00-99), cuadrícula de acompañantes y proyecciones atómicas. | Vacío, tabla generada. |
| **S07** | **Tabla de Equivalencias y Espejos** | Tab Herramientas / Tablas | Consulta de números equivalentes (+25, -25, espejo de decenas/unidades, inverso). | Selector de número (00-99), ficha de equivalencias directas, explicación de regla. | Vista interactiva inmediata. |
| **S08** | **Buscador & Generador de Parlés** | Tab Herramientas / Parlés | Consulta de parejas que suelen salir juntas y cálculo de candados/permutaciones. | Input de dos o tres números, matriz de candados (AB, BA, BC, etc.), indicador de frecuencia histórica conjunta. | Vacío, combinaciones calculadas. |
| **S09** | **Reducciones & Filtros** | Tab Herramientas / Filtros | Filtrado matemático para achicar listas de jugadas (pares/impares, terminales, decenas). | Checkboxes de decenas (0-9), terminales (0-9), filtros par/impar, lista exportable de números válidos. | Configuración inicial, lista filtrada. |
| **S10** | **Tablero de Control de Números (Atrasos y Calientes)** | Tab Estadísticas | Análisis estadístico de frecuencia de salida en ventanas de 30, 60, 90 y 365 días. | Tabs "Más Calientes", "Más Atrasados (Fríos)", gráfica de barras de frecuencia, alertas de números críticos. | Cargando datos históricos, tabla clasificada. |
| **S11** | **Cartón de Estudio Mensual** | Tab Estadísticas / Cartón | Matriz del 00 al 99 coloreada según las veces que ha salido en el mes actual. | Cuadrícula de 10x10, mapa de calor (heat-map) de frecuencias, selector de mes/año, tap en celda para ver fechas de salida. | Heatmap interactivo del mes actual. |
| **S12** | **Mi Laboratorio (Simulador de Jugadas)** | Menú / Herramientas de usuario | Registro personal de jugadas ficticias para evaluar efectividad y racha sin apostar. | Formulario de agregar jugada (número, tipo, fecha, monto virtual), lista de jugadas activas, balance de ROI virtual. | Vacío con onboarding, lista con historial de aciertos/fallos. |
| **S13** | **Encuestas Comunitarias y Pronósticos** | Tab Social / Comunidad | Votación anónima diaria del número favorito y visualización del leaderboard. | Barra de progreso de porcentajes de votos, formulario de voto de 1 clic, ranking de los mejores pronosticadores. | Voto pendiente, voto emitido con resultados en tiempo real. |
| **S14** | **Horóscopo & Números del Zodíaco** | Menú / Entretenimiento | Predicciones diarias por signo zodiacal y números de la suerte asociados. | Selector de los 12 signos zodiacales, tarjeta de predicción, números de la suerte destacados con enlace a la charada. | Actualización diaria. |

---

## 4. Flujos Clave de Usuario (User Flows)

### F01: Consulta rápida de resultados de la tarde
- **Flujo:** Abre la app -> S01 (Pizarra Home) -> Visualiza tarjeta de Florida Día destacada con Fijo y Corridos -> Clic en tarjeta -> S02 (Detalle con histórico reciente).
- **Happy Path Clicks:** 1 clic.
- **Caso borde:** Sorteo retrasado en la fuente oficial; mostrar badge "En espera de confirmación" en lugar de datos obsoletos.

### F02: Búsqueda de un sueño en la Charada para generar una jugada
- **Flujo:** Abre S03 (Charada) -> Escribe "accidente" o "dinero" -> La app filtra en vivo los términos -> Muestra número (ej. "48") -> Clic en el resultado -> Abre tarjeta con sinónimos, número espejo y opción "Calcular pirámide con este número" -> Salta a S04.
- **Happy Path Clicks:** 3 clics.
- **Caso borde:** Sueño con término regional cubano no estandarizado (usar motor difuso / fuzzy search de términos sincréticos).

### F03: Análisis matemático antes del sorteo (Pirámide + Cruz de la Suerte)
- **Flujo:** S01 -> Acceso directo a S04 (Pirámide) -> Selecciona "Pirámide de hoy" (autocompleta fecha actual) -> Observa el vértice y los pares base -> Toca "Ver Cruz de la Suerte" (S05) -> Compara números coincidentes en ambas herramientas.
- **Happy Path Clicks:** 2 clics.
- **Caso borde:** Cambiar manualmente la fecha para simular resultados pasados.

### F04: Simulación y seguimiento de jugada en "Mi Laboratorio"
- **Flujo:** S12 (Mi Laboratorio) -> Toca "Nueva Jugada" -> Ingresa número fijo (ej. 73) y parlé (ej. 73-15) -> Guarda jugada -> El sistema cruza automáticamente los números al llegar el sorteo de la noche -> Notificación push indicando acierto/fallo y actualización de estadísticas.
- **Happy Path Clicks:** 4 clics.
- **Caso borde:** Sorteo cancelado o feriado en EE.UU.

---

## 5. Inventario de Componentes y Sistema de Diseño

| Componente | Variantes | Estados | Pantallas que lo usan |
|---|---|---|---|
| **LotteryResultCard** | Destacada (Florida), Compacta (Georgia/NY), Histórica | En vivo, Oficial, Esperando, Error de conexión | S01, S02 |
| **BolitaBadge** | Fijo (dorado/azul), Corrido (gris), Centena (acento) | Normal, Destacado, Animado al ganar | S01, S02, S10, S11 |
| **CharadaSearchInput** | Con selector Tradicional/Mixta | Vacío, Con texto, Autocompletado, Cargando | S03 |
| **PyramidTreeRenderer** | Pick 3 (3 dígitos base), Pick 4 (4 dígitos base) | Render estático, Celdas clickeables, Resaltado de vértice | S04 |
| **LuckyCrossGrid** | Matriz 3x3 tradicional | Interactiva, Selección de pares | S05 |
| **HeatmapCell** | Gradiente de frío (azul) a caliente (rojo) | 0 salidas, 1-2 salidas, 3+ salidas, Seleccionado | S11 |
| **PredictionProgressBar** | Porcentaje de votación comunitaria | Activo, Concluido | S13 |

---

## 6. Modelo de Datos Deducido (Inferred Data Model)

```
Draw (Sorteo)
  id: string (ej. "FL-MID-20261109")
  lottery: enum ("florida", "georgia", "new_york", "powerball", "megamillions")
  period: enum ("midday", "evening", "night")
  draw_date: date (YYYY-MM-DD)
  draw_time: timestamp
  raw_winning_numbers: string (ej. "4-7-3")
  pick4: string (opcional, ej. "9-4-7-3")
  fijo: string (2 dígitos terminales, ej. "73")
  centena: string (1 dígito previo al fijo, ej. "4")
  corridos: array[string] (números corridos de la jugada)
  status: enum ("pending", "official", "delayed")
  evidence: S01, S02, boliteros.com API
  confidence: high

CharadaEntry (Entrada de Charada)
  number: integer (1..100)
  primary_name: string (ej. "Caballo")
  category: enum ("clasica", "mixta", "extendida")
  synonyms: array[string] (ej. ["sol", "revolución", "candela", "pescado grande"])
  description: string
  associated_god: string (opcional, para Atómico/Dioses)
  evidence: S03, tradición popular cubana
  confidence: high

NumberStatistic (Estadística de Número)
  number: string (00..99)
  lottery: string
  period: string
  days_delayed: integer (días sin salir)
  total_hits_last_30: integer
  total_hits_last_90: integer
  total_hits_last_365: integer
  last_draw_date: date
  evidence: S10, S11
  confidence: high

SimulationPlay (Jugada de Mi Laboratorio)
  id: uuid
  user_id: string
  draw_target_id: string
  play_type: enum ("fijo", "corrido", "parle", "candado", "centena")
  numbers: array[string]
  virtual_stake: float
  is_winner: boolean
  payout_multiplier: float
  created_at: timestamp
  evidence: S12
  confidence: high
```

---

## 7. Puntos Críticos y Dolencias del Original (Pain Points & Oportunidad)

1. **Saturación Extrema de Publicidad (Ad Clutter):**
   - El original de `devlotto` bombardea con banners adhesivos inferiores, anuncios intersticiales a pantalla completa en cada navegación y videos forzados para ver tablas de estadísticas. En Cuba o con datos móviles lentos, esto gasta megas preciosos y congela la UI.
2. **Caídas y Lentitud en Horas Pico:**
   - A la 1:30 PM y 9:45 PM (horas de los sorteos de Florida), miles de cubanos entran simultáneamente. El servidor central de devlotto suele degradarse o arrojar `Timeout / Network Error`.
3. **Dependencia Total de Conexión (Sin Modo Offline):**
   - Si no hay señal o datos móviles (frecuente en Cuba), el usuario no puede ni siquiera consultar el diccionario de la Charada ni usar los cálculos matemáticos de pirámides/cruces, que son funciones 100% estáticas.
4. **Fórmula de Suscripción VIP Agresiva:**
   - Restringe funciones básicas de cálculo detrás de pagos mensuales en dólares inaccesibles para la gran mayoría en la isla.

---

## 8. Estrategia "Better Than The Original" (La Ventaja Competitiva)

- **Arquitectura Offline-First:**
  - Base de datos local (SQLite / IndexedDB / PWA Cache).
  - La Charada entera, las pirámides, las cruces de la suerte y las tablas de equivalencia se ejecutan localmente en el cliente en microsegundos, **sin consumir 1 solo byte de internet**.
  - Los resultados se sincronizan mediante pequeños deltas JSON (pesan menos de 2 KB por actualización) con soporte para compresión extrema.
- **Diseño Ultra Rápido y Limpio (Dark Mode Nativo):**
  - Cero banners invasivos. Tipografía legible de alto contraste estilo terminal financiera deportiva.
- **Notificaciones Push Eficientes:**
  - Envío inmediato vía WebPush/Firebase sin necesidad de tener la app abierta ni refrescar en bucle.

---

## 9. Dimensionamiento del Proyecto

- **Pantallas:** 14 pantallas estructuradas.
- **Flujos Críticos:** 4 flujos principales.
- **Entidades:** 4 entidades núcleo (`Draw`, `CharadaEntry`, `NumberStatistic`, `SimulationPlay`).
- **Complejidad:** Media (**M** - 2 a 3 semanas para prototipo de producción).
- **Próximo Paso Recomendado:** Ejecutar `/replica-architect` para definir la pila tecnológica (frontend PWA / Flutter / React Native + backend ligero en Node/Go o Supabase/Cloudflare Workers para scraping y websocket de resultados).
