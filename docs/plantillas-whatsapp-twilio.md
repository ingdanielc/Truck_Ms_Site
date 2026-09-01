# Plantillas de WhatsApp para aprobación en Twilio

Texto listo para pegar en **Twilio Console → Messaging → Content Template
Builder** y enviar a aprobación de Meta. Cada plantilla de aquí es idéntica a la
que quedó en `scripts/info.sql` y `scripts/cashTruck_reset.sql`: el backend
guarda esa copia local para la auditoría, y Twilio envía la aprobada por
`ContentSid`. Si una cambia, la otra también.

## La contraseña no sale del backend

En las tres bienvenidas la contraseña es el literal `********`, no una variable.
El backend sigue recibiendo `plainPassword`, pero como `provider_variables` ya no
la lista, `MapUtils.mapContentVariables` no la incluye en el JSON que va a
Twilio. Efectos:

- La contraseña en texto plano nunca llega a Twilio ni a Meta.
- Tampoco queda en `whatsapp.message_content` ni en la auditoría, que antes la
  guardaban en claro.
- Desaparece del log `Final template content after mapping` de `MapUtils`.

A cambio, **el mensaje ya no comunica la contraseña**. En el registro público el
usuario la eligió, así que no hace falta; en las altas que crea un administrador,
él tiene que entregarla por otro canal. Si prefieres que el mensaje lo diga
explícitamente, cambia esa línea por `🔑 Contraseña: la que registraste` antes de
enviar a aprobación (y ajusta el SQL igual).

> Nota de formato: WhatsApp usa `*texto*` para negrita, pero `********` son
> asteriscos vacíos y se muestran tal cual. Si en la vista previa de Twilio se
> vieran raros, reemplázalos por `••••••••`.

---

## Resumen

| Plantilla | `message_type` | Categoría | Variables |
| --- | --- | --- | --- |
| `cashtruck_recuperacion_contrasena` | `PASSWORD_RECOVERY` | UTILITY | `name`, `code`, `minutes` |
| `cashtruck_bienvenida_propietario` | `WELCOME_OWNER` | UTILITY | `name`, `email` |
| `cashtruck_bienvenida_propietario_conductor` | `WELCOME_OWNER_DRIVER` | UTILITY | `name`, `email` |
| `cashtruck_bienvenida_conductor` | `WELCOME_DRIVER` | UTILITY | `name`, `email` |
| `cashtruck_aviso_suscripcion` | `SUBSCRIPTION_REMINDER` | UTILITY | `name`, `endDate`, `days` |

---

## Reglas que se aplicaron para que Meta las apruebe

1. **Categoría.** Las cinco van como `UTILITY`: son avisos sobre una cuenta que
   ya existe. Ojo con la de recuperación: lleva texto propio para poder saludar
   por el nombre y decir «CashTruck», y eso obliga a `UTILITY`, porque la
   categoría `AUTHENTICATION` genera un cuerpo fijo de Meta sin marca, sin
   saludo y sin emojis. El riesgo asumido es que la revisión automática
   reclasifique el mensaje a `AUTHENTICATION` por contener un código de un solo
   uso —la plantilla sigue sirviendo, solo cambia la tarifa— o que exija el
   formato fijo. Si eso pasa, abajo está la variante de respaldo.
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

---

## Plantillas

### cashtruck_recuperacion_contrasena

| | |
| --- | --- |
| `message_type` | `PASSWORD_RECOVERY` |
| Categoría | **UTILITY** |
| Tipo de contenido en Twilio | `twilio/text` |
| Idioma | `es` |
| Variables | 3 |

Texto propio en UTILITY para poder saludar por el nombre y nombrar la marca. Ver la advertencia de categoría en la regla 1 y la variante de respaldo al final del documento.

```
🔐 Recuperación de contraseña de CashTruck

Hola {{1}}, recibimos una solicitud para restablecer tu contraseña. Tu código de verificación es:

*{{2}}*

⏳ Vence en {{3}} minutos y solo se puede usar una vez.

⚠️ Si no lo solicitaste, ignora este mensaje y comunícate con el administrador.
```

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `name` | Juan Pérez |
| `{{2}}` | `code` | 482913 |
| `{{3}}` | `minutes` | 10 |

`provider_variables` = `name,code,minutes`

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
🔑 Contraseña: ********

