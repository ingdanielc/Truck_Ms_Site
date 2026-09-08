# Plan de implementación — Notificaciones Push (Web Push)

> **Revisión (2026-09-02):** los supuestos sobre el backend se contrastaron contra el código de la API. Se corrigieron el dialecto SQL, los tipos de evento, la matriz de canales de vencimientos, la firma de `createNotification`, el pool `@Async`, las transitivas de `web-push` y la nota de autenticación; y se agregó el puente `owner → users`, que faltaba. Las secciones de frontend (5, 6) no se revisaron.

> API: `https://truck.ccsoluciones.com.co` — **repositorio externo**, fuera de `Truck_Mf_Site`.
> Repos involucrados: `Truck_Mf_Single_Spa` (shell) · `Truck_Mf_Site` (MFE) · **API (backend)**

> ✅ **Stack verificado contra el repo de la API:** Spring Boot 3.3.2, JPA/Hibernate, Java 17, **MySQL/MariaDB**. La respuesta `{ data: { content: [], totalElements } }` la produce `ResponseMessage` con un `Page` dentro (`NotificationController.filter`). La autenticación **no** es la que se suponía: ver la advertencia del Paso 3.

---

## 0. Objetivo y regla de oro

Entregar notificaciones **instantáneas y gratuitas** a los usuarios en su celular, incluso con la app cerrada, sin desmontar el canal de WhatsApp existente.

**Regla de oro:** el push **no reemplaza** a WhatsApp ni a la tabla `notifications`. La notificación in-app sigue siendo la **fuente de verdad**; push y WhatsApp son dos **transportes** del mismo evento. Si el push falla o el usuario no está suscrito, el sistema debe comportarse exactamente como hoy.

**Orden de despliegue:** Backend (pasos 1-4) → Shell → Site → activación de envíos (paso 5). Detalle en la sección 7.

---

## 1. Estado actual (front verificado en los tres repos; backend verificado contra el código)

### Ya existe

| Requisito | Dónde |
|---|---|
| HTTPS en producción | `https://truck.ccsoluciones.com.co` |
| `manifest.json` con `display: standalone` e íconos 192/512 | `Truck_Mf_Single_Spa/src/manifest.json` |
| `<link rel="manifest">`, `theme-color`, `apple-touch-icon` | `Truck_Mf_Single_Spa/src/index.ejs:22-24` |
| Copia de manifest e íconos al build | `CopyWebpackPlugin` en `webpack.config.js` |
| Modelo y endpoints de notificaciones | `/notifications/filter`, `/notifications/save` |
| Tipos de evento **que el backend emite hoy** | `TRIP_EVENT`, `EXPENSE_EVENT`, `VEHICLE_EVENT`, `DRIVER_EVENT`, `OWNER_EVENT`, `DOCUMENT_EVENT` |
| Tipos de evento **solo del front** (nadie los emite) | `EXPIRATION_EVENT`, `BIRTHDAY_EVENT`, `TRIP_INACTIVITY_ALERT`, `SYSTEM_EVENT` — no planificar push sobre ellos hasta que el backend los produzca |
| UI del centro de notificaciones | `g-notifications`, `g-notification-card`, badge de no leídas |
| Canal WhatsApp/Twilio | `/notifications/sendMessages` con `ModelNotification` |

### No existe

**Cero código de push o service worker en los tres repos** (verificado por búsqueda de `serviceWorker`, `pushManager`, `VAPID`, `webpush`, `PushSubscription`).

Además, hoy las notificaciones llegan por **polling cada 5 minutos** (`Truck_Mf_Site/src/app/app.component.ts:63`): un evento puede tardar hasta 5 min en aparecer, y solo si la app está abierta.

---

## 2. Cómo funciona Web Push (contexto para el back)

```
[API]  --(HTTP POST cifrado + VAPID)-->  [Push Service del navegador]
                                          FCM (Chrome/Android)
                                          Mozilla Autopush (Firefox)
                                          APNs (Safari/iOS)
                                                 |
                                                 v
                                     [Service Worker en el celular]
                                          muestra la notificación
```

Cuatro cosas que el backend debe tener claras:

