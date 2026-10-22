# Evento-Plantilla

Plantilla de evento con portada, formulario público gratuito y administración privada con Supabase.

## Archivos
- `index.html`: página de asistentes
- `admin.html`: acceso privado y panel
- `styles.css`: diseño adaptable
- `public.js`: lectura del evento e inscripción
- `admin.js`: acceso, edición, listado y exportación CSV
- `config.js`: URL, clave **pública** y slug de evento
- `supabase.sql`: creación de tablas y políticas RLS

## Puesta en marcha
1. Crea un proyecto nuevo en https://supabase.com/dashboard (o reutiliza uno, comprobando primero que los nombres SQL no colisionan).
2. Abre SQL Editor y ejecuta `supabase.sql` completo.
3. En Project Settings > API / API Keys copia la **Project URL** y la **publishable key** (o la anon pública del proyecto). Pégalas en `config.js`. Nunca uses `service_role` ni una clave secreta en archivos web.
4. En Authentication > Users, crea un usuario con correo y contraseña para el administrador. Copia el **UUID** y ejecuta en SQL Editor: `insert into public.admin_users(user_id) values ('AQUI-UUID');`. No uses el correo en esa sentencia.
5. Sube los siete archivos a un repositorio de GitHub nuevo, por ejemplo `Evento-Plantilla`. En Settings > Pages > Deploy from a branch selecciona `main` y `/ (root)`.
6. Visita la URL de GitHub Pages para entrar en el formulario; añade `admin.html` a la dirección para abrir el panel. Inicia sesión y cambia título, descripción, fecha, ubicación e imagen mediante una **URL pública HTTPS** del cartel.
7. Prueba una inscripción desde el formulario y verifica que aparece en la tabla del panel y en el CSV.

## Limitaciones importantes antes de anunciar eventos reales
- Los datos se guardan en Supabase, pero **no hay correo de confirmación**: la confirmación aparece en pantalla. Para correos automáticos conviene añadir una Edge Function y un proveedor de correo.
- El formulario incluye una trampa anti-bots básica, pero para difusión pública se recomienda añadir CAPTCHA/Turnstile y protección contra altas masivas en servidor (Edge Function/rate limiting).
- El panel carga hasta 5000 registros; para eventos mayores, añade paginación.
- El CSV contiene datos personales: custodiarlo con cuidado, no compartirlo libremente y eliminar datos según la política de conservación.
- Completa la información legal de protección de datos del **organizador real** (responsable, finalidad, base jurídica, conservación, contacto y derechos). El texto actual es una plantilla, no constituye por sí solo un aviso legal completo.
- Esta plantilla gestiona un evento por despliegue (un `eventSlug`). Puedes duplicarla y personalizar el slug para otras webs/eventos, o ampliar el panel a múltiples eventos.
- Imagen: se configura por URL; no incluye aún subida de archivos a Supabase Storage.
- RLS protege el acceso a datos: los visitantes pueden insertar registros, pero no ver listas; solo usuarios autorizados pueden ver datos y editar el evento.
