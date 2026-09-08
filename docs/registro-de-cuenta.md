# Registro de cuenta — contrato

Insumo para el formulario de creación de cuenta. El registro es **público**: no
exige sesión, solo `X-API-KEY`. La cuenta queda **activa** desde el primer
minuto, sin verificación previa.

El alta reutiliza el mismo camino de `POST /owner/save`; lo nuevo es una capa
delante que decide qué campos del cuerpo se descartan y valida la unicidad antes
de tocar la base. Lo único que se tocó de lo existente es una sobrecarga de
`OwnerUseCase.save` para poder pasarle la vigencia: el alta administrativa sigue
entrando con sus 12 meses y se comporta igual que antes.

---

## 1. Cabeceras

Las tres peticiones del formulario van con **una sola cabecera**:

```
X-API-KEY: <llave>
Content-Type: application/json     (solo en el POST)
```

Sin `X-USER-ID` y sin `AUTHORIZED_TOKEN`. Ese par solo lo lee `/owner/save`
para decidir si quien llama es administrador; en el registro no aplica, y
justamente por eso el servidor asume que **no** lo es.

---

## 2. `POST /security/register`

### Cuerpo

| Campo | Tipo | Obligatorio | Nota |
| --- | --- | --- | --- |
| `name` | string | sí | |
| `email` | string | sí | Único en todo el sistema |
| `cellPhone` | string | sí | 10 dígitos; los espacios se eliminan al guardar |
| `documentTypeId` | int | sí | De `GET /common/getDocumentTypes` |
| `documentNumber` | string | sí | Único en todo el sistema |
| `password` | string | sí | **Base64 del texto plano**, ver abajo |
| `cityId` | int | no | De `GET /common/getCities` |
| `genderId` | int | no | De `GET /common/getGenders` |
| `birthdate` | `yyyy-MM-dd` | no | |
| `photo` | string | no | URL devuelta por `/common/upload-photo` |
| `maxVehicles` | int | no | Cupo de vehículos, entre 1 y 999. Si no llega, 3 |
| `isDriver` | bool | no | `true` si el propietario además conduce. Si no llega, `false` |
| `licenseCategory` | string | solo si `isDriver` | Categoría de la licencia |
| `licenseNumber` | string | solo si `isDriver` | Número de la licencia |
| `licenseExpiry` | `yyyy-MM-dd` | solo si `isDriver` | Vencimiento de la licencia |

**Ojo con `password`.** Aquí viaja en **Base64 del texto plano**, no en SHA-512
como en `/security/authentication`. La razón es que el servidor necesita la
contraseña legible una sola vez para enviarla en la bienvenida por WhatsApp;
después la cifra en SHA-512 y ya no se puede recuperar. Es la misma convención
que usa hoy `/owner/save`.

### Campos que el servidor fija e ignora si llegan

| Campo | Valor que impone el servidor |
| --- | --- |
| `id` | `null` — el registro siempre crea, nunca edita |
| `user` | El usuario que crea el propio servidor |
| `status` (del usuario) | `"Activo"` |
| `subscriptionEndDate` | Hoy + **1 mes**, en `America/Bogota` |

`user` e `id` no son cosmética: sin descartarlos, un cuerpo con
`"user": {"id": 1}` colgaría la cuenta nueva de un usuario ya existente.

**`isDriver` sí llega del formulario.** Cuando viene en `true`, el registro se
comporta igual que `/owner/save`: al usuario se le asigna también el rol **3
(Conductor)** y se crea el **conductor espejo** en `driver` con los mismos
datos personales del propietario más la licencia del cuerpo. Como en `driver`
la licencia es `NOT NULL`, los tres campos (`licenseCategory`,
`licenseNumber`, `licenseExpiry`) son obligatorios en ese caso: si falta
alguno, la respuesta es **400** con `register.invalid.<campo>` en vez del 500
genérico que salía antes al llegar el insert.

**`maxVehicles` sí llega del formulario**, con techo de **999**. Fuera del rango
1–999 la respuesta es 400 con `register.invalid.maxVehicles`; si el campo no
viene, el alta aplica su defecto de 3. El techo existe porque el endpoint es
público y `maxVehicles` es lo que limita el plan.

### Lo que ocurre en el servidor

1. Crea el registro en `users` con estado `Activo` y contraseña SHA-512. **Sí,
   toda cuenta nueva crea usuario**: sin fila en `users` no hay con qué iniciar
   sesión. El propietario queda enlazado por `owner.user_id`, y el `userId` del
   usuario creado vuelve en la respuesta.
2. Le asigna el rol **2 (Propietario)**, y también el **3 (Conductor)** cuando
   `isDriver` es `true`.
