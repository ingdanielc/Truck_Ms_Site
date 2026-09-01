# Plantillas de WhatsApp para aprobación en Twilio

Texto listo para pegar en **Twilio Console → Messaging → Content Template
Builder** y enviar a aprobación de Meta. Cada plantilla de aquí es idéntica a la
que quedó en `scripts/info.sql` y `scripts/cashTruck_reset.sql`: el backend
guarda esa copia local para la auditoría, y Twilio envía la aprobada por
`ContentSid`. Si una cambia, la otra también.

## La contraseña no aparece en el mensaje

Las bienvenidas no mencionan la contraseña: ni el valor ni un enmascarado. El
backend sigue recibiendo `plainPassword` para poder crear el usuario, pero como
`provider_variables` no la lista, `MapUtils.mapContentVariables` no la incluye en
el JSON que va a Twilio. Efectos:

- La contraseña en texto plano nunca llega a Twilio ni a Meta.
- Tampoco queda en `whatsapp.message_content` ni en la auditoría, que antes la
  guardaban en claro.
- Desaparece del log `Final template content after mapping` de `MapUtils`.

Lo que sí lleva el mensaje es el correo con el que se entra (`{{2}}`). En el
registro público la contraseña la eligió el propio usuario, así que no hay nada
que comunicarle; en las altas que crea un administrador, él tiene que entregarla
por otro canal.

---

## Resumen

| Plantilla | `message_type` | Categoría | Variables |
| --- | --- | --- | --- |
| `cashtruck_recuperacion_contrasena` | `PASSWORD_RECOVERY` | AUTHENTICATION | `code` |
| `cashtruck_bienvenida_propietario` | `WELCOME_OWNER` | UTILITY | `name`, `email` |
| `cashtruck_bienvenida_propietario_conductor` | `WELCOME_OWNER_DRIVER` | UTILITY | `name`, `email` |
| `cashtruck_bienvenida_conductor` | `WELCOME_DRIVER` | UTILITY | `name`, `email` |
| `cashtruck_aviso_suscripcion` | `SUBSCRIPTION_REMINDER` | UTILITY | `name`, `endDate`, `days` |

---

## Reglas que se aplicaron para que Meta las apruebe

1. **Categoría.** Las cuatro de cuenta van como `UTILITY`: son avisos sobre una
   cuenta que ya existe. La de recuperación va como `AUTHENTICATION`, y ahí no
   hay elección: Meta exige esa categoría para cualquier código de un solo uso y
   rechaza con `INCORRECT_CATEGORY` el mismo texto enviado como `UTILITY`. Ver
   «Por qué la de recuperación no lleva la marca».
2. **Nada promocional en las `UTILITY`.** Se quitó el arranque «¡Bienvenido!» a
   favor de «Tu cuenta ya está activa», y el aviso de suscripción no ofrece
   planes ni precios. Cualquier oferta lo movería a `MARKETING`, que cuesta más
   y exige opt-in.
3. **Ninguna variable al inicio ni al final del cuerpo**, ni dos variables
   pegadas: son las dos causas de rechazo automático más frecuentes.
4. **Numeración secuencial desde `{{1}}`**, sin huecos, y con un valor de
   ejemplo por cada una — Meta rechaza el envío si falta alguno.
5. **La URL va fija en el texto**, no como variable. Un enlace que llega en una
   variable es motivo habitual de rechazo por riesgo de abuso. El precio es que
   `truck.parameter.app-url` deja de influir en lo que ve el destinatario: si
   cambia el dominio, hay que crear plantillas nuevas.
6. **Sin la contraseña en claro**, por lo dicho arriba.
7. **Cuerpo por debajo de 1024 caracteres**, sin espacios sobrantes al final de
   línea ni tres saltos seguidos.
8. **Ortografía y tildes correctas** y coherentes con el idioma declarado (`es`).
   Los errores de redacción son causal de rechazo por sí solos.
