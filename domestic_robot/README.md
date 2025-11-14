# Sistema Multi-Agente de Robot Doméstico en Jason

## Descripción General

Este proyecto implementa un **sistema multi-agente** desarrollado en **AgentSpeak (Jason)** que simula un hogar inteligente con un robot de limpieza autónomo. El sistema modela la interacción entre múltiples agentes en un entorno doméstico realista, demostrando capacidades de planificación autónoma, navegación espacial, comunicación inter-agente y toma de decisiones reactiva.

### Agentes del Sistema

- **Robot**: Agente autónomo encargado de la limpieza del hogar y detección de intrusos
- **Owner (Propietario)**: Agente que simula el comportamiento del habitante de la casa
- **Repartidor**: Agente que gestiona entregas al domicilio
- **Intruso**: Agente que aparece periódicamente como amenaza de seguridad

## Características Principales

### Robot Autónomo
- **Limpieza inteligente**: Detecta y limpia habitaciones sucias de forma autónoma mediante percepciones del entorno
- **Navegación espacial**: Utiliza algoritmos de pathfinding basados en grafos para moverse eficientemente entre habitaciones
- **Algoritmo de barrido exhaustivo**: Implementa patrones de limpieza vertical y horizontal que garantizan cobertura completa
- **Detección de intrusos**: Sistema de vigilancia que alerta al propietario mediante comunicación inter-agente
- **Evasión inteligente**: Implementa comportamiento social para evitar molestar al propietario
- **Gestión energética**: Retorna automáticamente a la estación de carga cuando no hay tareas pendientes

### Propietario
- **Comportamiento realista**: Simula actividades cotidianas alternando entre descanso y sueño
- **Movimiento autónomo**: Navega por la casa utilizando la misma librería de pathfinding que el robot
- **Sistema de comunicación**: Recibe y procesa alertas de seguridad del robot en tiempo real

### Entorno Doméstico

El entorno simula una vivienda completa de 9 habitaciones distribuidas en un grid de 24×12 celdas:

- **Cocina (kitchen)**: Área de preparación de alimentos con nevera
- **Sala de estar (livingroom)**: Espacio social con sofá, mesa y sillas
- **Dormitorios**: Tres habitaciones (bedroom1, bedroom2, bedroom3) equipadas con camas
- **Baños**: Dos cuartos de baño (bath1, bath2)
- **Áreas de circulación**: Hall de entrada y pasillo (hallway) que conectan las habitaciones

**Elementos del Entorno:**
- **Mobiliario interactivo**: Sofá, sillas, camas, mesa, nevera y estación de carga
- **Sistema de puertas**: Red de 9 puertas que conectan las habitaciones formando un grafo navegable
- **Generación dinámica de eventos**: Thread independiente que genera suciedad cada 30 segundos
- **Sistema de seguridad**: Thread que simula la aparición de intrusos cada 40 segundos

## Arquitectura del Sistema

### Estructura de Archivos

```
domestic_robot/
├── DomesticRobot.mas2j          # Configuración del sistema multi-agente
├── logging.properties            # Configuración de logs
├── src/
│   ├── agt/                     # Agentes AgentSpeak
│   │   ├── robot.asl            # Lógica del robot de limpieza
│   │   ├── owner.asl            # Lógica del propietario
│   │   ├── movement.asl         # Librería de movimiento compartida
│   │   └── supermarket.asl      # Agente repartidor
│   └── main/
│       ├── env/domotic/         # Entorno de simulación
│       │   ├── HouseEnv.java    # Interfaz Jason-Entorno
│       │   ├── HouseModel.java  # Modelo lógico de la casa
│       │   └── HouseView.java   # Visualización gráfica
│       └── java/                # Acciones internas
│           ├── bot/chat.java    # Integración con IA (OpenAI)
│           └── time/check.java  # Utilidades de tiempo
└── lib/                         # Librerías externas
```

## Componentes Técnicos

### 1. Agentes AgentSpeak

#### **robot.asl**
Implementa el comportamiento completo del robot de limpieza mediante una arquitectura BDI (Belief-Desire-Intention).

**Creencias Iniciales:**
- `originalHeight(6)` y `originalWidth(16)`: Dimensiones máximas estimadas de las habitaciones para el algoritmo de barrido
- `originalOwnerLimit(5)`: Umbral de tolerancia antes de evadir al propietario
- `ownerLimit(5)`: Contador dinámico de proximidad al propietario

**Objetivos Principales:**

1. **`!main`**: Ciclo principal del agente
   - Ejecuta continuamente dos sub-objetivos en secuencia
   - `!cleaningLoop`: Gestiona la limpieza de habitaciones
   - `!evadeOwner`: Implementa comportamiento social
   - Reinicia recursivamente para mantener el agente activo

2. **`!cleaningLoop`**: Sistema de decisión de limpieza
   - Detecta habitaciones sucias mediante percepción `dirty(Room)`
   - Si no está limpiando: selecciona la mejor habitación (`!chooseRoomToClean`)
   - Si está limpiando: continúa con la tarea actual (`!cleanRoom`)
   - Si no hay suciedad: retorna a la estación de carga (`!goToCharger`)

3. **`!evadeOwner`**: Mecanismo de cortesía social
   - Monitoriza distancia al propietario vía percepción `at(robot, owner)`
   - Decrementa contador cada vez que está cerca
   - Cuando `ownerLimit` llega a 0, ejecuta movimiento aleatorio
   - Resetea el contador cuando se aleja

**Planes Reactivos (Event-Triggered):**

```asl
+at(Me, dirty):
    // Activado automáticamente al detectar suciedad bajo el robot
    .my_name(Me) <- clean(robot).

+at(Me, intruder):
    // Activado al detectar intruso en celda adyacente
    .my_name(Me) <- 
        alert("INTRUDER ALERT! A RED SPY IS IN THE BASE!");
        .send(owner, tell, intruderDetected).
```

Estos planes se ejecutan inmediatamente cuando se añaden las percepciones correspondientes, demostrando el comportamiento reactivo del agente.

**Algoritmo de Selección de Habitación (`!chooseRoomToClean`):**

1. Obtiene todas las habitaciones sucias: `.setof(X, dirty(X), Rooms)`
2. Aleatoriza el orden: `.shuffle(Rooms, ShuffledRooms)` (evita sesgos)
3. Para cada habitación:
   - Calcula ruta más corta usando `shortestRoomPath`
   - Compara longitud con mejor ruta actual
   - Aplica heurística: evita pasillo (hallway) a menos que sea única opción
4. Selecciona habitación con ruta más corta y establece `currentlyCleaning(Room)`

**Estrategia de Limpieza por Barrido Exhaustivo:**

El robot implementa un algoritmo de cobertura completa en 4 fases alternadas:

**Fase 1: Inicialización**
```asl
+!sweepRoom(Room):
    not bottomReached & not height(X)
    <-
    !moveUpNoExit;      // Posiciona en techo
    +height(Height).     // Inicializa contador vertical
```

**Fase 2: Descenso y Posicionamiento Horizontal**
```asl
+!sweepRoom(Room):
    not bottomReached & height(X)
    <-
    !moveDownNoExit;     // Baja hasta el suelo
    if (height(0)) {
        +bottomReached;   // Marca fondo alcanzado
        +width(Width);    // Inicia contador horizontal
    }.
```

**Fase 3: Posicionamiento en Esquina Inferior Izquierda**
```asl
+!sweepRoom(Room):
    bottomReached & not leftReached
    <-
    !moveLeftNoExit;     // Mueve a la izquierda
    if (width(0)) {
        +leftReached;     // Marca esquina alcanzada
        +verticalSweepA;  // Activa primera fase de barrido
        +movingUp;        // Establece dirección inicial
    }.
```

**Fase 4: Barrido en 4 Patrones Alternados**

Los cuatro patrones de barrido garantizan cobertura completa:

1. **Barrido Vertical A (`!verticalSweepA`)**: 
   - Sube/baja en columnas
   - Al llegar a extremo, avanza una celda a la derecha
   - Alterna dirección vertical (flag `movingUp`)
   - Transiciona a Horizontal B al completar

2. **Barrido Horizontal B (`!horizontalSweepB`)**:
   - Izquierda/derecha en filas (desde arriba)
   - Al llegar a extremo, baja una celda
   - Alterna dirección horizontal (flag `movingRight`)
   - Transiciona a Vertical B al completar

3. **Barrido Vertical B (`!verticalSweepB`)**:
   - Similar a A pero con dirección inicial opuesta (flag `movingDown`)
   - Avanza a la izquierda en lugar de derecha
   - Transiciona a Horizontal A al completar

4. **Barrido Horizontal A (`!horizontalSweepA`)**:
   - Similar a B pero desde abajo
   - Desciende en lugar de subir
   - Alterna dirección (flag `movingLeft`)
   - Al finalizar, declara habitación limpia

**Lógica de un Patrón de Barrido (ejemplo verticalSweepA):**

```asl
+!verticalSweepA:
    width(W) & height(H) & verticalSweepA
    <-
    if (height(OH) & width(0)) {
        // Condición de terminación: llegó a última columna
        -verticalSweepA;
        +horizontalSweepB;  // Transición a siguiente fase
    } else {
        if (not width(0) & height(0)) {
            // Llegó a extremo vertical: cambia columna
            !moveRightNoExit;
            -height(0); +height(OH);  // Resetea contador
            // Invierte dirección vertical
            if (movingUp) { -movingUp; } else { +movingUp; };
        } else {
            // Continúa en dirección actual
            if (movingUp) { !moveUpNoExit; } 
            else { !moveDownNoExit; };
        };
    }.
```

**Gestión de Estado durante Barrido:**

El robot mantiene múltiples creencias dinámicas:
- `height(N)` / `width(N)`: Contadores de posición relativa
- `bottomReached` / `leftReached`: Flags de inicialización
- `movingUp/Down/Left/Right`: Dirección actual de movimiento
- `verticalSweepA/B`, `horizontalSweepA/B`: Fase activa de barrido
- `currentlyCleaning(Room)`: Habitación objetivo

Al finalizar limpieza, `!resetCleaning` elimina todas estas creencias:
```asl
+!resetCleaning <-
    -currentlyCleaning(Room);
    -bottomReached; -leftReached;
    -height(X); -width(Y);
    -movingUp; -movingDown; -movingRight; -movingLeft;
    -verticalSweepA; -horizontalSweepA;
    -verticalSweepB; -horizontalSweepB.
```