*Primeros pasos:*
1️⃣ Crea tus conductores 👤
2️⃣ Registra tus vehículos 🚛
3️⃣ Crea viajes asignando conductor y vehículo 🗺️
4️⃣ Anota los gastos de cada viaje 💸
5️⃣ Registra los mantenimientos 🛠️
6️⃣ Consulta tus rutas en el mapa 📍
7️⃣ Revisa tus reportes 📊

¿Dudas? Escríbenos por este medio 📲
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
🔑 Contraseña: ********

*Primeros pasos:*
1️⃣ Registra tus vehículos 🚛
2️⃣ Crea viajes asignando tu vehículo 🗺️
3️⃣ Anota los gastos de cada viaje 💸
4️⃣ Registra los mantenimientos 🛠️
5️⃣ Consulta tus rutas en el mapa 📍
6️⃣ Revisa tus reportes 📊

¿Dudas? Escríbenos por este medio 📲
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
🔑 Contraseña: ********

*Primeros pasos:*
1️⃣ Crea viajes asignando tu vehículo 🗺️
2️⃣ Anota los gastos de cada viaje 💸
3️⃣ Registra los mantenimientos 🛠️
4️⃣ Consulta tus rutas en el mapa 📍
5️⃣ Revisa tus reportes 📊

¿Dudas? Escríbenos por este medio 📲
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

¿Necesitas ayuda? Escríbenos por este medio 📲
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
   indica la ficha de cada plantilla (`twilio/text` o `twilio/authentication`).
2. Nombre = el de la ficha, idioma `es`.
3. Pega el cuerpo tal cual, **incluidos emojis y saltos de línea**.
4. Carga los valores de ejemplo de cada variable.
5. *Submit for WhatsApp Approval* con la categoría indicada.
6. Cuando quede `approved`, copia el `ContentSid` (`HX…`) y regístralo con
   **`scripts/whatsapp_content_sids.sql`**: trae los cinco `UPDATE` con el
   `message_type` que le corresponde a cada plantilla, más un `SELECT` final
   para verificar que las cinco filas quedaron completas.

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

## Respaldo si Meta rechaza el código de recuperación

Solo si `cashtruck_recuperacion_contrasena` no pasa por exigir el formato de
`AUTHENTICATION`. Se crea con tipo de contenido `twilio/authentication`, y ahí
**el cuerpo no se escribe**: lo arma Meta a partir de dos opciones, caducidad de
10 minutos y recomendación de seguridad activada. Queda así:

```
*{{1}}* es tu código de verificación. Por tu seguridad, no lo compartas.

Este código caduca en 10 minutos.
```

Se pierde la marca, el saludo y los emojis —esa es justamente la limitación de
la categoría—, y la única variable pasa a ser el código:

| Posición | Clave interna | Valor de ejemplo |
| --- | --- | --- |
| `{{1}}` | `code` | 482913 |

Al usar el respaldo hay que alinear la copia local, porque cambian tanto el
texto como el orden de las variables:

```sql
UPDATE template
   SET template_content = '*${code}* es tu código de verificación. Por tu seguridad, no lo compartas.\n\nEste código caduca en 10 minutos.',
       provider_variables = 'code'
 WHERE medium = 'WhatsApp' AND message_type = 'PASSWORD_RECOVERY';
```

Con esta variante los `${name}` y `${minutes}` que envía `PasswordResetUseCase`
se ignoran, y los 10 minutos quedan fijos dentro de la plantilla aprobada.

---

## Al cambiar algo

Una plantilla aprobada **no se edita**: Meta obliga a crear otra y volver a
aprobarla. Quedaron acoplados a la plantilla estos valores:

| Si cambia… | Hay que rehacer |
| --- | --- |
| `truck.parameter.app-url` (hoy `https://truck.ccsoluciones.com.co`) | las tres bienvenidas |
| `Constants.PASSWORD_RESET_CODE_MINUTES` (hoy 10) | nada: viaja como variable `{{3}}`, salvo que se use la variante de respaldo |
| `Constants.SUBSCRIPTION_REMINDER_DAYS` (hoy 3) | nada: viaja como variable `{{3}}` |

Y en toda edición: cambia el texto en Twilio **y** en `template_content` de los
scripts SQL, o la auditoría dejará de reflejar lo que se envió.
