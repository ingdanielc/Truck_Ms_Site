# Peajes por ruta — contrato

`POST /trip/tolls` devuelve las estaciones de peaje que atraviesa un trayecto y
lo que cuesta cada una para el vehículo indicado.

Es una **consulta**: no crea ni modifica el viaje y no deja rastro. Va por POST
porque el trazado de la ruta viaja en el cuerpo y codificado son decenas de
miles de caracteres, muy por encima de lo que cabe en una URL.

El backend **no calcula rutas**. El front ya resolvió el trazado con Google y lo
reenvía codificado; aquí solo se decodifica, se pregunta qué estaciones del
catálogo caen sobre él y se les pone precio. Eso evita una segunda llamada
facturada al proveedor y garantiza que el cobro salga de la misma ruta que el
usuario está viendo pintada en el mapa.

---

## 1. Cabeceras

```
X-API-KEY: <llave>
Content-Type: application/json
```

Las mismas que el resto de `/trip`.

---

## 2. Cuerpo

| Campo | Tipo | Obligatorio | Nota |
| --- | --- | --- | --- |
| `origin.lat` / `origin.lng` | number | sí | Grados decimales |
| `origin.cityId` | int | no | Solo para relacionar con el maestro de ciudades; no se usa para ubicar peajes |
| `destination.lat` / `destination.lng` | number | sí | |
| `destination.cityId` | int | no | |
| `returnDestination` | objeto | solo si `tripType` es `REDONDO` | Mismo formato que `origin` |
| `vehicleId` | long | sí | De él salen los ejes y con ellos la categoría |
| `travelDate` | string `yyyy-MM-dd` | no | Por defecto, hoy. Decide qué tarifa aplica |
| `tripType` | enum | no | `CARGADO`, `REDONDO` o `VACIO`. Por defecto `CARGADO` |
| `route` | objeto | **no** | Ver abajo |
| `route.provider` | string | no | Se devuelve tal cual, para trazabilidad |
| `route.encodedPolyline` | string | no | `overview_polyline` de Google |
| `route.distanceMeters` | long | no | Si no llega, se calcula sobre la polilínea |

### `route` es opcional a propósito

Si Google no devolvió trazado utilizable, el front omite el bloque completo y el
endpoint **responde igual** en modo degradado. La pantalla nunca se queda sin
respuesta por un fallo del proveedor de mapas.

### Ejemplo

```json
{
  "origin":      { "lat": 4.711, "lng": -74.072, "cityId": 149 },
  "destination": { "lat": 6.244, "lng": -75.581, "cityId": 620 },
  "vehicleId": 123,
  "travelDate": "2026-09-07",
  "tripType": "CARGADO",
  "route": {
    "provider": "GOOGLE_ROUTES",
    "encodedPolyline": "yzpjBt~gs@...",
    "distanceMeters": 417300
  }
}
```

---

## 3. Respuesta

Envuelta en el `ResponseMessage` habitual; lo que sigue es el contenido de
`data`.

```json
{
  "route": {
    "mode": "POLYLINE",
    "provider": "GOOGLE_ROUTES",
    "distanceKm": 417.3,
    "durationMinutes": 522,
    "matchToleranceKm": 2.0
  },
  "vehicle": {
    "id": 123,
    "numberOfAxles": 5,
    "tollCategories": { "OETR_7": "VI", "INVIAS_5": "IV" }
  },
  "tolls": [
    {
      "id": 15,
      "name": "Peaje A",
      "department": "Cundinamarca",
      "municipality": "Villeta",
      "rateScheme": "OETR_7",
      "category": "VI",
      "amount": 91600,
      "rateStatus": "VIGENTE",
      "leg": null,
      "distanceFromRouteKm": 0.34
    },
    {
      "id": 27,
      "name": "Peaje B",
      "department": "Antioquia",
      "municipality": "Caldas",
      "rateScheme": "INVIAS_5",
      "category": "IV",
      "amount": 43700,
      "rateStatus": "VIGENTE",
      "leg": null,
      "distanceFromRouteKm": 0.12
    }
  ],
  "total": 135300,
  "warnings": []
}
```