**Navegación a Estación de Carga:**

```asl
+!goToCharger:
    not atRoom(bath1) <- !goToRoom(bath1).

+!goToCharger:
    atRoom(bath1) & not at(Me, charger) <- !moveRandomlyNoExit.

+!goToCharger:
    at(Me, charger) <- ?true.  // Plan vacío: ya está cargando
```

El cargador está en `bath1`, por lo que el robot:
1. Navega al baño si no está allí
2. Busca el cargador dentro del baño con movimiento aleatorio
3. Se detiene al encontrarlo

**Ventajas del Diseño:**

- **Reactivo**: Responde inmediatamente a suciedad e intrusos
- **Deliberativo**: Planifica rutas óptimas entre habitaciones
- **Robusto**: Los 4 patrones de barrido cubren cualquier geometría
- **Social**: Respeta el espacio del propietario
- **Eficiente**: Minimiza desplazamientos mediante pathfinding
- **Autónomo**: Ciclo infinito sin intervención externa

#### **owner.asl**
Simula el comportamiento del propietario como un agente autónomo con necesidades básicas y comportamiento estocástico.

**Arquitectura del Agente:**

El propietario implementa un modelo de comportamiento basado en estados internos (deseos) que determinan sus acciones. Utiliza la librería `movement.asl` compartida con el robot, demostrando reutilización de código en sistemas multi-agente.

```asl
{ include("movement.asl") }  // Hereda capacidades de navegación
```

**Creencias Iniciales:**

```asl
sittable([sofa, chair1, chair2, chair3, chair4]).
sleepOn([bed1, bed2, bed3]).
```

Estas listas definen los muebles válidos para cada actividad:
- **`sittable`**: 5 opciones de asiento (1 sofá + 4 sillas alrededor de la mesa)
- **`sleepOn`**: 3 camas disponibles en los dormitorios

**Objetivo Principal:**

```asl
!main.  // Objetivo inicial que arranca el agente
```

**Ciclo Principal (`!main`):**

El agente implementa una máquina de estados finitos mediante planes con diferentes contextos:

```asl
+!main: wantToSit(Object) <-
    !sitOnObjective; !main.

+!main: wantToSleep(Object) <-
    !sleepOnObjective; !main.

+!main <-
    !chooseObjective; !main.

-!main <-
    !main.  // Recuperación ante fallos
```

**Lógica de selección de plan:**

1. **Estado "quiero sentarme"**: Si existe creencia `wantToSit(Object)`
   - Ejecuta `!sitOnObjective` (navegar y sentarse)
   - Reinicia ciclo principal

2. **Estado "quiero dormir"**: Si existe creencia `wantToSleep(Object)`
   - Ejecuta `!sleepOnObjective` (navegar y dormir)
   - Reinicia ciclo principal

3. **Sin deseos activos**: 
   - Ejecuta `!chooseObjective` (decide nueva actividad)
   - Reinicia ciclo principal

4. **Plan de recuperación** (`-!main`): Si falla cualquier plan principal
   - Reinicia automáticamente el ciclo
   - Garantiza que el agente nunca se detiene

**Algoritmo de Decisión (`!chooseObjective`):**

```asl
+!chooseObjective <-
    .random(X);  // Genera número aleatorio [0, 1)
    if (X < 0.5) {
        !chooseSittingPlace;  // 50% probabilidad
    } else {
        !chooseSleepingPlace;  // 50% probabilidad
    };
    !resetPatience.  // Reinicia contador de pathfinding
```

**Distribución de probabilidades:**
- 50% selecciona actividad de sentarse
- 50% selecciona actividad de dormir
- Modelo estocástico simple que simula alternancia entre descanso activo y sueño

**Selección de Lugar para Sentarse (`!chooseSittingPlace`):**

```asl
+!chooseSittingPlace:
    sittable(SittableList)
    <-
    .random(R);                          // Aleatorio [0, 1)
    .length(SittableList, Len);          // Len = 5
    Index = R * Len;                      // [0, 5)
    IndexInt = math.floor(Index);         // {0, 1, 2, 3, 4} - conversión a entero
    .nth(IndexInt, SittableList, ChosenPlace);
    .println("Owner wants to sit on ", ChosenPlace);
    +wantToSit(ChosenPlace).              // Añade deseo
```

**Nota:** En el código real, la conversión a entero se hace implícitamente al usar `.nth()`, por lo que el código simplificado sería:

```asl
+!chooseSittingPlace:
    sittable(SittableList)
    <-
    .random(R);
    .length(SittableList, Len);
    .nth(R * Len, SittableList, ChosenPlace);  // Jason trunca automáticamente
    .println("Owner wants to sit on ", ChosenPlace);
    +wantToSit(ChosenPlace).
```

**Proceso paso a paso:**
1. Obtiene lista de lugares sentables desde creencias
2. Genera índice aleatorio: `floor(random() * 5)` → distribución uniforme
3. Selecciona elemento en posición `IndexInt` de la lista
4. Imprime intención en consola (trazabilidad)
5. Añade creencia `wantToSit(ChosenPlace)` que activará siguiente iteración

**Ejemplo de ejecución:**
```
R = 0.73
Index = 0.73 * 5 = 3.65
IndexInt = floor(3.65) = 3
ChosenPlace = .nth(3, [sofa, chair1, chair2, chair3, chair4]) = chair3
Output: "Owner wants to sit on chair3"
```

**Selección de Lugar para Dormir (`!chooseSleepingPlace`):**

```asl
+!chooseSleepingPlace:
    sleepOn(SleepableList)
    <-
    .random(R);
    .length(SleepableList, Len);          // Len = 3
    Index = (R * Len);                     // [0, 3)
    IndexInt = math.floor(Index);          // {0, 1, 2}
    .nth(IndexInt, SleepableList, ChosenPlace);
    .println("Owner wants to sleep on ", ChosenPlace);
    +wantToSleep(ChosenPlace).
```

Funcionamiento idéntico a `chooseSittingPlace` pero sobre lista `sleepOn` de 3 elementos.

**Ejecución de Actividad: Sentarse (`!sitOnObjective`):**

**Plan 1: Navegación hacia el objetivo**
```asl
+!sitOnObjective:
    wantToSit(ChosenPlace) &
    .my_name(Me) &
    not at(Me, ChosenPlace)
    <-
    !moveTowardsAdvanced(ChosenPlace).
```

- **Contexto**: Desea sentarse pero no está en el mueble
- **Acción**: Navega usando plan de `movement.asl`
- Se ejecuta repetidamente hasta llegar al destino

**Plan 2: Sentarse y esperar**
```asl
+!sitOnObjective:
    wantToSit(ChosenPlace) &
    .my_name(Me) &
    at(Me, ChosenPlace)
    <-
    sit(ChosenPlace);              // Acción externa (HouseEnv)
    .random(X);
    .wait(X*1000+1000);            // Espera entre 1-2 segundos
    .random(Y);
    if (Y < 0.1) {                 // 10% probabilidad
        -wantToSit(ChosenPlace);   // Elimina deseo
    }.
```

**Funcionamiento detallado:**

1. **Sentarse**: Ejecuta acción `sit(ChosenPlace)` en el entorno
   - Actualiza posición del agente al mueble
   - Cambia visualización gráfica

2. **Tiempo de permanencia**: 
   - Genera `X ∈ [0, 1)`
   - Espera `X * 1000 + 1000` ms = **1000-2000 ms** (1-2 segundos)
   - Simula tiempo sentado

3. **Decisión de cambiar actividad**:
   - Genera `Y ∈ [0, 1)`
   - Con probabilidad 10% (`Y < 0.1`): elimina `wantToSit`
   - Con probabilidad 90%: mantiene el deseo
   - Si elimina deseo → próxima iteración de `!main` ejecutará `!chooseObjective`
   - Si mantiene deseo → se queda sentado otro ciclo

**Ejecución de Actividad: Dormir (`!sleepOnObjective`):**

**Plan 1: Navegación**
```asl
+!sleepOnObjective:
    wantToSleep(ChosenPlace) &
    .my_name(Me) &
    not at(Me, ChosenPlace)
    <-
    !moveTowardsAdvanced(ChosenPlace).
```

Idéntico al de sentarse pero con `wantToSleep`.

**Plan 2: Dormir y esperar**
```asl
+!sleepOnObjective:
    wantToSleep(ChosenPlace) &
    .my_name(Me) &
    at(Me, ChosenPlace)
    <-
    sit(ChosenPlace);              // Misma acción (acostarse)
    .random(X);
    .wait(X*5000+2000);            // Espera entre 2-7 segundos
    .random(Y);
    if (Y < 0.1) {
        -wantToSleep(ChosenPlace);
    }.
```

**Diferencias con sentarse:**

- **Tiempo de permanencia**: `X * 5000 + 2000` = **2000-7000 ms** (2-7 segundos)
- Refleja que dormir toma más tiempo que sentarse
- Misma probabilidad 10% de cambiar actividad
- Misma acción `sit()` en el entorno (la visualización diferencia por ubicación)

**Plan Reactivo: Respuesta a Alerta de Intruso**

```asl
+intruderDetected[source(robot)]
    <-
    alert("He could be you, he could be me, he could even be-");
    -intruderDetected[source(robot)].
```

**Mecanismo de comunicación inter-agente:**

1. El robot envía mensaje: `.send(owner, tell, intruderDetected)`
2. Se añade percepción con anotación `[source(robot)]`
3. Este plan se activa automáticamente (evento `+`)
4. Ejecuta acción `alert()` con mensaje
5. Elimina la percepción `-intruderDetected[source(robot)]`

**Anotación `[source(robot)]`:**
- Identifica origen del mensaje
- Permite distinguir si es percepción del entorno vs mensaje de otro agente
- Patrón estándar en Jason para comunicación

**Diagrama de Estados del Propietario:**