1. **La API nunca habla con el celular directamente.** Habla con el push service cuya URL viene en la suscripción (`endpoint`). No hay que registrarse con Google ni Apple: el estándar Web Push con **VAPID** basta.
2. **La suscripción es por dispositivo + navegador**, no por usuario. Un usuario con celular y PC tiene dos filas.
3. **El payload va cifrado** con las llaves `p256dh` y `auth` de la suscripción. La librería lo hace; el back solo entrega el JSON.
4. **La entrega no está garantizada.** Permiso revocado, datos borrados, ahorro de batería. Por eso lo crítico sigue yendo por WhatsApp.

---

## 3. Alcance por repositorio

| Repo | Cambio | Responsable |
|---|---|---|
| **API** | Llaves VAPID, tabla `push_subscription`, 3 endpoints, servicio de envío, limpieza | Backend |
| `Truck_Mf_Single_Spa` | `sw.js` en la raíz + registro + ajuste de `start_url` | Frontend |
| `Truck_Mf_Site` | Servicio de suscripción, UI de permiso, banner iOS, quitar polling | Frontend |

---

## 4. Backend — paso a paso

### Paso 1 — Generar el par de llaves VAPID

Un único par para toda la aplicación, generado **una sola vez**. Si se pierde o se rota, **todas las suscripciones existentes quedan inválidas** y hay que re-suscribir a todos los usuarios.

```bash
# Opción A (Node, la más simple)
npx web-push generate-vapid-keys

# Opción B (OpenSSL)
openssl ecparam -genkey -name prime256v1 -out vapid_private.pem
```

- [ ] Llave **privada** en variable de entorno / secreto del servidor. **Nunca** en el repo.
- [ ] Llave **pública** expuesta al frontend (ver Paso 3, `GET /push/public-key`).
- [ ] Definir el `subject` VAPID: `mailto:soporte@ccsoluciones.com.co` (obligatorio por el estándar).
- [ ] Documentar dónde quedó respaldada la llave privada.

**Dependencias (Java/Spring Boot):**

```xml
<dependency>
  <groupId>nl.martijndwars</groupId>
  <artifactId>web-push</artifactId>
  <version>5.1.1</version>
</dependency>
<dependency>
  <groupId>org.bouncycastle</groupId>
  <artifactId>bcprov-jdk18on</artifactId>
  <version>1.78</version>
</dependency>
```

> ⚠️ **`web-push` arrastra un árbol pesado.** Sus transitivas son `async-http-client 2.10.4` (Netty), `httpasyncclient 4.1.4` (retirado por Apache), `jose4j 0.7.0` y `jcommander`. La API ya corre sobre Tomcat y ya usa `jjwt 0.11.1` para JOSE: sin exclusiones se meten un segundo stack HTTP, Netty y un segundo stack JWT. Excluir lo que no se use y **verificar el arranque del contexto** después de agregar la dependencia.

---

### Paso 2 — Tabla de suscripciones

```sql
CREATE TABLE push_subscription (
  id                BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id           INT          NOT NULL,
  endpoint          TEXT         NOT NULL,
  endpoint_hash     CHAR(64)     NOT NULL UNIQUE,  -- SHA-256 del endpoint
  p256dh            VARCHAR(255) NOT NULL,
  auth              VARCHAR(255) NOT NULL,
  user_agent        VARCHAR(300),
  is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
  creation_date     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_success_date TIMESTAMP,
  failure_count     INT          NOT NULL DEFAULT 0
);

CREATE INDEX idx_push_subscription_user ON push_subscription (user_id, is_active);
```

- [ ] **`endpoint_hash` en vez de índice único sobre `endpoint`:** los endpoints pueden superar los 500 caracteres y MySQL no indexa columnas tan largas (límite de 3072 bytes ⇒ 768 chars en utf8mb4). El hash resuelve el unique sin ese límite.
- [ ] Sin FK a `user`, para mantener la consistencia con el resto del esquema si allí tampoco se usan.
- [ ] **Dialecto MySQL, no PostgreSQL:** `BIGINT AUTO_INCREMENT` en vez de `BIGSERIAL`.
- [ ] **`user_id` es `INT`, no `BIGINT`:** `users.id` está declarado `INT AUTO_INCREMENT` (`scripts/tables.sql`) y en Java `Users.id` es `Integer`. Con `BIGINT` no se puede poner FK ni comparar sin cast.
- [ ] El proyecto **no usa Flyway ni Liquibase**: la migración va como SQL manual en `scripts/`, siguiendo la convención de `tables.sql`, y se aplica a mano.