9. **Nombre en minúsculas con guion bajo**, que es lo único que acepta Meta.
10. **Las cuatro `UTILITY` cierran igual, avisando que el mensaje es
    automático**, en vez de invitar a responder. Nadie atiende ese número, así
    que prometer un canal de soporte que no existe solo genera respuestas que
    nadie lee. Donde sí hay que hacer algo —renovar la suscripción— el mensaje
    remite al administrador, que es un canal real.

---

## Plantillas

### cashtruck_recuperacion_contrasena

| | |
| --- | --- |
| `message_type` | `PASSWORD_RECOVERY` |
| Categoría | **AUTHENTICATION** |
| Tipo de contenido en Twilio | `whatsapp/authentication` |
| Idioma | `es` |
| Variables | 1 |

Categoría obligatoria: Meta exige AUTHENTICATION para cualquier código de un solo uso, y ahí el cuerpo es fijo. Por eso no lleva marca ni saludo; ver la seccion final sobre la marca.

| Opción | Valor |
| --- | --- |
| `add_security_recommendation` | `true` — agrega «Por tu seguridad, no lo compartas» |
| `code_expiration_minutes` | `10` — debe coincidir con `Constants.PASSWORD_RESET_CODE_MINUTES` |
| Botón | `COPY_CODE` con texto `Copiar código` |

Texto que genera Meta a partir de las opciones (no se escribe):

```
{{1}} es tu código de verificación. Por tu seguridad, no lo compartas.
```

Pie de página (footer):

```
Este código caduca en 10 minutos.
```

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `code` | 482913 |

`provider_variables` = `code`

### cashtruck_bienvenida_propietario

| | |
| --- | --- |
| `message_type` | `WELCOME_OWNER` |
| Categoría | **UTILITY** |
| Tipo de contenido en Twilio | `twilio/text` |
| Idioma | `es` |
| Variables | 2 |

Propietario que no conduce: conserva el paso de crear conductores.

```
🚀 Tu cuenta de CashTruck ya está activa 🚛

Hola {{1}}, ya puedes gestionar tus vehículos y controlar tus costos.

🔗 App: https://truck.ccsoluciones.com.co
📧 Usuario: {{2}}

*Primeros pasos:*
1️⃣ Crea tus conductores 👤
2️⃣ Registra tus vehículos 🚛
3️⃣ Crea viajes asignando conductor y vehículo 🗺️
4️⃣ Anota los gastos de cada viaje 💸
5️⃣ Registra los mantenimientos 🛠️
6️⃣ Consulta tus rutas en el mapa 📍
7️⃣ Revisa tus reportes 📊

🤖 Mensaje automático, por favor no respondas a este número.
```

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `name` | Juan Pérez |
| `{{2}}` | `email` | juan.perez@correo.com |

`provider_variables` = `name,email`

### cashtruck_bienvenida_propietario_conductor

| | |
| --- | --- |
| `message_type` | `WELCOME_OWNER_DRIVER` |
| Categoría | **UTILITY** |
| Tipo de contenido en Twilio | `twilio/text` |
| Idioma | `es` |
| Variables | 2 |

Propietario que también conduce: su conductor se crea solo, así que no aparece ese paso.

```
🚀 Tu cuenta de CashTruck ya está activa 🚛

Hola {{1}}, ya puedes gestionar tus vehículos y controlar tus costos.

🔗 App: https://truck.ccsoluciones.com.co
📧 Usuario: {{2}}

*Primeros pasos:*
1️⃣ Registra tus vehículos 🚛
2️⃣ Crea viajes asignando tu vehículo 🗺️
3️⃣ Anota los gastos de cada viaje 💸
4️⃣ Registra los mantenimientos 🛠️
5️⃣ Consulta tus rutas en el mapa 📍
6️⃣ Revisa tus reportes 📊

🤖 Mensaje automático, por favor no respondas a este número.
```

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `name` | Juan Pérez |
| `{{2}}` | `email` | juan.perez@correo.com |