```
    ┌──────────────┐
    │   Sin Deseo  │
    │  !main →     │
    │!chooseObject │
    └──────┬───────┘
           │ random()
      ┌────┴────┐
      │         │
   50%│         │50%
      ▼         ▼
┌──────────┐ ┌──────────┐
│wantToSit │ │wantToSleep│
│          │ │          │
└────┬─────┘ └────┬─────┘
     │            │
     │ not at()   │ not at()
     ▼            ▼
┌──────────┐ ┌──────────┐
│ Navegar  │ │ Navegar  │
│  !move   │ │  !move   │
└────┬─────┘ └────┬─────┘
     │            │
     │ at()       │ at()
     ▼            ▼
┌──────────┐ ┌──────────┐
│ Sentado  │ │ Durmiendo│
│ 1-2 seg  │ │ 2-7 seg  │
└────┬─────┘ └────┬─────┘
     │            │
   10│% random()  │10%
     ▼            ▼
    (elimina deseo)
     │            │
     └────┬───────┘
          ▼
    ┌──────────────┐
    │   !main      │
    │  (reinicia)  │
    └──────────────┘
```

**Características del Diseño:**

**1. Autonomía:**
- No requiere intervención externa una vez iniciado
- Ciclo infinito autosostenido

**2. Estocástico:**
- Comportamiento impredecible mediante aleatoriedad
- Simula variabilidad humana

**3. Reactivo:**
- Responde inmediatamente a alertas del robot
- Comunicación asíncrona via mensajes

**4. Deliberativo:**
- Mantiene estados internos (deseos)
- Planifica navegación hacia objetivos

**5. Modular:**
- Reutiliza librería `movement.asl`
- Separación de lógica de navegación y comportamiento

**6. Robusto:**
- Plan de recuperación ante fallos (`-!main`)
- Reinicia automáticamente si falla algún objetivo

**Comparación con el Robot:**

| Aspecto | Robot | Owner |
|---------|-------|-------|
| Objetivo principal | Limpiar habitaciones | Realizar actividades cotidianas |
| Complejidad | Alta (4 fases de barrido) | Media (navegación + espera) |
| Percepciones | dirty, intruder, atDoor | intruderDetected, at, atRoom |
| Comunicación | Envía alertas | Recibe alertas |
| Estado interno | Multiple flags de barrido | Deseos simples (sit/sleep) |
| Navegación | Pathfinding + barrido | Solo pathfinding |
| Tiempo de espera | No (limpia continuamente) | Sí (simula actividades) |

**Interacción Robot-Owner:**

```
Robot detecta intruso
        │
        ├─ +at(robot, intruder)
        │
        ├─ .send(owner, tell, intruderDetected)
        │
        ▼
Owner recibe mensaje
        │
        ├─ +intruderDetected[source(robot)]
        │
        ├─ alert("He could be you...")
        │
        └─ -intruderDetected[source(robot)]

Robot evita al owner
        │
        ├─ at(robot, owner) detectado
        │
        ├─ ownerLimit decrementado
        │
        └─ Si limit=0: !moveRandomly
```

**Ventajas del Modelo del Propietario:**

- **Realismo conductual**: Tiempos aleatorios simulan comportamiento humano
- **Simplicidad**: Lógica clara y mantenible
- **Extensibilidad**: Fácil añadir nuevas actividades (comer, leer, etc.)
- **Interactividad**: Responde a eventos del entorno y otros agentes
- **Eficiencia**: Reutiliza código de navegación del robot

#### **movement.asl**
Librería compartida de navegación que implementa algoritmos sofisticados de pathfinding basado en grafos y gestión de movimiento para múltiples agentes.

**Propósito y Diseño:**

Esta librería es un módulo reutilizable que abstrae toda la complejidad de navegación en el entorno doméstico. Tanto el robot como el propietario heredan estas capacidades mediante:

```asl
{ include("movement.asl") }
```

Este diseño modular ofrece:
- **Reutilización de código**: Evita duplicación entre agentes
- **Mantenimiento centralizado**: Cambios en un solo lugar
- **Abstracción de complejidad**: Los agentes usan `!moveTowardsAdvanced(X)` sin conocer algoritmos internos
- **Separación de responsabilidades**: Navegación vs. comportamiento específico del agente

**Arquitectura de la Librería:**

La librería se estructura en 4 capas:

1. **Capa de Datos**: Representación del grafo y constantes
2. **Capa de Razonamiento**: Reglas lógicas y predicados
3. **Capa de Planificación**: Algoritmos de pathfinding
4. **Capa de Ejecución**: Planes de movimiento

---

### **1. CAPA DE DATOS: Modelo Topológico del Entorno**

**Grafo de Conectividad:**

El entorno se modela como un **grafo dirigido bidireccional** donde:
- **Vértices (V)**: 9 habitaciones {kitchen, hall, hallway, bedroom1, bedroom2, bedroom3, bath1, bath2, livingroom}
- **Aristas (E)**: 9 puertas físicas representadas como 18 conexiones dirigidas
- **Etiquetas (L)**: Identificadores únicos de puertas {doorKit1, doorKit2, doorBed1, doorBed2, doorBed3, doorBath1, doorBath2, doorSal1, doorSal2}

**Definición Completa del Grafo:**

```asl
// Cocina conecta con hall y hallway
connect(kitchen, hall, doorKit1).
connect(hall, kitchen, doorKit1).
connect(kitchen, hallway, doorKit2).
connect(hallway, kitchen, doorKit2).

// Baños
connect(bath1, hallway, doorBath1).
connect(hallway, bath1, doorBath1).
connect(bath2, bedroom1, doorBath2).
connect(bedroom1, bath2, doorBath2).

// Dormitorios
connect(bedroom1, hallway, doorBed1).
connect(hallway, bedroom1, doorBed1).
connect(bedroom2, hallway, doorBed2).
connect(hallway, bedroom2, doorBed2).
connect(bedroom3, hallway, doorBed3).
connect(hallway, bedroom3, doorBed3).

// Sala de estar
connect(hall, livingroom, doorSal1).
connect(livingroom, hall, doorSal1).
connect(hallway, livingroom, doorSal2).
connect(livingroom, hallway, doorSal2).
```

**Propiedades del Grafo:**

- **Bidireccionalidad**: Cada puerta física se representa con 2 predicados `connect/3`
  - Ejemplo: `connect(A, B, P)` y `connect(B, A, P)` para la misma puerta P
  - Permite búsquedas en ambas direcciones sin lógica adicional

- **Centralidad del Hallway**: El pasillo (hallway) actúa como hub central
  - Grado de entrada/salida: 10 (máximo del grafo)
  - Conecta directamente con 5 habitaciones
  - Todas las rutas óptimas suelen atravesarlo

- **Diámetro del grafo**: Distancia máxima entre dos nodos = 4 puertas
  - Ejemplo: bedroom3 → bath2 requiere [doorBed3, doorSal2, doorBed1, doorBath2]
  - La mayoría de rutas requieren 1-2 puertas

**Visualización del Grafo:**

```
        kitchen
       /       \
   doorKit1  doorKit2
     /           \
   hall        hallway ────────────────┐
     |            |  \  \  \           |
  doorSal1    doorBath1 | | |      doorSal2
     |            |      | | |          |
 livingroom     bath1   | | └─ bedroom3 |
                         | |            |
                         | └── bedroom2 |
                         |              |
                    doorBed1            |
                         |              |
                    bedroom1 ─ doorBath2 ─ bath2
```

**Constantes del Sistema de Paciencia:**

```asl
originalPatience(50).   // Valor inicial de paciencia
patience(50).           // Contador dinámico
```

El sistema de paciencia previene bucles infinitos en situaciones de:
- Bloqueos por obstáculos dinámicos
- Rutas temporalmente inaccesibles
- Fallos en el pathfinding

---

### **2. CAPA DE RAZONAMIENTO: Predicados y Reglas**

**Regla de Aritmética (`minusOne/2`):**

```asl
minusOne(X, Y) :- Y = X - 1.
```

**Propósito**: Decremento aritmético reutilizable para control de profundidad.

**Justificación**: En Prolog/AgentSpeak, la aritmética requiere unificación explícita. Este predicado encapsula la operación de decremento para:
- Mejorar legibilidad del código
- Facilitar debugging (punto de breakpoint único)
- Reutilización en múltiples contextos

**Regla de Conteo de Puertas (`numberOfDoors/1`):**

```asl
numberOfDoors(X)
    :-
        .setof(Door, connect(_, _, Door), DoorList)
    &
        .length(DoorList, X).
```

**Funcionamiento paso a paso:**

1. **`.setof(Door, connect(_, _, Door), DoorList)`**:
   - Recopila TODAS las puertas únicas del grafo
   - `_` ignora habitaciones de origen/destino
   - Resultado: `DoorList = [doorKit1, doorKit2, doorBed1, doorBed2, doorBed3, doorBath1, doorBath2, doorSal1, doorSal2]`

2. **`.length(DoorList, X)`**:
   - Cuenta elementos en la lista
   - `X = 9` (número total de puertas únicas)

**Uso en el sistema:**
- Se invoca como `numberOfDoors(MaxDepth)` para obtener límite de búsqueda
- Garantiza que pathfinding puede explorar todo el grafo
- Previene configuraciones incorrectas de profundidad

---

### **3. CAPA DE PLANIFICACIÓN: Algoritmos de Pathfinding**

#### **Algoritmo 1: Búsqueda en Profundidad con Retroceso (`findPathRoom/5`)**

**Declaración completa:**

```asl
// Caso base: Ya estamos en el destino
findPathRoom(Current, Target, _, [], MaxDepth)
    :-
    Current = Target.

// Caso recursivo: Búsqueda DFS
findPathRoom(Current, Target, Visited, Path, MaxDepth)
    :-
        connect(Current, NextRoom, Door)      // Encuentra conexión
    &
        minusOne(MaxDepth, N1)                // Decrementa profundidad
    &
        N1 > 0                                 // Verifica límite
    &
        not .member(Door, Visited)             // Evita ciclos
    &
        findPathRoom(NextRoom, Target, [Door|Visited], SubPath, N1)
    &
        Path = [Door|SubPath].                 // Construye solución
```

**Análisis Algorítmico:**

**Tipo**: Depth-First Search (DFS) con backtracking y detección de ciclos

**Parámetros de entrada:**
- `Current`: Habitación actual (nodo de inicio)
- `Target`: Habitación destino (nodo objetivo)
- `Visited`: Lista de puertas ya atravesadas (previene ciclos)
- `MaxDepth`: Límite de profundidad (previene búsqueda infinita)

**Parámetro de salida:**
- `Path`: Lista ordenada de puertas [Primera, Segunda, ..., Última]

**Complejidad:**
- **Temporal**: O(b^d) donde b=grado máximo (≈4) y d=profundidad (≤3)
  - En la práctica: O(10-20 exploraciones) para este grafo
