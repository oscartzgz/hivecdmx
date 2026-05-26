# Publicar Hive Avances en Cloudflare

## Recursos necesarios

- Cloudflare Pages para la app.
- Cloudflare D1 para datos.
- Cloudflare R2 para fotos.
- HTTP Basic Auth con secretos `BASIC_AUTH_USER` y `BASIC_AUTH_PASS`.

## Pasos

1. Instalar Wrangler o usar el panel de Cloudflare.
2. Crear una base D1 llamada `hive_avances`.
3. Ejecutar `migrations/0001_initial.sql`.
4. Crear un bucket R2 llamado `hive-avances-photos`.
5. Reemplazar `database_id` en `wrangler.toml`.
6. Configurar secretos:

```powershell
wrangler secret put BASIC_AUTH_USER
wrangler secret put BASIC_AUTH_PASS
```

7. Publicar en Cloudflare Pages.

## Fotos

Las fotos se comprimen en el celular antes de subirlas. D1 guarda solo metadatos; R2 conserva la imagen como evidencia.