**Rollback:** nadie lee la tabla hasta el Paso 5. Revertir = `DROP TABLE`.

---

### Paso 3 — Endpoints

Autenticación **igual que el resto de la API**: headers `X-API-KEY` y `X-USER-ID` (el interceptor del frontend ya los envía en toda petición — `src/app/services/utils/http-headers.service.ts`). El `userId` se resuelve del header, **no del body**.

> 🔴 **Ojo: "igual que el resto de la API" hoy significa casi sin protección.** `CustomHeaderAuthFilter` valida **solo** `X-API-KEY`, y esa llave está **quemada en el código** (`CustomHeaderAuthFilter.java`) y es la misma para todos los usuarios. `X-USER-ID` **no lo autentica nadie**: es un dato que leen dos controladores, no una identidad verificada. Consecuencia para estos endpoints: cualquiera con la llave puede suscribir o desuscribir dispositivos **a nombre de cualquier usuario**. No bloquea el arranque, pero es una decisión consciente a tomar antes del Paso 5, no algo que se herede por inercia.

#### `GET /push/public-key`

```json
{ "data": "BEl62iUYgUivxIkv69yViEuiBIa-Ib9-SkvMeAtA3LFgDzkrxZJjSgSnfckjBJuBkr3qBUYIHBQFLXYp5Nksh8U" }
```

Permite rotar la llave sin redesplegar el frontend. Si prefieren, la llave pública puede ir fija en `environment.ts` — pero entonces rotarla exige build del front.

#### `POST /push/subscribe`

Body — es exactamente el objeto que entrega el navegador (`PushSubscription.toJSON()`), más el user agent:

```json
{
  "endpoint": "https://fcm.googleapis.com/fcm/send/dQw4w9WgXcQ:APA91b...",
  "keys": {
    "p256dh": "BNcRdreALRFXTkOOUHK1EtK2wtaz5Ry4YfYCA_0QTpQtUbVlUls0VJXg7A8u-Ts1XbjhazAkj7I99e8QcYP7DkM=",
    "auth": "tBHItJI5svbpez7KI4CCXg=="
  },
  "userAgent": "Mozilla/5.0 (Linux; Android 13; SM-A515F) ..."
}
```

Comportamiento — **upsert por `endpoint_hash`**, no insert:

- [ ] Si el `endpoint_hash` ya existe → actualizar `user_id`, `p256dh`, `auth`, `is_active = true`, `failure_count = 0`. Esto cubre el caso real de **un celular compartido** donde entra otro conductor: la suscripción se reasigna, no se duplica.
- [ ] Si no existe → insertar.
- [ ] Un usuario puede tener **N filas activas** (celular, tablet, PC). No limitar.
- [ ] Respuesta: `{ "data": { "id": 123 } }` o `{ "data": true }`, según la convención que prefieran.

#### `POST /push/unsubscribe`

```json
{ "endpoint": "https://fcm.googleapis.com/fcm/send/dQw4w9WgXcQ:APA91b..." }
```

- [ ] Marcar `is_active = false` (o borrar la fila). Se llama al cerrar sesión.

---

### Paso 4 — Servicio de envío

Un único punto de entrada, para que ningún flujo de negocio conozca los detalles del push:

```java
pushSender.send(userId, PushPayload payload);
```

> 🔴 **Falta un paso: hoy no hay `userId` a mano.** Las notificaciones **no se direccionan por usuario**. `Notification.targetUser` es nullable y **va siempre en null**: las seis llamadas a `InAppNotificationUseCase.createNotification(...)` pasan `targetUserId = null` y direccionan por `owner_id` + `target_role_id = 1`. Antes de poder invocar `pushSender.send(userId, ...)` hay que construir el puente:
>
> - `owner_id` → `Owner.user` (`@OneToOne` a `users`) → `users.id` → suscripciones activas.
> - Para eventos de conductor, `Driver.user` por el mismo camino.
> - Decidir qué hacer cuando el propietario o el conductor **no tiene `user_id` poblado**: hoy nada garantiza que lo tenga. Sin usuario no hay push, y el evento debe seguir su curso sin error.
>
> Este puente es trabajo real, no una línea, y conviene medirlo primero con un conteo sobre la base de producción: cuántos `owner` y `driver` tienen `user_id`.