- **Espacial**: O(d) para la pila de recursión
  - Máximo 3 niveles de profundidad en este entorno

**Ejemplo de Ejecución Completa:**

Objetivo: Encontrar ruta de `bedroom3` a `bath1`

```
1. findPathRoom(bedroom3, bath1, [], Path, 9)
   ├─ connect(bedroom3, hallway, doorBed3) ✓
   ├─ not .member(doorBed3, []) ✓
   │
   2. findPathRoom(hallway, bath1, [doorBed3], SubPath, 8)
      ├─ connect(hallway, bath1, doorBath1) ✓
      ├─ not .member(doorBath1, [doorBed3]) ✓
      │
      3. findPathRoom(bath1, bath1, [doorBath1, doorBed3], SubPath2, 7)
         └─ bath1 = bath1 ✓  (Caso base)
         └─ Retorna SubPath2 = []
      │
      └─ SubPath = [doorBath1 | []] = [doorBath1]
   │
   └─ Path = [doorBed3 | [doorBath1]] = [doorBed3, doorBath1]

Resultado final: Path = [doorBed3, doorBath1]
```

**Mecanismo de Backtracking:**

Si la primera conexión explorada falla, Prolog retrocede automáticamente:

```
findPathRoom(kitchen, bedroom1, [], Path, 3)
  Intento 1: connect(kitchen, hall, doorKit1)
    → Explora hall → livingroom → [FALLA: no llega a bedroom1 en profundidad 2]
    → BACKTRACK
  Intento 2: connect(kitchen, hallway, doorKit2)
    → Explora hallway → bedroom1 → [ÉXITO]
    → Retorna Path = [doorKit2, doorBed1]
```

**Prevención de Ciclos:**

La lista `Visited` evita volver a atravesar puertas ya usadas:

```
findPathRoom(hall, bedroom1, [doorKit1], Path, 5)
  → connect(hall, kitchen, doorKit1)
  → .member(doorKit1, [doorKit1]) ✓  (Ya visitada)
  → Esta rama se descarta
  → Continúa con otras conexiones de hall
```

#### **Algoritmo 2: Búsqueda de Ruta Más Corta (`shortestRoomPath/4`)**

**Declaración:**

```asl
shortestRoomPath(Current, Target, Path, MaxDepth)
    :-
        MaxDepth > 0
    &
        (
            (
                minusOne(MaxDepth, N1)
            &
                shortestRoomPath(Current, Target, Path, N1)
            )
        |
            findPathRoom(Current, Target, [], Path, MaxDepth)
        ).
```

**Estrategia: Iterative Deepening Depth-First Search (IDDFS)**

Este algoritmo combina las ventajas de BFS (optimalidad) y DFS (eficiencia espacial).

**Funcionamiento:**

1. **Primera iteración**: Intenta con profundidad `MaxDepth - 1`
   - Si encuentra solución → es más corta (menos puertas)
   - Si falla → continúa

2. **Segunda iteración**: Intenta con profundidad `MaxDepth`
   - Usa `findPathRoom` completo
   - Encuentra solución si existe dentro de MaxDepth

3. **Recursión**: El primer intento es recursivo, reduciendo profundidad hasta 1

**Ejemplo de Ejecución:**

```
shortestRoomPath(kitchen, bedroom2, Path, 5)

1. MaxDepth = 5 > 0 ✓
2. Intenta profundidad 4:
   shortestRoomPath(kitchen, bedroom2, Path, 4)
   
   2.1. MaxDepth = 4 > 0 ✓
   2.2. Intenta profundidad 3:
        shortestRoomPath(kitchen, bedroom2, Path, 3)
        
        2.2.1. MaxDepth = 3 > 0 ✓
        2.2.2. Intenta profundidad 2:
               shortestRoomPath(kitchen, bedroom2, Path, 2)
               
               2.2.2.1. MaxDepth = 2 > 0 ✓
               2.2.2.2. Intenta profundidad 1:
                        shortestRoomPath(kitchen, bedroom2, Path, 1)
                        
                        FALLA: No hay ruta en profundidad 1
               
               2.2.2.3. findPathRoom(kitchen, bedroom2, [], Path, 2)
                        ÉXITO: Path = [doorKit2, doorBed2]
                        └─ Ruta: kitchen → hallway → bedroom2

Resultado: Path = [doorKit2, doorBed2]
```

**Por qué es Óptima:**

- Si existe ruta de longitud N, será encontrada en iteración de profundidad N
- Nunca retorna ruta de longitud N+1 si existe de longitud N
- Para este grafo: la mayoría de rutas óptimas tienen longitud 1-2

**Comparación BFS vs IDDFS:**

| Aspecto | BFS Tradicional | IDDFS (este algoritmo) |
|---------|-----------------|------------------------|
| Complejidad Temporal | O(b^d) | O(b^d) |
| Complejidad Espacial | O(b^d) | O(d) |
| Memoria usada (d=3, b=4) | ~64 nodos | ~3 nodos |
| Optimalidad | ✓ | ✓ |
| Implementación | Requiere cola | Solo recursión |

---

### **4. CAPA DE EJECUCIÓN: Planes de Movimiento**

#### **Plan 1: Movimiento Adaptativo hacia Objetivo (`!moveTowardsAdvanced/1`)**

**Plan A: Mismo Cuarto (Movimiento Directo)**

```asl
+!moveTowardsAdvanced(Objective):
    // Contexto: Agente y objetivo en misma habitación
            atRoom(CurrentRoom)
        &
            atRoom(Objective, CurrentRoom)
    <-
        move_towards(Objective);    // Acción física hacia objetivo
        !reducePatience.             // Decrementa contador de paciencia
```

**Comportamiento:**
- Usa acción interna `move_towards` del entorno Java
- El entorno calcula vector de dirección y mueve 1 celda
- No requiere pathfinding complejo

**Plan B: Habitaciones Diferentes (Navegación Multi-Sala)**

```asl
+!moveTowardsAdvanced(Objective):
    // Contexto: Objetivo en otra habitación
            atRoom(CurrentRoom)
        &
            atRoom(Objective, ObjectiveRoom)
        &
            not ObjectiveRoom = CurrentRoom
    <-
        !goToRoom(ObjectiveRoom);    // Navega a habitación destino
        !reducePatience.              // Decrementa paciencia
```

**Selección de Plan:**

Jason evalúa planes en orden de declaración:
1. Intenta Plan A: Si `CurrentRoom = ObjectiveRoom` → Éxito
2. Si falla contexto A, intenta Plan B: Si habitaciones diferentes → Éxito
3. Si ambos fallan: Error de plan

**Ventaja del Diseño:**
- Abstracción completa para el agente que llama
- El robot/owner solo ejecuta `!moveTowardsAdvanced(bed1)`
- La librería decide automáticamente qué estrategia usar

#### **Plan 2: Navegación entre Habitaciones (`!goToRoom/1`)**

**Implementación Completa:**

```asl
+!goToRoom(ObjectiveRoom):
            atRoom(CurrentRoom)
        &
            numberOfDoors(MaxDepth)
        &
            shortestRoomPath(CurrentRoom, ObjectiveRoom, Path, MaxDepth)
    <-
        // 1. Extrae primera puerta del path
        .nth(0, Path, FirstDoor);
        
        // 2. Detecta si ya está en una puerta (antes de moverse)
        if (atDoor) {
            +wasAtDoor;       // Marca flag temporal
        } else {
            -wasAtDoor;       // Elimina flag si existe
        };
        
        // 3. Ejecuta movimiento hacia la puerta
        move_towards(FirstDoor);
        
        // 4. Detecta bloqueo en puerta
        if (atDoor & wasAtDoor) {
            .println("Stuck in a door.");
            !unstuckFromDoor;
        };
        
        // 5. Mantenimiento de sistema de paciencia
        !reducePatience;
        
        // 6. Limpieza de flags temporales
        -wasAtDoor.
```

**Análisis Paso a Paso:**

**Paso 1: Cálculo de Ruta Óptima**

```asl
numberOfDoors(MaxDepth)    // MaxDepth = 9
shortestRoomPath(CurrentRoom, ObjectiveRoom, Path, MaxDepth)
```

- Obtiene límite de profundidad dinámicamente
- Calcula path óptimo usando IDDFS
- Ejemplo: `Path = [doorBed1, doorBath2]`

**Paso 2: Extracción de Próxima Puerta**

```asl
.nth(0, Path, FirstDoor);   // Índice 0 = primer elemento
```

- Si `Path = [doorBed1, doorBath2]` → `FirstDoor = doorBed1`
- El agente solo se preocupa de la puerta inmediata

**Paso 3-4: Sistema Anti-Bloqueo en Puertas**

Problema detectado: Los agentes a veces se atascan en puertas por:
- Colisión con otro agente
- Geometría de puerta estrecha
- Oscilación entre dos celdas

**Solución implementada:**

```asl
// ANTES de moverse: ¿Está en puerta?
if (atDoor) { +wasAtDoor; } else { -wasAtDoor; };

// Mueve hacia puerta
move_towards(FirstDoor);

// DESPUÉS de moverse: ¿Sigue en puerta Y estaba antes?
if (atDoor & wasAtDoor) {
    // ¡BLOQUEADO! Activar recuperación
    !unstuckFromDoor;
};
```

**Casos cubiertos:**

| Situación | atDoor antes | atDoor después | wasAtDoor | Acción |
|-----------|--------------|----------------|-----------|--------|
| Movimiento normal | false | false | false | Continuar |
| Entrando a puerta | false | true | false | Continuar |
| Saliendo de puerta | true | false | true | Continuar |
| **BLOQUEADO** | **true** | **true** | **true** | **!unstuckFromDoor** |

**Paso 5-6: Mantenimiento del Sistema**

```asl
!reducePatience;   // Previene bucles infinitos
-wasAtDoor;        // Limpia flags para próxima iteración
```

#### **Plan 3: Procedimiento de Desbloqueo (`!unstuckFromDoor`)**

```asl
+!unstuckFromDoor
    <-
    !moveRandomly;
    // Recursión hasta salir de la puerta
    if (atDoor) {
        !unstuckFromDoor;
    }.
```

**Algoritmo:**

1. Ejecuta movimiento aleatorio en cualquier dirección
2. Verifica si sigue en puerta
3. Si sí → repite recursivamente
4. Si no → termina y retorna al flujo normal