| Campo | Nota |
| --- | --- |
| `route.mode` | `POLYLINE` o `CORRIDOR`. Ver sección 4 |
| `route.durationMinutes` | La estima el backend: el front envía distancia pero no tiempo |
| `route.matchToleranceKm` | A qué distancia de la ruta se aceptó un peaje |
| `tolls[]` | En el orden en que el camión los encuentra, no alfabético |
| `vehicle.tollCategories` | Categoría del vehículo **en cada escala**. No hay un valor único; ver sección 7 |
| `tolls[].rateScheme` | Escala tarifaria de esa estación: `OETR_7` o `INVIAS_5` |
| `tolls[].category` | Categoría aplicada, dentro de la escala de esa estación |
| `tolls[].amount` | `null` si la estación no tiene tarifa cargada para esa categoría |
| `tolls[].rateStatus` | `VIGENTE`, `VENCIDA` o `SIN_TARIFA` |
| `tolls[].leg` | `IDA` o `REGRESO`; solo se informa en viaje redondo |
| `total` | Suma de los `amount`. Las estaciones sin tarifa **no** suman |
| `warnings[]` | Texto para mostrar al usuario. Ver sección 6 |

### Viaje redondo

El front pide ida y regreso en una sola ruta, con el destino como punto
intermedio, así que llega **una sola polilínea** que cubre los dos tramos. El
backend la parte por el vértice más cercano al destino, que es donde el camión
da la vuelta: hasta ahí es `IDA`, de ahí en adelante `REGRESO`.

Un peaje que está en los dos tramos **aparece dos veces** y suma dos veces al
total, porque se paga dos veces.

---

## 4. Modos

| Modo | Cuándo | Qué tan confiable |
| --- | --- | --- |
| `POLYLINE` | Llegó `route.encodedPolyline` y se pudo decodificar | Sigue la carretera real. Tolerancia de 2 km |
| `CORRIDOR` | No llegó trazado, o el recibido no era decodificable | Aproxima con la recta origen-destino. Corredor de 30 km y distancia inflada por un factor de sinuosidad |

En modo `CORRIDOR` la respuesta siempre trae un `warning` diciéndolo. Es una
estimación orientativa: puede incluir peajes que la ruta no toca y perder otros
que sí.

---

## 5. Códigos de estado

| Código | Cuándo |
| --- | --- |
| `200` | Cotización resuelta, incluso si `tolls` viene vacío |
| `400` | Faltan coordenadas, están fuera de rango, falta `vehicleId`, falta el destino de regreso en un redondo, o el vehículo no tiene ejes registrados. El mensaje es mostrable al usuario |
| `404` | El `vehicleId` no existe |
| `413` | `route.encodedPolyline` supera los 200.000 caracteres. Reintentar **sin** el bloque `route` |
| `500` | Error inesperado |

El front ya recorta en 200.000 antes de enviar, así que el 413 no debería verse
en la práctica: es la defensa del servidor frente a otro consumidor.

---

## 6. `warnings`

Texto listo para mostrar. Es lo que explica por qué un total puede no ser
definitivo:

- Modo degradado: *"No se recibió el trazado de la ruta: la distancia y los peajes son una estimación sobre la línea recta del trayecto."*
- Tarifas vencidas: *"N peaje(s) se cotizaron con la última tarifa conocida, ya vencida a la fecha del viaje."*
- Sin tarifa: *"N peaje(s) de la ruta no tienen tarifa cargada para la categoría que les corresponde y no suman al total."*
- Supuesto de 2 ejes: *"N peaje(s) parten los camiones de dos ejes en dos categorías según el tamaño de la llanta trasera. Se aplicó la mayor, así que ese valor puede quedar por encima del real."*
- Catálogo incompleto: *"N estación(es) de peaje del catálogo no tienen coordenadas registradas y no se pueden ubicar sobre la ruta."*