**Contrato del payload** (JSON que llega tal cual al service worker):

```json
{
  "title": "Viaje asignado",
  "body": "ABC123 · Bogotá → Medellín",
  "icon": "/assets/images/icons/iconV1-192x192.png",
  "badge": "/assets/images/icons/iconV1-192x192.png",
  "tag": "trip-1234",
  "data": {
    "notificationId": 987,
    "eventType": "TRIP_EVENT",
    "url": "/truck/site/trips/1234"
  }
}
```

Reglas del payload:

- [ ] **Máximo 4 KB cifrado.** Apuntar a **menos de 2 KB**: `title` ≤ 50 caracteres, `body` ≤ 120. Los títulos largos se truncan en el celular de todos modos.
- [ ] **`tag`** agrupa/reemplaza notificaciones del mismo objeto. Con `tag: "trip-1234"`, tres actualizaciones del mismo viaje muestran **una sola** notificación actualizada en vez de tres. Muy recomendable para `TRIP_INACTIVITY_ALERT`.
- [ ] **`data.url`** es el deep-link. Rutas reales de la app (el `basePath` es `/truck` y las vistas cuelgan de `/site`):

| Evento | `data.url` |
|---|---|
| `TRIP_EVENT` | `/truck/site/trips/{tripId}` |
| `EXPENSE_EVENT` | `/truck/site/expenses` |
| `VEHICLE_EVENT` | `/truck/site/vehicles/{vehicleId}` |
| `DRIVER_EVENT` | `/truck/site/drivers/{driverId}` |
| `DOCUMENT_EVENT` | `/truck/site/vehicles` — al listado, porque su `reference_id` es el id del **documento**, no el del vehículo |
| `OWNER_EVENT` | `/truck/site/owners/{ownerId}` |

> Los eventos `EXPIRATION_EVENT`, `BIRTHDAY_EVENT`, `TRIP_INACTIVITY_ALERT` y `SYSTEM_EVENT` existen solo en el front: **el backend no los emite**. No tienen deep-link porque no hay evento que enrutar.

- [ ] **`data.notificationId`** debe ser el `id` real de la fila en `notifications`. El service worker lo usa para marcarla como leída al abrirla.
- [ ] ⚠️ **`createNotification(...)` devuelve `void`.** Para poder mandar el id real hay que cambiar la firma a que devuelva la `Notification` guardada y ajustar los **seis** llamadores (`TripUseCase`, `ExpenseUseCase`, `VehicleUseCase`, `DriverUseCase`, `OwnerUseCase`, `DocumentExpiryReminderScheduler`).

**Headers del envío:**

- [ ] `TTL`: cuánto retiene el push service el mensaje si el celular está apagado. Sugerido: `86400` (1 día) para eventos operativos. *(El `259200` que sugería este plan era para los vencimientos, que ya no van por push — ver Paso 5.)*
- [ ] `Urgency`: `high` para alertas críticas, `normal` para el resto. En `low` el celular puede retrasar la entrega hasta que salga del ahorro de batería.

---

### Paso 5 — Enganche con el flujo actual

**No crear un flujo paralelo.** Donde hoy se persiste una `GNotification`, después del commit se dispara el fan-out:

```
Evento de negocio
      │
      ├─► INSERT en notifications        (fuente de verdad — ya existe)
      │
      └─► Fan-out por canal:
            ├─ Push      → si el usuario tiene suscripción activa
            └─ WhatsApp  → según la matriz de abajo
```

**Matriz de enrutamiento por criticidad:**

| Evento | In-app | Push | WhatsApp |
|---|:---:|:---:|:---:|
| Viaje asignado / iniciado / finalizado | ✅ | ✅ | — |
| Gasto registrado | ✅ | ✅ | — |
| `TRIP_INACTIVITY_ALERT` *(el backend aún no lo emite)* | ✅ | ✅ | Escalamiento |
| Documento subido | ✅ | ✅ | — |
| **Vencimiento de documento de vehículo a 10 / 3 / 0 días** (`DOCUMENT_EVENT`) | ✅ | ✅ | **—** |
| **Liquidación de viaje** | ✅ | ✅ | ✅ **siempre** |
| Cumpleaños | ✅ | ✅ | — |
| **Usuario sin suscripción push activa** | ✅ | — | ✅ **fallback** |