**Análisis de Terminación:**

- **Garantía probabilística**: P(salir en N intentos) → 1 cuando N → ∞
- **En la práctica**: 1-3 movimientos suelen ser suficientes
- **Caso extremo**: Si hay agente bloqueando, eventualmente se moverá

#### **Plan 4: Movimiento Aleatorio (`!moveRandomly`)**

```asl
+!moveRandomly
    <-
    .my_name(Me);
    .random(R);
    if (R < 0.25) {
        moveLeft(Me);
    } else {
        if (R < 0.5) {
            moveRight(Me);
        } else {
            if (R < 0.75) {
                moveUp(Me);
            } else {
                moveDown(Me);
            };
        };
    }.
```

**Distribución de Probabilidad:**

```
R ∈ [0.00, 0.25) → moveLeft   (25%)
R ∈ [0.25, 0.50) → moveRight  (25%)
R ∈ [0.50, 0.75) → moveUp     (25%)
R ∈ [0.75, 1.00) → moveDown   (25%)
```

**Propiedades Estadísticas:**
- Distribución uniforme discreta
- Esperanza de dirección: (0, 0) → sin sesgo
- Útil para exploración y recuperación de bloqueos

#### **Plan 5: Movimiento Confinado (`!moveRandomlyNoExit`)**

```asl
+!moveRandomlyNoExit
    <-
    .my_name(Me);
    .random(R);
    if (R < 0.25) {
        !moveLeftNoExit;
    } else {
        if (R < 0.5) {
            !moveRightNoExit;
        } else {
            if (R < 0.75) {
                !moveUpNoExit;
            } else {
                !moveDownNoExit;
            };
        };
    }.
```

**Diferencia con `moveRandomly`:**
- Usa planes `!moveXNoExit` en lugar de acciones `moveX`
- Estos planes verifican que el movimiento no salga de la habitación
- Útil para barrido de habitaciones (robot) y búsqueda de muebles (owner)

#### **Planes 6-9: Movimientos Direccionales Confinados**

Estos cuatro planes implementan movimiento seguro que previene salir de la habitación actual.

**Ejemplo: `!moveDownNoExit` con Tracking de Posición**

```asl
+!moveDownNoExit:
    // Contexto: Ya existe contador de altura
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            height(H)
    <-                  
        moveDown(Me);                           // 1. Intenta mover hacia abajo
        if (not atRoom(CurrentRoom) | atDoor) { // 2. Verifica si salió
            moveUp(Me);                          // 3. Revierte movimiento
            -height(H);                          // 4. Marca límite alcanzado
            +height(0);
        } else {                                // 5. Movimiento válido
            -height(H);                          // 6. Actualiza contador
            +height(H-1);
        }.
```

**Funcionamiento Detallado:**

**Escenario A: Movimiento Válido (Dentro de Habitación)**

```
Estado inicial:
  - Agente en (x=5, y=7) de bedroom1
  - height(3)

Ejecución:
  1. moveDown(Me) → nueva posición (x=5, y=8)
  2. atRoom(bedroom1) ✓ & not atDoor ✓
  3. Entra en rama else
  4. -height(3); +height(2)

Estado final:
  - Agente en (x=5, y=8) de bedroom1
  - height(2)
```

**Escenario B: Alcanza Límite de Habitación**

```
Estado inicial:
  - Agente en (x=5, y=11) [última fila de bedroom1]
  - height(1)

Ejecución:
  1. moveDown(Me) → nueva posición (x=5, y=12) [puerta o pasillo]
  2. not atRoom(bedroom1) ✓ [salió de la habitación]
  3. Entra en rama if
  4. moveUp(Me) → revierte a (x=5, y=11)
  5. -height(1); +height(0)  [marca límite inferior]

Estado final:
  - Agente en (x=5, y=11) de bedroom1
  - height(0)  [flag de límite]
```

**Ejemplo: `!moveDownNoExit` sin Tracking Inicial**

```asl
+!moveDownNoExit:
    // Contexto: Primera vez que se mueve en esta dirección
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            not height(H)
    <-
        moveDown(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveUp(Me);
        }.
```

**Comportamiento:**
- Simplemente revierte si sale, sin inicializar contador
- Útil cuando no se necesita tracking de posición
- Más liviano computacionalmente

**Los otros tres planes (`!moveUpNoExit`, `!moveLeftNoExit`, `!moveRightNoExit`) siguen el mismo patrón:**

```asl
!moveUpNoExit:
  - Usa height(H)
  - Revierte con moveDown si sale
  - Actualiza contador o marca límite

!moveLeftNoExit:
  - Usa width(W)
  - Revierte con moveRight si sale
  - Actualiza contador o marca límite

!moveRightNoExit:
  - Usa width(W)
  - Revierte con moveLeft si sale
  - Actualiza contador o marca límite
```

**Aplicación en el Robot:**

El robot usa estos planes durante el barrido de habitaciones:

```asl
// Durante verticalSweepA
!moveUpNoExit;    // Sube sin salir de habitación
// height(N) se decrementa automáticamente

// Al llegar a techo: height(0)
// Cambia dirección horizontal
!moveRightNoExit; // Se mueve a siguiente columna
```

---

### **5. SISTEMA DE PACIENCIA: Prevención de Bucles Infinitos**

**Declaración Completa:**

```asl
// Creencias iniciales
originalPatience(50).
patience(50).

// Plan de reducción
+!reducePatience:
        patience(P)
    <-
        -patience(P);
        +patience(P-1).

// Plan reactivo cuando se agota
+patience(0)
    <-
        !moveRandomly;
        .println("Patience exhausted, moving randomly.");
        !resetPatience.

// Plan de reseteo
+!resetPatience:
        originalPatience(OP)
    <-
        -patience(_);
        +patience(OP).
```

**Propósito del Sistema:**

Previene situaciones donde el agente queda atrapado en bucles de comportamiento:

1. **Bucles de pathfinding**: Intenta alcanzar objetivo inaccesible repetidamente
2. **Bloqueos físicos**: Obstáculos dinámicos (otro agente bloqueando)
3. **Fallos de navegación**: Errores en cálculo de rutas

**Funcionamiento:**

**Fase 1: Decremento Gradual**

Cada vez que el agente intenta navegar, se reduce paciencia:

```asl
!moveTowardsAdvanced(bed1)
  └─ !goToRoom(bedroom1)
      └─ !reducePatience
          └─ patience(50) → patience(49)
```

**Fase 2: Activación de Recuperación**

Cuando `patience` llega a 0, se activa automáticamente el plan reactivo:

```asl
+patience(0)  // Evento generado al añadir creencia patience(0)
  ├─ !moveRandomly              // Rompe bucle con movimiento aleatorio
  ├─ .println("Patience...")    // Log de debug
  └─ !resetPatience             // Restaura patience(50)
```

**Fase 3: Reseteo tras Éxito**

Cuando el agente completa un objetivo, resetea paciencia manualmente:

```asl
+!cleaningLoop:
    dirty(Room)
    <-
    !chooseRoomToClean;
    !sweepRoom(Room);
    !resetCleaning;
    !resetPatience.    // ← Reseteo explícito
```

**Análisis del Valor 50:**

- **Suficiente para navegación compleja**: 50 intentos permiten atravesar todo el grafo varias veces
- **No demasiado alto**: Evita esperas largas ante bloqueos permanentes
- **Ajustable**: Cambiar `originalPatience(50)` a otro valor es trivial

**Diagrama de Estados:**

```
    patience(50)
         │
         ├──┐ Cada intento de navegación
         ▼  │ !reducePatience
    patience(49...1)
         │
         │ Llega a 0
         ▼
    +patience(0) [EVENTO REACTIVO]
         │
         ├─ !moveRandomly
         │  └─ Rompe bucle
         │
         └─ !resetPatience
            └─ patience(50)
                │
                └─ Ciclo continúa
```

---

### **6. VENTAJAS DEL DISEÑO DE movement.asl**

**1. Completitud Algorítmica:**
- DFS garantiza encontrar ruta si existe
- MaxDepth suficiente para todo el grafo
- Backtracking automático de Prolog

**2. Optimalidad de Rutas:**
- IDDFS encuentra rutas más cortas
- Minimiza tiempo de navegación
- Reduce desgaste del agente

**3. Robustez ante Fallos:**
- Sistema de paciencia previene bucles
- Detección de bloqueo en puertas
- Planes de recuperación automáticos

**4. Modularidad y Reutilización:**
- Compartido por robot y owner
- Abstracción completa de navegación
- Fácil extensión a nuevos agentes

**5. Eficiencia Computacional:**
- O(d) espacio vs O(b^d) de BFS
- Detección temprana de ciclos
- Predicados optimizados

**6. Mantenibilidad:**
- Código centralizado en un archivo
- Separación clara de responsabilidades
- Documentación embebida en código

**7. Extensibilidad:**
- Agregar habitaciones: solo modificar `connect/3`
- Cambiar algoritmo: reemplazar `findPathRoom`
- Ajustar paciencia: modificar constante

---

### **7. COMPARACIÓN DE ALGORITMOS**

| Aspecto | `findPathRoom` (DFS) | `shortestRoomPath` (IDDFS) |
|---------|----------------------|----------------------------|
| Tipo | Búsqueda en profundidad | Profundización iterativa |
| Optimalidad | No garantizada | Garantizada |
| Complejidad temporal | O(b^d) | O(b^d) |
| Complejidad espacial | O(d) | O(d) |
| Uso típico | Exploración rápida | Navegación principal |
| Primera solución | Cualquiera | La más corta |

---

### **8. CASOS DE USO EN EL SISTEMA**

**Robot limpiando bedroom3, detecta suciedad en kitchen:**

```
1. robot ejecuta: !moveTowardsAdvanced(kitchen)

2. movement.asl:
   atRoom(bedroom3) & atRoom(kitchen, kitchen)
   → Habitaciones diferentes
   → !goToRoom(kitchen)

3. Pathfinding:
   shortestRoomPath(bedroom3, kitchen, Path, 9)
   → Path = [doorBed3, doorKit2]

4. Navegación:
   move_towards(doorBed3)  [bedroom3 → hallway]
   patience(50) → patience(49)

5. Siguiente iteración:
   atRoom(hallway)
   shortestRoomPath(hallway, kitchen, Path, 9)
   → Path = [doorKit2]
   move_towards(doorKit2)  [hallway → kitchen]
   patience(49) → patience(48)

6. Llegada:
   atRoom(kitchen) & atRoom(kitchen, kitchen)
   → Mismo cuarto
   → !resetPatience → patience(50)
```

