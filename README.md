# Hive Avances

App web movil para levantar avances diarios por habitacion usando la estructura del archivo `CHECK LIST ULTIMO (2).xlsx`.

## Uso rapido

1. Abre `index.html` en el navegador.
2. Selecciona habitacion, fecha y responsable.
3. Marca cada partida como pendiente, defectuoso o completado.
4. Agrega observaciones y fotos cuando aplique.
5. Usa `Reporte diario` para copiar, compartir o exportar CSV.

Los datos se guardan en el navegador con `localStorage`, por lo que cada celular conserva sus capturas localmente.

## Para usar desde celular en la misma red

En esta carpeta puedes levantar un servidor local:

```powershell
npx http-server -p 5173
```

Despues abre desde el celular:

```text
http://IP-DE-LA-COMPUTADORA:5173
```