> 🔴 **Los vencimientos de documento no salen por WhatsApp — decisión del negocio.** Van por la bandeja in-app y por push, nunca por WhatsApp, y los hitos son **10, 3 y 0 días**, no 30/15/7. Está implementado así en `DocumentExpiryReminderScheduler` y esta matriz manda sobre cualquier versión anterior del plan.

> **Destinatario del aviso de cuenta nueva.** `OWNER_EVENT` se guarda con `owner_id` nulo porque no es un aviso para el propietario recién creado —que al momento del alta ni siquiera tiene un dispositivo suscrito— sino para **quien administra**. Por eso su push va a todos los usuarios con rol `ADMINISTRADOR`, y cubre por igual el alta administrativa y el registro desde el sitio público, que reutiliza el mismo `OwnerUseCase.save`.

**Escalamiento (opcional, fase 2):** si una notificación marcada como crítica sigue con `isRead = false` después de N horas, disparar el WhatsApp. Baja el gasto de Twilio sin perder garantía de entrega. El campo `isRead` ya existe, no requiere esquema nuevo.

- [ ] El envío push debe ser **asíncrono** (`@Async` o cola). Nunca dentro de la transacción del evento de negocio: un push service lento no puede bloquear el guardado de un viaje.
- [ ] **Pool dedicado y acotado (10-20 hilos), no el `@Async` por defecto.** Cada usuario tiene N dispositivos ⇒ N llamadas HTTP salientes por evento. Un job masivo son cientos de conexiones a FCM/APNs: sobre el executor por defecto de Spring, eso compite con las peticiones de los usuarios y degrada la API.
- [ ] ⚠️ **`@EnableAsync` ya existe** (`AsyncConfig`), así que ese paso está hecho. Pero esa clase documenta que usa a propósito el executor autoconfigurado, porque declarar uno propio *"haría ambigua la resolución de los `@Async` sin calificador"* — los de WhatsApp, SMS y Email. Por eso el pool de push debe declararse como **bean nombrado** y usarse como `@Async("pushExecutor")`, dejando intactos los tres `@Async` existentes. Actualizar el comentario de `AsyncConfig` al hacerlo.
- [ ] Un fallo de push **nunca** debe revertir la transacción ni propagar excepción al flujo de negocio.

---

### Paso 6 — Limpieza de suscripciones muertas

**Este paso no es opcional.** Sin él la tabla se llena de endpoints muertos, cada envío intenta N entregas fallidas y el sistema se degrada solo.

Manejo por código de respuesta del push service:

| Código | Significado | Acción |
|---|---|---|
| `201` / `200` | Entregado al push service | `last_success_date = now()`, `failure_count = 0` |
| `404` / `410` | Suscripción expirada o revocada | **`is_active = false`** (o borrar la fila) |
| `413` | Payload muy grande | Log de error — es un bug del payload, no del usuario |
| `429` | Rate limit | Reintentar respetando el header `Retry-After` |
| `5xx` | Falla temporal del push service | Reintentar hasta 3 veces con backoff; luego `failure_count++` |

- [ ] Job de aseo: borrar filas con `is_active = false` de más de 30 días, o con `failure_count > 10`.

---

### Paso 7 — Pruebas del backend

- [ ] `POST /push/subscribe` inserta correctamente.
- [ ] `POST /push/subscribe` con el **mismo endpoint** actualiza, no duplica.
- [ ] `POST /push/subscribe` con el mismo endpoint y **otro `X-USER-ID`** reasigna el `user_id` (celular compartido).
- [ ] `POST /push/unsubscribe` desactiva.
- [ ] Envío a un usuario con 2 dispositivos llega a los 2.
- [ ] Envío a un usuario **sin** suscripciones no lanza excepción y cae al fallback de WhatsApp.
- [ ] Respuesta `410` simulada ⇒ la fila queda `is_active = false`.
- [ ] Payload de más de 4 KB ⇒ se trunca o se rechaza con log, no se cae el proceso.
- [ ] El fallo del push **no** revierte la transacción de negocio.
- [ ] Envío real a un Android físico y a un iPhone con la PWA instalada.

---

## 5. Frontend — Shell (`Truck_Mf_Single_Spa`)

### Paso 8 — `sw.js` en la raíz