**Owner buscando sofá dentro de livingroom:**

```
1. owner ejecuta: !moveTowardsAdvanced(sofa)

2. movement.asl:
   atRoom(livingroom) & atRoom(sofa, livingroom)
   → Misma habitación
   → move_towards(sofa)

3. Entorno Java:
   Calcula vector: agente(x=10,y=5) → sofa(x=8,y=6)
   Mueve: (10,5) → (9,5) [acercándose]

4. Repetición:
   Continúa hasta at(owner, sofa)
```

---

**Conclusión:**

La librería `movement.asl` representa un diseño sofisticado que combina teoría de grafos, algoritmos de búsqueda clásicos y manejo robusto de errores. Su arquitectura modular permite que múltiples agentes naveguen de forma autónoma y eficiente en un entorno complejo, demostrando principios avanzados de ingeniería de software en sistemas multi-agente.

```asl
+!goToRoom(ObjectiveRoom):
    atRoom(CurrentRoom) &
    numberOfDoors(MaxDepth) &
    shortestRoomPath(CurrentRoom, ObjectiveRoom, Path, MaxDepth)
    <-
    .nth(0, Path, FirstDoor);  // Extrae primera puerta
    // Detección de bloqueo en puerta
    if (atDoor) { +wasAtDoor; } else { -wasAtDoor; };
    move_towards(FirstDoor);
    if (atDoor & wasAtDoor) { 
        !unstuckFromDoor;  // Mecanismo anti-bloqueo
    };
    !reducePatience;
    -wasAtDoor.
```

**Mecanismo anti-bloqueo:**
- Detecta si ya estaba en una puerta antes de moverse
- Si sigue en puerta después de moverse, está bloqueado
- Activa procedimiento de desbloqueo

**3. Desbloqueo de Puertas (`!unstuckFromDoor`)**

```asl
+!unstuckFromDoor <-
    !moveRandomly;
    if (atDoor) { !unstuckFromDoor; };  // Recursión hasta salir
```

**4. Movimiento Aleatorio (`!moveRandomly`)**

```asl
+!moveRandomly <-
    .my_name(Me);
    .random(R);  // Genera número aleatorio [0, 1)
    if (R < 0.25) { moveLeft(Me); }
    else { if (R < 0.5) { moveRight(Me); }
    else { if (R < 0.75) { moveUp(Me); }
    else { moveDown(Me); }; }; }.
```

Distribución uniforme: 25% probabilidad por dirección.

**5. Movimiento Confinado a Habitación (`!moveRandomlyNoExit`)**

Similar a `moveRandomly` pero usa variantes `NoExit`:
```asl
!moveLeftNoExit;  !moveRightNoExit;
!moveUpNoExit;    !moveDownNoExit;
```

**6. Movimientos Direccionales Confinados**

Ejemplo: `!moveDownNoExit` con tracking de posición:

```asl
+!moveDownNoExit:
    .my_name(Me) & atRoom(CurrentRoom) & height(H)
    <-
    moveDown(Me);
    if (not atRoom(CurrentRoom) | atDoor) {
        moveUp(Me);      // Revierte movimiento
        -height(H);
        +height(0);      // Marca límite alcanzado
    } else {
        -height(H);
        +height(H-1);    // Decrementa contador
    }.
```

**Tracking de posición relativa:**
- Mantiene contador `height(N)` y `width(N)`
- Si sale de habitación o llega a puerta: revierte y marca límite (0)
- Si movimiento válido: actualiza contador

**Caso sin tracking inicial:**
```asl
+!moveDownNoExit:
    .my_name(Me) & atRoom(CurrentRoom) & not height(H)
    <- moveDown(Me);
       if (not atRoom(CurrentRoom) | atDoor) { moveUp(Me); }.
```

Simplemente revierte si sale, sin tracking numérico.

**Sistema de Paciencia Anti-Bucles:**

```asl
originalPatience(50).
patience(50).

+!reducePatience: patience(P) <-
    -patience(P); +patience(P-1).

+patience(0) <-
    !moveRandomly;
    .println("Patience exhausted, moving randomly.");
    !resetPatience.

+!resetPatience: originalPatience(OP) <-
    -patience(_); +patience(OP).
```

**Funcionamiento:**
- Cada intento de navegación reduce paciencia
- Al llegar a 0: movimiento aleatorio forzado
- Previene bucles infinitos si pathfinding falla
- Se resetea al completar objetivos

**Ventajas del Diseño:**

- **Completo**: Encuentra ruta si existe
- **Óptimo**: Prefiere rutas más cortas
- **Robusto**: Maneja bloqueos y casos límite
- **Reutilizable**: Compartido por robot y owner
- **Eficiente**: Limita búsqueda con MaxDepth

---

## 2. Entorno Java

El entorno Java actúa como puente entre los agentes AgentSpeak y el mundo simulado, implementando el patrón **Modelo-Vista-Controlador** distribuido en tres componentes principales.

### **HouseModel.java - Lógica del Mundo Simulado**

**Arquitectura del Modelo:**

Este componente extiende `GridWorldModel` de Jason y mantiene el estado completo de la simulación en un grid de **24×12 celdas** (288 posiciones totales).

**Sistema de Representación de Objetos:**

Los objetos se codifican mediante constantes de bits para permitir múltiples objetos por celda:

```java
public static final int CHAIR = 8;      // 0b00001000
public static final int SOFA = 16;      // 0b00010000
public static final int FRIDGE = 32;    // 0b00100000
public static final int DOOR = 128;     // 0b10000000
public static final int CHARGER = 256;  // 0b100000000
public static final int BED = 1024;     // 0b10000000000
public static final int DIRTY = 2048;   // 0b100000000000
```

Esta codificación permite operaciones bitwise para verificar múltiples objetos en una celda:
```java
if ((cell & CHAIR) != 0 && (cell & DIRTY) != 0) {
    // Hay una silla Y suciedad en esta posición
}
```

**Definición de Áreas (Habitaciones):**

Cada habitación se define mediante la clase `Area` con coordenadas rectangulares:

```java
Area kitchen = new Area(0, 0, 6, 6);              // Esquina superior izquierda
Area livingroom = new Area(4, 6, 12, 11);         // Centro-derecha
Area hallway = new Area(7, 5, 23, 5);             // Pasillo horizontal
Area bedroom1 = new Area(13, 6, 20, 11);          // Esquina inferior derecha
Area bath1 = new Area(8, 0, 11, 4);               // Superior centro
// ... etc. (9 habitaciones totales)
```

**Método clave `getRoom(Location)`:**

```java
String getRoom(Location thing) {
    String byDefault = "kitchen";
    if (bath1.contains(thing)) { byDefault = "bath1"; }
    if (bedroom1.contains(thing)) { byDefault = "bedroom1"; }
    // ... verifica todas las áreas
    return byDefault;
}
```

Este método traduce coordenadas (x,y) a nombres de habitaciones que los agentes pueden razonar.

**Gestión de Estado de Suciedad:**

```java
Map<String, Integer> dirtyRooms = new HashMap<>();
// Almacena: "kitchen" → 3, "bedroom1" → 5, etc.
```

- **`addDirty(Location loc)`**: Incrementa contador de habitación
- **`clean(int Ag)`**: Decrementa contador y elimina DIRTY del grid
- Permite percepciones `dirty(Room)` solo si contador > 0

**Hilos de Generación Dinámica:**

**Thread 1: Generación de Suciedad**
```java
Thread dirtyPlaces = new Thread(() -> {
    while (true) {
        createDirtyPlaces();  // Crea DirtyPlacesNumber manchas
        Thread.sleep(30000);   // Cada 30 segundos
    }
});
```

**Thread 2: Aparición de Intrusos**
```java
Thread intruder = new Thread(() -> {
    while (true) {
        createIntruder();      // Coloca intruso en posición aleatoria
        Thread.sleep(40000);   // Cada 40 segundos
        // Intruso permanece 30 segundos antes de desaparecer
    }
});
```

**Algoritmo de Movimiento (`moveTowards`):**

```java
boolean moveTowards(int Ag, Location dest) {
    Location r1 = getAgPos(Ag);
    
    // Fase 1: Movimiento óptimo en ambos ejes
    if (r1.x < dest.x && canMoveTo(Ag, r1.x + 1, r1.y)) {
        r1.x++;  // Avanza hacia la derecha
    } else if (r1.x > dest.x && canMoveTo(Ag, r1.x - 1, r1.y)) {
        r1.x--;  // Avanza hacia la izquierda
    }
    
    if (r1.y < dest.y && canMoveTo(Ag, r1.x, r1.y + 1)) {
        r1.y++;  // Avanza hacia abajo
    } else if (r1.y > dest.y && canMoveTo(Ag, r1.x, r1.y - 1)) {
        r1.y--;  // Avanza hacia arriba
    }
    
    // Fase 2: Desbloqueo si no pudo moverse
    if (r1 == r2 && r1.distance(dest) > 0) {
        // Intenta movimiento perpendicular para rodear obstáculo
        if (r1.x == dest.x && canMoveTo(Ag, r1.x + 1, r1.y)) {
            r1.x++;  // Desplazamiento lateral
        }
        // ... otras direcciones
    }
    
    setAgPos(Ag, r1);
    return true;
}
```

Este algoritmo implementa navegación **greedy con recuperación ante obstáculos**.

**Restricciones de Movimiento por Agente:**

```java
boolean canMoveTo(int Ag, int x, int y) {
    if (Ag < 1) {  // Robot (Ag=0)
        return isFree(x, y) && !hasObject(FRIDGE, x, y) 
            && !hasObject(TABLE, x, y) && !hasObject(SOFA, x, y);
    } else {  // Owner/Intruso (Ag≥1)
        return isFree(x, y) && !hasObject(FRIDGE, x, y)
            && !hasObject(CHARGER, x, y) && !hasObject(TABLE, x, y);
    }
}
```

El robot **no puede atravesar** sofás/sillas (debe rodearlos), pero el propietario **puede sentarse** en ellos.

---

### **HouseEnv.java - Interfaz Jason-Entorno**

**Arquitectura:**