3. Crea el propietario con el cupo recibido (o 3) y suscripción a **1 mes**.
   Si `isDriver` es `true`, crea además el conductor espejo en `driver`
   enlazado al mismo usuario y con `owner_id` del propietario recién creado.
4. Envía la bienvenida por WhatsApp. **Si el envío falla, la cuenta igual
   queda creada**: el mensaje es accesorio y el error se registra en el log.

### Respuestas

**201 — creada**

```jsonc
{
  "data": {
    "id": 87,
    "userId": 143,
    "name": "Enrique Castro Solís",
    "email": "enrique@correo.com",
    "documentNumber": "1032456789",
    "cellPhone": "3147235739",
    "isDriver": false,
    "maxVehicles": 5,
    "subscriptionEndDate": "2026-09-30",
    "status": "Activo"
  },
  "code": 201,
  "message": "CREATED",
  "pagination": null,
  "i18n": "register.created.ok"
}
```

Se devuelve este resumen y no la entidad completa a propósito: `Owner` arrastra
el usuario asociado y con él la contraseña cifrada, que en un endpoint abierto
no debe salir.

**400 — dato faltante o mal formado**

```jsonc
{ "code": 400, "message": "El celular debe tener 10 dígitos.", "i18n": "register.invalid.cellPhone" }
```

`i18n` es `register.invalid.<campo>`, con `<campo>` en: `name`, `email`,
`cellPhone`, `documentNumber`, `documentTypeId`, `password`, `maxVehicles`,
`licenseCategory`, `licenseNumber`, `licenseExpiry`, `payload`. El sufijo es el nombre exacto del campo del formulario, así que
sirve directo para marcar el input en rojo.

**409 — el valor ya está tomado**

```jsonc
{ "code": 409, "message": "Ya existe una cuenta con ese número de documento.", "i18n": "register.duplicate.documentNumber" }
```

`i18n` es `register.duplicate.<campo>`, con `<campo>` en: `documentNumber`,
`email`, `cellPhone`.

**429 — demasiados intentos**: 5 registros por IP cada 10 minutos.
`i18n`: `register.rate.limited`.

**500**: `i18n` `register.ko`.

---

## 3. `GET /security/checkAvailability?field=&value=`

Validador asíncrono, para usar en el `blur` de cada campo.

- `field` ∈ `documentNumber` | `email` | `cellPhone`. Cualquier otro valor → 400.
- `value` — el texto tal como lo escribió el usuario.

```jsonc
{
  "data": { "field": "email", "available": false },
  "code": 200,
  "message": "OK",
  "pagination": null,
  "i18n": "availability.check.ok"
}
```

Un mismo dato puede vivir en varias tablas, y se consultan todas: el correo en
`users`, `owner` y `driver`; el documento y el celular en `owner` y `driver`.
El celular se busca por todas sus formas (`3147235739`, `573147235739`,
`+573147235739`) porque quedó guardado de distinta manera según quién lo cargó;
comparar por igualdad exacta daría falsos "disponible".

**429**: 30 consultas por IP por minuto. `i18n`: `availability.rate.limited`.

El límite es un contador en memoria por instancia. Si mañana la aplicación
corre en varios nodos, el límite efectivo se multiplica por el número de nodos.
Es mitigación, no garantía: el lugar correcto para un límite duro es el proxy
que expone la API.

El validador nunca reemplaza la validación del `POST`. Entre el `blur` y el
envío del formulario alguien más pudo tomar el valor, así que el registro
vuelve a comprobarlo y puede responder 409 aunque el validador dijera que
estaba libre.

---

## 4. Catálogos — confirmado, sin cambios

`GET /common/getDocumentTypes`, `getGenders` y `getCities` ya responden solo con
`X-API-KEY`. `CommonController` no lee `X-USER-ID` en ningún método. No hubo
que tocar nada.

---

## 5. Dos cosas que quedan sobre la mesa

**El celular no tiene índice único en base de datos.** El registro nuevo sí lo
valida, pero los datos que ya están cargados pueden tener celulares repetidos, y
ese campo es la llave de la recuperación de contraseña: con duplicados,
`/security/forgotPassword` toma el primero que encuentre y el otro usuario
nunca podrá recuperar su clave. Añadir el `UNIQUE` exige antes limpiar los
duplicados existentes; queda pendiente de decidir.

**La API key es una constante en el código** (`CustomHeaderAuthFilter`) y viaja
en el frontend. Con el registro abierto, cualquiera que la extraiga del bundle
puede crear cuentas hasta el tope del límite por IP. El límite acota el daño, no
lo impide.