**Crítico:** el archivo debe quedar en la **raíz del build** (`/sw.js`), junto al `manifest.json`. Un service worker solo controla rutas **por debajo** de su propia ubicación: si se publica en `/truck/truck-mf-site/sw.js`, **no controla `/truck/site/*`** y el push nunca llega.

- [ ] Crear `src/sw.js` con los listeners de `push` y `notificationclick`.
- [ ] Agregarlo al `CopyWebpackPlugin` del `webpack.config.js`: `{ from: "src/sw.js", to: "." }`.
- [ ] En `notificationclick`: si ya hay una pestaña de la app abierta, enfocarla y navegar a `data.url`; si no, `clients.openWindow(data.url)`.

> 🔴 **Regla dura — sin listener `fetch`.** El service worker **no debe cachear nada**. No usar `@angular/service-worker` ni Workbox: sus configuraciones por defecto interceptan `fetch` y empezarían a cachear los `main.js` de los micro-frontends, que SystemJS carga desde URLs fijas. Consecuencia: usuarios clavados en una versión vieja del MFE, sin forma de actualizar, mientras se despliega y nadie ve el cambio. El archivo es de ~30 líneas escritas a mano. **Si contiene la palabra `caches` o `fetch`, está mal.**

- [ ] **Killswitch listo desde el día uno.** Un service worker roto **persiste en el dispositivo** y borrar el archivo del servidor **no lo desinstala** — deja el viejo corriendo. Tener preparado un `sw.js` alterno que solo haga `self.registration.unregister()`, para desplegar y recuperar si algo sale mal.

### Paso 9 — Registro y `start_url`

- [ ] Registrar el SW en `src/Truck-root-config.ts`: `navigator.serviceWorker.register('/sw.js')`, con guarda de `'serviceWorker' in navigator`.
- [ ] **Verificar la CSP del `index.ejs` — no asumir.** La cadena de fallback es `worker-src` → `child-src` → **`script-src`** (no `default-src`). El `script-src` de producción **no incluye `'self'`**, pero sí `truck.ccsoluciones.com.co:*`, que cubre `/sw.js` servido por HTTPS desde ese host. Debería funcionar sin cambios; confirmarlo en la consola del navegador antes de dar el paso por cerrado.
- [ ] **`start_url`: opcional, y con orden.** Hoy es `"."`, que resuelve a `/` y obliga al redirect del root-config; `"/truck/site/home"` es mejor. **Pero el manifest no tiene campo `id`**, y cuando `id` no está, el navegador usa `start_url` como identidad de la app: cambiarlo puede dejar **dos íconos** a quien ya tenga la PWA instalada. Agregar `"id": "/"` en un despliegue previo, y cambiar `start_url` después. No es un requisito del push — si hay dudas, no tocarlo.

---

## 6. Frontend — Site (`Truck_Mf_Site`)

### Paso 10 — Servicio de suscripción

- [ ] `PushService` con `subscribe()`: pide permiso, `registration.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey })`, y envía el resultado a `POST /push/subscribe`.
- [ ] Convertir la llave VAPID pública de base64url a `Uint8Array` antes de pasarla.
- [ ] `unsubscribe()` al cerrar sesión (hay un flujo de cierre de sesión ya implementado — commit `4e7a2d2`).
- [ ] Re-verificar la suscripción en cada arranque: los push services la rotan silenciosamente.

### Paso 11 — UI del permiso

- [ ] **Nunca pedir el permiso al cargar la app.** Solo hay un intento por usuario: si lo bloquea, no se puede volver a pedir por código, solo desde la configuración del navegador.
- [ ] Pedirlo **en contexto**, con una tarjeta previa que explique el valor ("Recibe avisos de tus viajes al instante"), y solo tras un gesto explícito del usuario.
- [ ] Buen momento: al abrir el centro de notificaciones, o tras crear el primer viaje.

### Paso 12 — iOS

- [ ] Detectar iOS + no instalado (`navigator.standalone === false`) y mostrar un banner con las instrucciones de "Compartir → Agregar a pantalla de inicio".
- [ ] En iOS el permiso **solo puede pedirse dentro de la PWA ya instalada**, nunca desde Safari.

### Paso 13 — Retirar el polling

- [ ] Una vez el push esté verificado en producción, eliminar o alargar el `interval(300000)` de `src/app/app.component.ts:63`.
- [ ] **Dejar un refresco al volver al foreground** (evento `visibilitychange`) como red de seguridad para los push perdidos.