Extiende `Environment` de Jason e implementa el ciclo **percepción-acción** del framework BDI.

**Generación de Percepciones:**

Método principal ejecutado cada ciclo de razonamiento:

```java
@Override
public List<Literal> getPercepts(String agName) {
    List<Literal> percepts = new ArrayList<>();
    
    // Percepción 1: Habitación actual
    Location agPos = model.getAgPos(agentId);
    String room = model.getRoom(agPos);
    percepts.add(Literal.parseLiteral("atRoom(" + room + ")"));
    
    // Percepción 2: Habitaciones sucias
    for (String roomName : model.dirtyRooms.keySet()) {
        if (model.dirtyRooms.get(roomName) > 0) {
            percepts.add(Literal.parseLiteral("dirty(" + roomName + ")"));
        }
    }
    
    // Percepción 3: Proximidad a objetos/agentes
    if (agPos.isNeighbour(model.lFridge)) {
        percepts.add(Literal.parseLiteral("at(" + agName + ", fridge)"));
    }
    
    // Percepción 4: En puerta
    if (model.hasObject(HouseModel.DOOR, agPos)) {
        percepts.add(Literal.parseLiteral("atDoor"));
    }
    
    return percepts;
}
```

**Ejecución de Acciones:**

```java
@Override
public boolean executeAction(String agName, Structure action) {
    String actionName = action.getFunctor();
    
    switch (actionName) {
        case "clean":
            model.clean(getAgentId(agName));
            return true;
            
        case "move_towards":
            Location dest = parseLocation(action.getTerm(0));
            model.moveTowards(getAgentId(agName), dest);
            return true;
            
        case "sit":
            String furniture = action.getTerm(0).toString();
            Location furnitureLoc = model.getFurnitureLocation(furniture);
            model.sit(getAgentId(agName), furnitureLoc);
            return true;
            
        case "alert":
            String message = action.getTerm(0).toString();
            JOptionPane.showMessageDialog(null, message);
            return true;
    }
    
    return false;  // Acción no reconocida
}
```

**Ciclo de Actualización:**

```java
// Ejecutado automáticamente por Jason cada ~100ms
1. getPercepts() → Genera lista de percepciones para cada agente
2. Jason ejecuta razonamiento BDI con nuevas percepciones
3. executeAction() → Procesa acciones decididas por agentes
4. updateView() → Actualiza visualización gráfica
```

---

### **HouseView.java - Visualización Gráfica**

**Arquitectura:**

Extiende `GridWorldView` de Jason y usa **Java Swing** para renderizado.

**Sistema de Renderizado:**

```java
@Override
public void draw(Graphics g, int x, int y, int object) {
    switch (object) {
        case HouseModel.BED:
            if (hmodel.lBed1.equals(loc)) {
                drawMultipleScaledImage(g, x, y, "/doc/doubleBedlt.png", 2, 2, 100, 100);
            }
            break;
            
        case HouseModel.DOOR:
            if (robotNearby || ownerNearby) {
                drawScaledImage(g, x, y, "/doc/openDoor2.png", 75, 100);
            } else {
                drawScaledImage(g, x, y, "/doc/closeDoor2.png", 75, 100);
            }
            break;
    }
}
```

**Renderizado de Agentes:**

```java
@Override
public void drawAgent(Graphics g, int x, int y, Color c, int id) {
    if (id == 0) {  // Robot
        drawImage(g, x, y, "/doc/bot.png");
    } else if (id == 1) {  // Owner
        if (lOwner.equals(hmodel.lBed1)) {
            drawMultipleScaledMan(g, x, y, "right");  // Durmiendo
        } else if (lOwner.equals(hmodel.lChair1)) {
            drawMan(g, x, y, "left");  // Sentado mirando izquierda
        }
    } else if (id == 2) {  // Intruso
        drawMan(g, x, y, "walkf");
    }
}
```

**Thread de Actualización:**

```java
Thread refresh = new Thread(() -> {
    while (true) {
        update();           // Redibuja todo el grid
        Thread.sleep(481);  // ~2 FPS
    }
});
```

**Escalado Adaptativo:**

```java
public HouseView(HouseModel model) {
    int screenWidth = Toolkit.getDefaultToolkit().getScreenSize().width;
    int screenHeight = Toolkit.getDefaultToolkit().getScreenSize().height;
    setSize(screenWidth * 3/7, screenHeight * 3/7);  // 43% de pantalla
}
```

**Recursos Visuales:**

- **22 imágenes PNG** en `/doc/`: bot.png, sitr.png, openDoor2.png, etc.
- Cargadas dinámicamente: `getClass().getResource("/doc/bot.png")`
- Escaladas según tamaño de celda: `cellSizeW × scaleW / 100`

---

### **Interacción entre Componentes:**

```
┌─────────────┐
│   Agentes   │ (robot.asl, owner.asl)
│  AgentSpeak │
└──────┬──────┘
       │ Percepciones: dirty(kitchen), at(robot, fridge)
       │ Acciones: clean(robot), move_towards(bed1)
       ▼
┌─────────────┐
│ HouseEnv    │ (Traductor Jason↔Java)
│  .java      │
└──────┬──────┘
       │ Llamadas: model.clean(0), model.moveTowards(0, loc)
       │ Consultas: model.getRoom(loc), model.dirtyRooms
       ▼
┌─────────────┐
│ HouseModel  │ (Estado del mundo)
│  .java      │ Grid 24×12, objetos, agentes
└──────┬──────┘
       │ Estado: posiciones, suciedad, muebles
       │ Eventos: Thread dirtyPlaces, Thread intruder
       ▼
┌─────────────┐
│ HouseView   │ (Renderizado gráfico)
│  .java      │ Swing GUI, 481ms refresh
└─────────────┘
```

**Flujo completo de un ciclo:**

1. **Modelo genera evento**: Thread crea suciedad en (15,8)
2. **Modelo actualiza**: `dirtyRooms.put("bedroom1", 3)`
3. **Env genera percepción**: `dirty(bedroom1)` para robot
4. **Robot razona**: `+dirty(bedroom1) <- !cleaningLoop`
5. **Robot ejecuta acción**: `move_towards(doorBed1)`
6. **Env traduce**: `model.moveTowards(0, lDoorBed1)`
7. **Modelo actualiza**: Cambia posición robot de (22,9) → (21,9)
8. **Vista renderiza**: Dibuja robot en nueva posición cada 481ms

---

### 3. Acciones Internas Java

#### **time.check**
Acción interna para obtener la hora actual:
```java
public Object execute(TransitionSystem ts, Unifier un, Term[] args) {
    String time = (new SimpleDateFormat("HH:mm:ss")).format(new Date());
    return un.unifies(args[0], new StringTermImpl(time));
}
```

**Uso en AgentSpeak:**
```asl
time.check(CurrentTime);  // Unifica CurrentTime con hora actual
.print("Hora actual: ", CurrentTime);
```

#### **bot.chat** (experimental)
Integración con OpenAI para respuestas conversacionales:
- Utiliza la API de OpenAI (modelo Ada)
- Permite al robot generar respuestas textuales
- **Nota**: Requiere configuración de API key en el código fuente

**Uso previsto:**
```asl
bot.chat("Hello", Response);  // Genera respuesta conversacional
```

---

## Requisitos del Sistema

### Dependencias

- **Java Development Kit (JDK)**: Versión 8 o superior
- **Jason Framework**: Versión 3.3.0 o superior
- **Entorno de Desarrollo**: 
  - Eclipse con plugin Jason, o
  - IntelliJ IDEA con soporte para proyectos Jason, o
  - Visual Studio Code con extensión Jason
- **Librerías adicionales**: Incluidas en la carpeta `lib/`

### Especificaciones Técnicas

- **Lenguaje de agentes**: AgentSpeak (Jason)
- **Lenguaje de entorno**: Java 8+
- **Framework GUI**: Java Swing
- **Arquitectura**: Sistema Multi-Agente basado en BDI (Belief-Desire-Intention)

## Instalación y Configuración

### Pasos de Instalación

1. **Clonar o descargar el proyecto**
   ```bash
   git clone <repository-url>
   cd domestic_robot
   ```

2. **Verificar instalación de Jason**
   ```bash
   jason --version
   ```

3. **Configurar el IDE**
   - Importar el proyecto como proyecto Jason
   - Verificar que `jason.jar` esté en el classpath
   - Confirmar que la carpeta `lib/` contiene todas las dependencias

4. **Compilar el proyecto**
   - El IDE compilará automáticamente los archivos `.asl` y `.java`
   - Verificar que no hay errores de compilación

### Ejecución del Sistema

**Modo con Interfaz Gráfica (recomendado):**
```bash
jason DomesticRobot.mas2j
```

**Modo Consola (sin GUI):**

Modificar el archivo `DomesticRobot.mas2j`:
```jason
environment: domotic.HouseEnv(nogui)
```

Luego ejecutar:
```bash
jason DomesticRobot.mas2j
```

### Configuración de Logs

Editar `logging.properties` para ajustar verbosidad:

```properties
.level = INFO          # Cambiar a FINE para debug detallado
jason.runtime.MASConsoleLogHandler.tabbed = true
jason.runtime.MASConsoleLogHandler.colors = true
```

## Diagrama de Interacciones

```
┌─────────────┐          ┌──────────────┐
│    Robot    │◄────────►│  HouseEnv    │
│             │          │              │
│ - Limpia    │          │ - Percepciones│
│ - Navega    │          │ - Acciones   │
│ - Alerta    │          │              │
└─────┬───────┘          └───────┬──────┘
      │                          │
      │ intruderDetected         │ dirty(Room)
      │                          │ at(X,Y)
      ▼                          ▼
┌─────────────┐          ┌──────────────┐
│    Owner    │          │  HouseModel  │
│             │          │              │
│ - Se mueve  │          │ - Grid 24x12 │
│ - Se sienta │◄────────►│ - Objetos    │
│ - Recibe    │          │ - Agentes    │
│   alertas   │          │              │
└─────────────┘          └──────────────┘
```

## Posibles Extensiones y Mejoras

### Líneas de Investigación Futuras

#### 1. Inteligencia Artificial Avanzada
   - **Aprendizaje automático**: Implementación de algoritmos de aprendizaje por refuerzo para optimizar patrones de limpieza
   - **Predicción de suciedad**: Modelo predictivo basado en históricos para anticipar áreas que requieren limpieza
   - **Optimización de rutas**: Algoritmos genéticos o A* para minimizar tiempo de desplazamiento
   - **Modelado de preferencias**: Aprendizaje del comportamiento del propietario para minimizar interrupciones

