# Features propuestas — seguimiento comunitario de animales

Resumen de la sesión de análisis del 2026-08-21. Contexto para continuar la conversación.

## Estado del sistema al momento del análisis

- Rails 8, SQLite, Active Storage para fotos, auth con password + Google OAuth.
- Modelo actual: `User` → `Account` → `Session`; `User` → `Report` (1:N) → `Location` (1:1) + `Animal` (1:1).
- `Report` tiene flujo de creación en 2 pasos y flag `draft`. Listado paginado con tabs "mis reportes" / "comunidad".
- Sin página de detalle de reporte, sin mapa, sin búsqueda/filtros, sin estados de resolución, sin roles, sin contacto entre usuarios.

## Idea central del usuario

La comunidad pueda actualizar la ubicación de un mismo animal reportando avistamientos sucesivos, y con eso construir un mapa de triangulación que estime dónde puede estar ahora, considerando su movilidad probable (tamaño, edad, si está lastimado, etc.). Además, sumar un estado de "tránsito" (alguien lo aloja sin adoptarlo) y que la adopción final la autorice Cuidado Animal (dependencia del municipio).

## Cambio de modelo necesario (base de todo lo demás)

Hoy `Animal` es 1:1 con `Report` (una foto fija en el tiempo). Para soportar seguimiento hace falta:

- **`Animal`** deja de pertenecer a un solo `Report` y pasa a ser la entidad persistente (ficha del animal).
- **`Sighting`** (avistamiento) nuevo modelo: `belongs_to :animal`, `belongs_to :user`, `belongs_to :location`, `datetime`, `kind` (`avistado`, `en_transito`, `adoptado`, `perdido_inicial`). El `Report` original pasa a ser el primer `Sighting`.
- Esto habilita `animal.sightings.order(:created_at)` como traza de puntos para la triangulación.

## Lista de features

**Base estructural (prerequisito)**
1. Separar `Animal` de `Report` + nuevo modelo `Sighting`.

**Descubrimiento y seguimiento comunitario**
2. Vinculación de nuevos reportes a un animal ya existente (búsqueda por especie/tamaño/color/zona/foto).
3. Línea de tiempo de avistamientos por animal.
4. Mapa de triangulación: zona probable actual por centroide ponderado por recencia de avistamientos.
5. Radio de búsqueda dinámico según perfil de movilidad (tamaño, edad, lastimado/ansioso/agresivo).
6. Página de detalle de un reporte/animal individual (falta hoy, es base visual para 2–5).
7. Búsqueda y filtros generales (especie, tamaño, estado, urgencia, distancia).

**Ciclo de vida del animal**
8. Estado "en tránsito": alguien lo aloja temporalmente sin adoptarlo (saca al animal de la búsqueda activa).
9. Estados generales: perdido → en tránsito → en proceso de adopción → adoptado / encontrado por su dueño.
10. Favoritos/seguimiento: usuarios se suscriben a novedades de un animal puntual.

**Adopción y rol municipal**
11. Rol institucional "Cuidado Animal" (dependencia del municipio).
12. Flujo de autorización de adopción: solicitud → revisión municipal → aprobación/rechazo con motivo y trazabilidad.
13. Solo cuentas con ese rol pueden marcar un animal como `adoptado`.

**Comunicación**
14. Contacto directo entre usuarios (reportante, quien tiene el tránsito, interesado en adoptar).
15. Notificaciones de novedades (nuevo avistamiento, cambio de estado, aprobación de adopción).
16. Comentarios en el reporte para coordinación comunitaria.

**Moderación y gestión**
17. Roles de moderador para resolver vinculaciones ambiguas entre avistamientos y animales.
18. Panel de estadísticas para el municipio (animales activos, en tránsito, adoptados, zonas con más reportes).

**Pendientes menores del sistema actual**
19. Completar `pages#home` (hoy es un placeholder vacío).

## Fases sugeridas

1. Base: separar `Animal` de `Report`, introducir `Sighting`.
2. Vinculación + historial de avistamientos.
3. Mapa de triangulación (visualización + heurística de zona probable).
4. Estado de tránsito.
5. Adopción con autorización municipal.

## Próximo paso pendiente

Diseño detallado de la migración de datos de la fase base (separar `Animal` de `Report`, introducir `Sighting`), o alternativamente un diagrama/mockup del flujo completo antes de tocar el modelo — a decidir en la próxima sesión.