---

## 7. Orden de despliegue

1. **Backend** (Pasos 1-4, 6): tabla y endpoints en producción. Nadie los consume todavía. Riesgo cero.
2. **Shell** (Pasos 8-9): `sw.js` registrado. La app queda instalable, sin cambio visible.
3. **Site** (Pasos 10-12): empieza la captación de suscripciones. Las notificaciones siguen llegando por polling y WhatsApp.
4. **Esperar** a tener una masa de suscripciones (una o dos semanas).
5. **Activar el fan-out de push** (Paso 5). WhatsApp sigue intacto.
6. **Medir** entrega y lectura. Solo entonces, ajustar la matriz de canales y retirar el polling (Paso 13).

> **No negociable:** los endpoints del backend deben estar en producción antes de desplegar el Site, o el `POST /push/subscribe` devuelve 404 en cada arranque.

---

## 8. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| **El SW cachea los `main.js` de los MFEs** | **Usuarios clavados en una versión vieja del micro-frontend, sin forma de actualizar** | `sw.js` **sin listener `fetch`**, escrito a mano, sin Workbox ni `@angular/service-worker` (Paso 8) |
| SW roto ya instalado en dispositivos | Borrar el archivo del servidor **no lo desinstala** | Killswitch con `unregister()` listo desde el día uno (Paso 8) |
| Cambiar `start_url` sin campo `id` | Doble ícono para quien ya instaló la PWA | Agregar `"id": "/"` en un despliegue previo, o no tocar `start_url` (Paso 9) |
| Fan-out sobre el executor por defecto | Un job masivo compite con las peticiones de usuarios y degrada la API | Pool dedicado y acotado de 10-20 hilos (Paso 5) |
| `sw.js` publicado bajo `/truck/truck-mf-site/` | El push **no funciona nunca**, sin error visible | Servirlo desde la raíz del shell (Paso 8) |
| Usuarios en iPhone que no instalan la PWA | **Cero push** para ese segmento | Banner de instalación (Paso 12) + WhatsApp como fallback obligatorio |
| Pedir el permiso al cargar la app | Bloqueo permanente, irreversible por código | Permiso en contexto, tras gesto del usuario (Paso 11) |
| Sin limpieza de suscripciones muertas | La tabla se llena, cada envío degrada | Manejo de 404/410 (Paso 6), no opcional |
| Rotar o perder la llave VAPID privada | **Todas** las suscripciones quedan inválidas | Respaldo documentado (Paso 1) |
| Envío push dentro de la transacción de negocio | Un push service lento bloquea el guardado de viajes | Envío asíncrono (Paso 5) |
| Retirar el polling antes de validar el push | Los usuarios dejan de enterarse de todo | Paso 13 solo después de medir (Paso 7.6) |
| Probar en `http://168.231.93.145` | El SW **no carga**: requiere HTTPS o localhost | Probar en localhost o contra el dominio de producción |
| Ahorro de batería agresivo (Xiaomi, Huawei, Oppo) | Entregas retrasadas horas | `Urgency: high` en lo crítico + WhatsApp para lo que no puede esperar |

---

## 9. Checklist de entrega

**Backend**
- [ ] Par VAPID generado, privada en secreto, respaldo documentado
- [ ] Migración `push_subscription` versionada y aplicada en dev
- [ ] `GET /push/public-key`, `POST /push/subscribe`, `POST /push/unsubscribe` operativos
- [ ] Upsert por `endpoint_hash` verificado (incluido el caso de celular compartido)
- [ ] `PushSenderService` asíncrono, con el contrato de payload del Paso 4
- [ ] Manejo de 404/410/429 y job de aseo
- [ ] Matriz de canales del Paso 5 implementada, con fallback a WhatsApp
- [ ] Las 10 pruebas del Paso 7 en verde

**Frontend**
- [ ] `sw.js` en la raíz del shell y registrado
- [ ] `start_url` corregido a `/truck/site/home`
- [ ] `PushService` con subscribe/unsubscribe y re-verificación al arranque
- [ ] UI de permiso en contexto, nunca al cargar
- [ ] Banner de instalación para iOS
- [ ] Verificado en Android físico y en iPhone con PWA instalada
- [ ] Polling retirado **solo después** de medir la entrega en producción