Lo accionable —el modo y el estado de cada tarifa— además viaja tipado, así que
el front no necesita leer estos textos para ramificar lógica.

---

## 7. Categoría tarifaria

**La categoría no es un atributo del vehículo.** En Colombia conviven dos
escalas y el mismo número romano cobra cosas distintas en cada una. Un camión de
5 ejes es `VI` en unas estaciones y `IV` en otras.

| | Categorías | Origen |
| --- | --- | --- |
| `OETR_7` | I – VII | Operación Estadística de Tráfico y Recaudo (ANI) |
| `INVIAS_5` | I – V | Clasificación general de INVIAS |

### `OETR_7` — 7 categorías

| Cat. | Vehículo (texto oficial) |
| --- | --- |
| I | Automóviles, camperos, camionetas y minivan de dos ejes con eje trasero de una sola llanta |
| II | Buses pequeños, busetas, microbuses de dos ejes con eje trasero de doble llanta |
| III | Camiones y buses pequeños de dos ejes con eje trasero de doble llanta **pequeña** |
| IV | Camiones y buses grandes de dos ejes con eje trasero de doble llanta **grande** |
| V | Camiones y buses grandes de **tres y cuatro** ejes |
| VI | Camiones grandes de **cinco** ejes |
| VII | Camiones grandes de carga pesada de **seis ejes o más** |

### `INVIAS_5` — 5 categorías

| Cat. | Vehículo |
| --- | --- |
| I | Automóviles, camperos, camionetas y microbuses con eje de llanta sencilla |
| II | Buses, busetas, microbuses de eje trasero doble **y camiones de 2 ejes** |
| III | Pasajeros y carga de **3 y 4** ejes |
| IV | Carga de **5** ejes |
| V | Carga de **6** ejes |

### Mapeo que aplica el backend

| Ejes | `OETR_7` | `INVIAS_5` |
| --- | --- | --- |
| 2 | `IV` ⚠ | `II` |
| 3 – 4 | `V` | `III` |
| 5 | `VI` | `IV` |
| 6 o más | `VII` | `V` |

Un dato de ejes inválido o menor que 2 se trata como 2: la flota siempre es de
carga y bajar más daría la tarifa de un liviano.

### ⚠ El supuesto de los camiones de 2 ejes

`OETR_7` parte los camiones de 2 ejes en `III` (doble llanta pequeña) y `IV`
(doble llanta grande). **`numberOfAxles` no distingue una de otra.** Se aplica
`IV`, la mayor, y la respuesta lo advierte en `warnings`.

Es el único punto del cálculo que puede cobrar de más. Resolverlo requiere un
atributo nuevo del vehículo —tamaño de llanta trasera o peso bruto—, no más
lógica. Bajo `INVIAS_5` no existe la ambigüedad: 2 ejes es `II` y punto.

### De dónde sale la escala de cada estación

De `toll.rate_scheme`, que se deriva de las propias tarifas al cargar el
catálogo (`scripts/tolls_update_rate_scheme.sql`): si la estación publica
categoría `VII` es `OETR_7`; si no, `INVIAS_5`.

Se mira `VII` y no `VI` porque hay estaciones de escala corta que publican una
`VI` marginal casi igual a su `V` —Los Patios, La Cabaña y Sopó cobran 71.700 en
`V` y 72.100 en `VI`—; mirar `VI` las clasificaría mal.

La regla está verificada contra el reporte oficial de la ANI (OETR, corte junio
2026, en `docs/`): las estaciones que topan en `V` tienen un perfil de tarifas
corrido exactamente una posición respecto de las de escala completa —su `IV`
equivale al `VI` de las otras y su `V` al `VII`— y su categoría tope concentra
el 7,9 % del tráfico, el peso de una tractomula, contra el 3,1 % que mueve la
`V` de las estaciones de siete.

Cobertura tras la migración: **100 % para 5 y 6 ejes**. Solo `SAN LUIS DE
GACENO` y `UNISABANA` quedan sin tarifa, y únicamente para 2–4 ejes.