#### 2. Funcionalidades del Hogar Inteligente
   - **Control de electrodomésticos**: Integración con lavadora, horno y otros dispositivos
   - **Gestión de inventario**: Monitorización del contenido de la nevera con sistema de reabastecimiento
   - **Automatización de pedidos**: Agente repartidor completamente funcional con integración a APIs de supermercados
   - **Sistema domótico**: Control de iluminación, climatización y seguridad

#### 3. Comunicación e Interfaces
   - **Procesamiento de lenguaje natural**: Integración completa con modelos de IA (GPT-4, Claude) para comandos conversacionales
   - **Comandos de voz**: Reconocimiento de voz mediante APIs de Google o Amazon
   - **Interfaz web**: Dashboard de control remoto con tecnologías web modernas (React, WebSockets)
   - **Aplicación móvil**: Control desde smartphone con notificaciones push

#### 4. Simulación Realista
   - **Modelo energético**: Simulación de consumo y carga de batería del robot
   - **Ciclo circadiano**: Alternancia día/noche que afecta comportamiento de agentes
   - **Eventos estocásticos**: Averías, visitas de invitados, emergencias
   - **Física del entorno**: Simulación de obstáculos dinámicos y colisiones

#### 5. Arquitectura Multi-Agente Avanzada
   - **Coordinación entre robots**: Múltiples robots colaborando en la limpieza
   - **Mercado de tareas**: Asignación de tareas mediante subastas entre agentes
   - **Formación de coaliciones**: Agrupación dinámica para tareas complejas
   - **Negociación**: Resolución de conflictos mediante protocolos de negociación

## Estructura de Percepciones

### Percepciones del Robot

| Percepción | Descripción | Ejemplo |
|------------|-------------|---------|
| `atRoom(Room)` | Habitación actual | `atRoom(kitchen)` |
| `at(robot, Object)` | Proximidad a objeto | `at(robot, charger)` |
| `dirty(Room)` | Habitación sucia | `dirty(bedroom1)` |
| `at(robot, dirty)` | En celda sucia | - |
| `at(robot, intruder)` | Intruso detectado | - |
| `atDoor` | En una puerta | - |

### Percepciones del Owner

| Percepción | Descripción | Ejemplo |
|------------|-------------|---------|
| `atRoom(Room)` | Habitación actual | `atRoom(livingroom)` |
| `at(owner, Object)` | En/cerca de mueble | `at(owner, sofa)` |
| `at(owner, robot)` | Cerca del robot | - |
| `intruderDetected[source(robot)]` | Alerta recibida | - |

## Competencias Técnicas Requeridas

### Conocimientos Fundamentales

Para comprender, modificar y extender este proyecto, se requiere familiaridad con los siguientes conceptos:

#### Sistemas Multi-Agente
- **Arquitectura BDI**: Modelo Belief-Desire-Intention implementado en Jason
- **Comunicación inter-agente**: Paso de mensajes mediante actos de habla (FIPA)
- **Coordinación**: Mecanismos de cooperación y resolución de conflictos
- **Razonamiento reactivo y deliberativo**: Balance entre respuesta inmediata y planificación

#### AgentSpeak y Jason
- **Sintaxis AgentSpeak**: Planes, creencias, objetivos, eventos
- **Ciclo de razonamiento**: Selección de eventos, opciones aplicables, intenciones
- **Acciones internas**: Implementación de acciones Java desde AgentSpeak
- **Percepciones y acciones**: Interacción con el entorno mediante HouseEnv

#### Programación Lógica
- **Unificación**: Mecanismo fundamental de matching de patrones
- **Backtracking**: Exploración de soluciones alternativas
- **Prolog**: Base teórica de AgentSpeak
- **Lógica de primer orden**: Representación de conocimiento

#### Programación Java
- **Programación orientada a objetos**: Herencia, polimorfismo, encapsulación
- **Java Swing**: Desarrollo de interfaces gráficas
- **Concurrencia**: Threads, sincronización, condiciones de carrera
- **Patrones de diseño**: Observer, MVC aplicados al entorno

#### Algoritmos y Estructuras de Datos
- **Grafos**: Representación de conectividad entre habitaciones
- **Búsqueda en grafos**: BFS, DFS, pathfinding
- **Algoritmos de cobertura**: Patrones de barrido espacial
- **Optimización**: Heurísticas para toma de decisiones

## Resolución de Problemas

### Diagnóstico y Soluciones

#### Error: Jason no encontrado o no se puede ejecutar

**Síntomas:**
- Comando `jason` no reconocido
- Error de ClassNotFoundException al ejecutar

**Soluciones:**
1. Verificar que Jason esté correctamente instalado:
   ```bash
   jason --version
   ```
2. Añadir `jason.jar` al classpath del sistema
3. En IDE, configurar Jason como librería del proyecto
4. Verificar variable de entorno `JASON_HOME`

#### La Interfaz Gráfica no se muestra

**Síntomas:**
- El sistema arranca pero no aparece ventana
- Error relacionado con display o headless mode

**Soluciones:**
1. Verificar parámetro en `DomesticRobot.mas2j`:
   ```jason
   environment: domotic.HouseEnv(gui)
   ```
2. Comprobar compatibilidad de Swing en el sistema operativo
3. Si está en servidor sin GUI, usar modo `nogui`
4. Verificar que no está en modo headless de Java:
   ```bash
   java -Djava.awt.headless=false
   ```

#### El Robot no realiza limpieza

**Síntomas:**
- Robot se mueve pero no limpia
- No se detectan habitaciones sucias

**Diagnóstico:**
1. Revisar logs para verificar generación de suciedad:
   ```
   [INFO] Suciedad en (x, y)
   [INFO] En el bedroom1 hay N celdas sucias
   ```
2. Verificar percepciones del robot en consola Jason:
   ```asl
   dirty(bedroom1)
   ```
3. Comprobar que el thread `dirtyPlaces` está activo
4. Validar pathfinding entre habitaciones con logs de navegación

**Soluciones:**
- Aumentar nivel de logging en `logging.properties` a `FINE`
- Revisar implementación de `chooseRoomToClean`
- Verificar que `shortestRoomPath` encuentra rutas válidas

#### Imágenes no se cargan en la interfaz

**Síntomas:**
- Aparecen cuadrados vacíos en lugar de sprites
- Console muestra "Could not find image!"

**Soluciones:**
1. Verificar que la carpeta `src/main/resources/doc/` existe y contiene:
   - `bot.png`, `beerBot.png`
   - `sofa.png`, `table.png`
   - `singleBed.png`, `doubleBedlt.png`
   - `chairU.png`, `chairD.png`, `chairL.png`
   - `openDoor2.png`, `closeDoor2.png`
   - Todas las imágenes de personas (sit*, walk*)
2. Comprobar rutas relativas en `HouseView.java` (deben comenzar con `/doc/`)
3. Asegurar que las imágenes están incluidas en el build del proyecto
4. Verificar permisos de lectura de los archivos

#### Errores de concurrencia o deadlocks

**Síntomas:**
- El sistema se congela
- Excepciones relacionadas con threads

**Soluciones:**
1. Reducir frecuencia de threads en `HouseModel.java`:
   ```java
   Thread.sleep(40000); // Aumentar tiempo entre eventos
   ```
2. Verificar sincronización en métodos de acceso al modelo
3. Revisar logs para detectar ciclos infinitos en planes AgentSpeak

#### Rendimiento degradado

**Síntomas:**
- Respuesta lenta del sistema
- Alto uso de CPU

**Optimizaciones:**
1. Reducir frecuencia de actualización en `HouseView`:
   ```java
   Thread.sleep(500); // Aumentar de 481ms
   ```
2. Limitar profundidad de búsqueda en pathfinding
3. Optimizar número de celdas sucias generadas:
   ```java
   DirtyPlacesNumber = GSize * GSize / 30; // Reducir cantidad
   ```

## Referencias Bibliográficas

### Framework y Teoría

- Bordini, R. H., Hübner, J. F., & Wooldridge, M. (2007). *Programming Multi-Agent Systems in AgentSpeak using Jason*. John Wiley & Sons.
- Rao, A. S., & Georgeff, M. P. (1995). BDI Agents: From Theory to Practice. *Proceedings of the First International Conference on Multi-Agent Systems (ICMAS-95)*, 312-319.
- Wooldridge, M. (2009). *An Introduction to MultiAgent Systems* (2nd ed.). John Wiley & Sons.

### Documentación Técnica

- Jason Official Documentation: http://jason.sourceforge.net/
- Jason API Reference: http://jason.sourceforge.net/api/
- AgentSpeak(L) Language Specification

### Algoritmos Implementados

- Dijkstra, E. W. (1959). A note on two problems in connexion with graphs. *Numerische Mathematik*, 1(1), 269-271.
- Hart, P. E., Nilsson, N. J., & Raphael, B. (1968). A Formal Basis for the Heuristic Determination of Minimum Cost Paths. *IEEE Transactions on Systems Science and Cybernetics*, 4(2), 100-107.

## Información del Proyecto

### Metadatos

- **Institución**: Universidade de Vigo
- **Departamento**: Sistemas Multi-Agente
- **Contexto**: Proyecto educativo para el curso de Agentes Inteligentes
- **Framework**: Jason 3.3.0
- **Lenguaje**: AgentSpeak(L) y Java 8+
- **Tipo de licencia**: Académica

### Estructura del Repositorio

```
domestic_robot/
├── README.md                     # Este archivo
├── DomesticRobot.mas2j          # Configuración principal del MAS
├── logging.properties            # Configuración del sistema de logs
├── lib/                         # Librerías de Jason
├── src/
│   ├── agt/                     # Agentes en AgentSpeak
│   └── main/                    # Código Java del entorno
└── doc/                         # Recursos gráficos (imágenes)
```

### Contacto y Contribuciones

Para preguntas, sugerencias o reportar problemas:

1. Revisar la sección de [Resolución de Problemas](#resolución-de-problemas)
2. Consultar la documentación oficial de Jason
3. Contactar con el equipo docente del curso

---

**Versión del documento**: 2.0  
**Fecha de última actualización**: Noviembre 14, 2025  
**Estado del proyecto**: Completado y funcional