`provider_variables` = `name,email`

### cashtruck_bienvenida_conductor

| | |
| --- | --- |
| `message_type` | `WELCOME_DRIVER` |
| Categoría | **UTILITY** |
| Tipo de contenido en Twilio | `twilio/text` |
| Idioma | `es` |
| Variables | 2 |

Conductor al que el propietario le dio acceso a la app.

```
🚀 Tu cuenta de CashTruck ya está activa 🚛

Hola {{1}}, ya puedes registrar tus viajes y gastos.

🔗 App: https://truck.ccsoluciones.com.co
📧 Usuario: {{2}}

*Primeros pasos:*
1️⃣ Crea viajes asignando tu vehículo 🗺️
2️⃣ Anota los gastos de cada viaje 💸
3️⃣ Registra los mantenimientos 🛠️
4️⃣ Consulta tus rutas en el mapa 📍
5️⃣ Revisa tus reportes 📊

🤖 Mensaje automático, por favor no respondas a este número.
```

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `name` | Pedro Fernández |
| `{{2}}` | `email` | pedro.fernandez@correo.com |

`provider_variables` = `name,email`

### cashtruck_aviso_suscripcion

| | |
| --- | --- |
| `message_type` | `SUBSCRIPTION_REMINDER` |
| Categoría | **UTILITY** |
| Tipo de contenido en Twilio | `twilio/text` |
| Idioma | `es` |
| Variables | 3 |

Aviso de estado de la cuenta, sin precios ni oferta: eso es lo que lo mantiene en UTILITY y no en MARKETING.

```
⏳ Tu suscripción a CashTruck está por vencer

Hola {{1}}, tu suscripción finaliza el *{{2}}*, dentro de {{3}} días.

Cuando venza perderás el acceso a tus viajes, vehículos, mantenimientos y reportes. Comunícate con el administrador para gestionar la renovación. 🔄

🤖 Mensaje automático, por favor no respondas a este número.
```

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `name` | Juan Pérez |
| `{{2}}` | `endDate` | 15/10/2026 |
| `{{3}}` | `days` | 3 |

`provider_variables` = `name,endDate,days`

---

## Cómo cargarlas

1. En **Content Template Builder**, *Create new* → el tipo de contenido que
   indica la ficha de cada plantilla (`twilio/text` o `whatsapp/authentication`).
2. Nombre = el de la ficha, idioma `es`.
3. Pega el cuerpo tal cual, **incluidos emojis y saltos de línea**.
4. Carga los valores de ejemplo de cada variable.
5. *Submit for WhatsApp Approval* con la categoría indicada.
6. Cuando quede `approved`, copia el `ContentSid` (`HX…`) al `UPDATE ... SET
   provider_template_id` que le corresponde en **`scripts/info.sql`**, al final
   del bloque de plantillas.

Mientras `provider_template_id` siga en `NULL`, el backend envía texto libre:
sirve para probar dentro de la ventana de 24 horas, pero WhatsApp lo rechaza
(error 63016) en un mensaje que inicia el negocio. Cada vez que eso pasa queda
un `WARN` en el log nombrando la plantilla que falta por registrar.

---

## Qué hace el backend con esto

No hay que tocar código para estrenar una plantilla: basta el `ContentSid` en la
base. El camino es siempre el mismo.

1. `WhatsappMessageUseCase.getTemplate` busca la fila por `medium` +
   `message_type` y arma dos cosas a la vez: el **texto local**, resolviendo los
   `${...}` con `MapUtils.mapTemplateValues`, y los **datos para Twilio**.
2. El texto local es el que se guarda en `whatsapp.message_content` y en la
   auditoría — por eso tiene que ser idéntico al aprobado, o el registro dejará
   de reflejar lo que recibió el destinatario.