`vehicle.number_of_axles` es texto libre en la base, así que se lee el primer
número que aparezca: conviven `"3"` y `"3 ejes"`. Si no hay ningún número, la
petición se rechaza con 400 en vez de cotizar con un valor inventado.

Sobre la vigencia: una tarifa vencida se usa igual y se marca `VENCIDA`. `amount`
solo queda en `null` si la estación no tiene tarifa para la categoría que le
corresponde.

---

## 8. Configuración

En `application-dev.yml` y `application-qa.yml`, bajo `truck.tolls`. Los valores
por defecto del código son los mismos, así que el bloque puede faltar.

| Clave | Defecto | Qué controla |
| --- | --- | --- |
| `match-tolerance-km` | `2.0` | Distancia máxima al trazado real para dar un peaje por transitado |
| `corridor-km` | `30.0` | Ancho del corredor en modo degradado |
| `sinuosity-factor` | `1.4` | Cuánto más larga es la carretera que la recta, solo en modo degradado |
| `average-speed-kmh` | `48.0` | Velocidad promedio de carga con que se estima `durationMinutes` |
| `max-encoded-polyline-length` | `200000` | Tope del trazado; por encima, 413 |

---

## 9. Datos del catálogo

El emparejamiento es geográfico: para saber si una estación está sobre la ruta
hace falta saber dónde está.

Orden de carga:

1. `scripts/tolls_schema_and_data_with_coordinates_FINAL.sql` — 165 estaciones,
   159 georreferenciadas, y las tarifas.
2. `scripts/tolls_update_missing_coordinates.sql` — completa 4 de las 6 que
   faltan, con las coordenadas del script anterior
   (`cashtruck_tolls_schema_and_data_definitive.sql`). Deja el catálogo en
   **163 de 165 georreferenciadas**.
3. `scripts/tolls_update_rate_scheme.sql` — agrega `toll.rate_scheme` y clasifica
   cada estación en su escala tarifaria. **Sin este paso las tarifas se cobran
   mal**: ver sección 7.
4. `scripts/tolls_update_coordinates_chaparral_riogrande.sql` — completa las 2
   últimas estaciones sin georreferenciar. Requiere pegar 4 coordenadas a mano.

### Lo que queda pendiente

| Punto | Estado |
| --- | --- |
| `CHAPARRAL`, `RIO GRANDE` | Sin coordenadas en ninguna fuente pública. **Activas y de alto tráfico** (95.903 y 103.401 vehículos/mes según la ANI), así que no deben desactivarse. Mientras sigan en `NULL` no aparecen en ninguna ruta y su peaje falta del total. Script listo en el paso 4 |
| `ETD 10 850` | Activa y con tarifas, pero el script anterior la excluía por ser *"counting station, not a toll station"*. Hoy suma al total de cualquier viaje por Rumichaca – Pasto |
| Tarifas `VI` y `VII` | Solo las publican las estaciones `OETR_7`; en `INVIAS_5` esas categorías no existen. No es un hueco de datos |
| 2 ejes bajo `OETR_7` | Se aplica `IV` por supuesto de tamaño de llanta. Requiere un atributo nuevo del vehículo. Ver sección 7 |
| Vigencia | Todo el catálogo es del corte de junio de 2026 (`2026-06-01` a `2026-06-30`). Cualquier viaje posterior se cotiza marcado `VENCIDA` |

Las tres primeras están documentadas como bloques comentados dentro de
`tolls_update_missing_coordinates.sql`, con la consulta lista para ejecutar y la
razón por la que no se aplicó sola. Ninguna requiere cambios de código: al
cargar datos nuevos, esas estaciones pasan por sí solas a `VIGENTE` o a tarifa
propia.

### `toll_route`

No se usa en esta implementación. El emparejamiento se hace contra la geometría
de la ruta, que es lo que permite responder a un par de coordenadas arbitrario
sin mantener un catálogo previo de rutas.