3. `MapUtils.mapContentVariables` traduce las claves nombradas al JSON posicional
   que espera Twilio (`{"1":"Juan","2":"juan@correo.com"}`). **El orden lo manda
   `provider_variables`**, no el orden en que el llamador armó la lista: esa
   posición es la que tiene que coincidir con el `{{n}}` de la plantilla
   aprobada. Una clave que no llegue viaja vacía en vez de romper el envío.
4. `TwilioWhatsAppNotificationProviders.create` envía por `ContentSid` cuando lo
   hay, y por cuerpo libre cuando no.

El envío corre en `@Async` (habilitado en `AsyncConfig`), así que crear un
propietario o pedir un código de recuperación responde sin esperar a Twilio. El
resultado real queda en la auditoría: `audit.status` en `Sent` o `Failed` según
lo que contestó Twilio, y `audit.error_type` con el motivo exacto del rechazo,
que es lo que distingue un celular mal formado de una plantilla sin aprobar.

Para probar una plantilla antes de que Meta la apruebe, escribe primero al
número de WhatsApp del negocio desde el celular de destino: eso abre la ventana
de 24 horas y el texto libre sí se entrega.

---

## Por qué la de recuperación no lleva la marca

La primera versión saludaba por el nombre y decía «CashTruck», y Meta la
rechazó. No es un problema de redacción: un código de un solo uso **solo** se
puede enviar en la categoría `AUTHENTICATION`, y ahí el cuerpo no se escribe.
Twilio lo dice sin rodeos: *custom authentication templates aren't allowed*. Se
eligen dos opciones —la recomendación de seguridad y los minutos de caducidad— y
Meta arma el texto y lo traduce al idioma declarado.

Mandar ese mismo contenido como `UTILITY` es justamente lo que ya se intentó:
desde abril de 2025 Meta valida la categoría durante la revisión y responde
`INCORRECT_CATEGORY`.

De la marca sí sobrevive lo que importa:

- **El remitente.** WhatsApp muestra encima del mensaje el nombre de negocio de
  tu WABA, así que el destinatario ve que viene de CashTruck.
- **El botón de copiar.** La plantilla incluye un `COPY_CODE`, que evita
  transcribir el código a mano: es mejor experiencia que el texto suelto.

El backend no cambia. `PasswordResetUseCase` sigue enviando `name` y `minutes`,
pero como `provider_variables` es solo `code`, esas dos claves ya no viajan a
Twilio y los minutos quedan fijos dentro de la plantilla aprobada.

---

## Al cambiar algo

Una plantilla aprobada **sí se puede editar**, y al editarla conserva su
`ContentSid`: en la consola actual con el botón *Edit*, o por API con
`PUT /v1/Content/{ContentSid}`. La edición vuelve a pasar por revisión de Meta, y
el tope es una edición cada 24 horas y diez cada 30 días. Como el `HX` no cambia,
retocar el texto no obliga a tocar `info.sql`. (En la consola antigua no hay
*Edit*: ahí toca duplicar, y eso sí genera un `HX` nuevo.)

Lo que obliga a crear una plantilla desde cero es cambiar su **tipo o
categoría** —por ejemplo pasar de `twilio/text` a `whatsapp/authentication`—,
porque eso ya no es editar un texto sino otra plantilla distinta. Solo en ese
caso cambia el `HX` y hay que actualizarlo.

Quedaron acoplados a la plantilla estos valores:

| Si cambia… | Hay que rehacer |
| --- | --- |
| `truck.parameter.app-url` (hoy `https://truck.ccsoluciones.com.co`) | las tres bienvenidas |
| `Constants.PASSWORD_RESET_CODE_MINUTES` (hoy 10) | `cashtruck_recuperacion_contrasena`: los minutos viven dentro de la plantilla |
| `Constants.SUBSCRIPTION_REMINDER_DAYS` (hoy 3) | nada: viaja como variable `{{3}}` |

Y en toda edición: cambia el texto en Twilio **y** en `template_content` de los
scripts SQL, o la auditoría dejará de reflejar lo que se envió.
