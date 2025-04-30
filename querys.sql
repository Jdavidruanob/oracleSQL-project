-- 1
SELECT
    l.titulo,
    l.isbn,
    e.calidad,
    e.tipoEjemplar,
    i.tipoIntercambio,
    us.idUsuario AS idSolicitante,
    us.nombre AS nombreSolicitante,
    uo.idUsuario AS idOferente,
    uo.nombre AS nombreOferente,
    LISTAGG(DISTINCT a.nombres || ' ' || a.apellidos, ', ') 
        WITHIN GROUP (ORDER BY a.nombres, a.apellidos) AS autores,
    LISTAGG(DISTINCT g.nombreGenero, ', ') 
        WITHIN GROUP (ORDER BY g.nombreGenero) AS generos,
    CASE 
        WHEN i.tipoIntercambio = 'TEMPORAL' THEN i.fechaInicio
        ELSE i.fechaPropuesta
    END AS fechaIntercambio
FROM INTERCAMBIO i
JOIN INTERCAMBIO_LIBRO il ON i.idIntercambio = il.idIntercambio
JOIN EJEMPLAR e ON il.idEjemplar = e.idEjemplar
JOIN LIBRO l ON e.idLibro = l.idLibro
JOIN USUARIO us ON i.idUsuarioSolicitante = us.idUsuario
JOIN USUARIO uo ON i.idUsuarioOferente = uo.idUsuario
LEFT JOIN LIBRO_AUTOR la ON l.idLibro = la.idLibro
LEFT JOIN AUTOR a ON la.idAutor = a.idAutor
LEFT JOIN LIBRO_GENERO lg ON l.idLibro = lg.idLibro
LEFT JOIN GENERO g ON lg.idGenero = g.idGenero
WHERE 
    (
        (i.tipoIntercambio = 'TEMPORAL' AND i.fechaInicio BETWEEN TO_DATE('2023-01-01','YYYY-MM-DD') AND TO_DATE('2025-12-31','YYYY-MM-DD'))
        OR
        (i.tipoIntercambio = 'PERMANENTE' AND i.fechaPropuesta BETWEEN TO_DATE('2023-01-01','YYYY-MM-DD') AND TO_DATE('2025-12-31','YYYY-MM-DD'))
    )
GROUP BY 
    l.titulo, l.isbn, e.calidad, e.tipoEjemplar, i.tipoIntercambio,
    us.idUsuario, us.nombre, uo.idUsuario, uo.nombre,
    CASE 
        WHEN i.tipoIntercambio = 'TEMPORAL' THEN i.fechaInicio
        ELSE i.fechaPropuesta
    END;

-- 2
SELECT 
    u.idUsuario,
    u.nombre,
    u.email,
    SUM(d.puntosAsignados) AS saldo
FROM USUARIO u
JOIN DONACION d ON u.idUsuario = d.idUsuario
GROUP BY u.idUsuario, u.nombre, u.email
ORDER BY saldo DESC;


-- 3

SELECT 
    TO_CHAR(
        CASE 
            WHEN i.tipoIntercambio = 'TEMPORAL' THEN i.fechaInicio
            ELSE i.fechaPropuesta
        END,
        'MM-YYYY'
    ) AS mes_anio,
    COUNT(*) AS total_libros
FROM INTERCAMBIO i
JOIN INTERCAMBIO_LIBRO il ON i.idIntercambio = il.idIntercambio
GROUP BY 
    TO_CHAR(
        CASE 
            WHEN i.tipoIntercambio = 'TEMPORAL' THEN i.fechaInicio
            ELSE i.fechaPropuesta
        END,
        'MM-YYYY'
    )
HAVING COUNT(*) > 3 -- X deseado
ORDER BY mes_anio;

--4
SELECT 
    u.idUsuario,
    u.nombre,
    COALESCE(entregados.cantidad, 0) AS libros_entregados,
    COALESCE(recibidos.cantidad, 0) AS libros_recibidos,
    COALESCE(donados.cantidad, 0) AS libros_donados,
    COALESCE(recompensados.cantidad, 0) AS libros_recompensados
FROM USUARIO u

LEFT JOIN (
    SELECT 
      i.idUsuarioSolicitante AS idUsuario,
      COUNT(*) AS cantidad
    FROM INTERCAMBIO_LIBRO il
    JOIN INTERCAMBIO i ON il.idIntercambio = i.idIntercambio
    WHERE il.rol = 'ENTREGADO'
    GROUP BY i.idUsuarioSolicitante
) entregados
  ON u.idUsuario = entregados.idUsuario

LEFT JOIN (
    SELECT 
      i.idUsuarioSolicitante AS idUsuario,
      COUNT(*) AS cantidad
    FROM INTERCAMBIO_LIBRO il
    JOIN INTERCAMBIO i ON il.idIntercambio = i.idIntercambio
    WHERE il.rol = 'RECIBIDO'
    GROUP BY i.idUsuarioSolicitante
) recibidos
  ON u.idUsuario = recibidos.idUsuario

LEFT JOIN (
    SELECT 
      d.idUsuario,
      COUNT(*) AS cantidad
    FROM DONACION d
    GROUP BY d.idUsuario
) donados
  ON u.idUsuario = donados.idUsuario

LEFT JOIN (
    SELECT 
      d.idUsuario,
      COUNT(*) AS cantidad
    FROM DONACION_RECOMPENSA dr
    JOIN DONACION d 
      ON dr.idDonacion = d.idDonacion
    GROUP BY d.idUsuario
) recompensados
  ON u.idUsuario = recompensados.idUsuario

WHERE u.tipoUsuario = 'NORMAL'
ORDER BY u.nombre;

-- 5
SELECT 
    u.idUsuario,
    u.nombre,
    u.email,
    u.telefono,
    u.direccion,
    l.idLibro,
    l.titulo,
    i.fechaInicio,
    i.fechaFin
FROM INTERCAMBIO i
JOIN USUARIO u ON (i.idUsuarioSolicitante = u.idUsuario OR i.idUsuarioOferente = u.idUsuario)
JOIN INTERCAMBIO_LIBRO il ON i.idIntercambio = il.idIntercambio
JOIN EJEMPLAR e ON il.idEjemplar = e.idEjemplar
JOIN LIBRO l ON e.idLibro = l.idLibro
WHERE i.tipoIntercambio = 'TEMPORAL'
  AND i.fechaFin BETWEEN SYSDATE AND SYSDATE + 30
ORDER BY i.fechaFin;

-- 6
WITH book_authors AS (
  SELECT 
    la.idLibro,
    LISTAGG(a.nombres || ' ' || a.apellidos, ', ') 
      WITHIN GROUP (ORDER BY a.apellidos) AS autores
  FROM LIBRO_AUTOR la
  JOIN AUTOR a 
    ON la.idAutor = a.idAutor
  GROUP BY la.idLibro
)
SELECT
  u.idUsuario,
  u.nombre AS nombreUsuario,
  d.idDonacion,
  d.fechaSolicitud,
  -- Libros que el usuario dono
  LISTAGG(
    b1.titulo || 
    ' (' || ba1.autores || ', ' || e_don.tipoEjemplar || ')'
    , '; '
  ) WITHIN GROUP (ORDER BY b1.titulo) AS libros_donados,
  -- Libros que recibió en recompensa por esa donación
  LISTAGG(
    b2.titulo || 
    ' (' || ba2.autores || ', ' || e_rec.tipoEjemplar || ')'
    , '; '
  ) WITHIN GROUP (ORDER BY b2.titulo) AS libros_recompensa
FROM DONACION d
JOIN USUARIO u 
  ON d.idUsuario = u.idUsuario
-- Ejemplares donados en esta donación
LEFT JOIN EJEMPLAR e_don 
  ON e_don.idDonacion = d.idDonacion
LEFT JOIN LIBRO b1 
  ON e_don.idLibro = b1.idLibro
LEFT JOIN book_authors ba1 
  ON ba1.idLibro = b1.idLibro
-- Ejemplares recibidos en recompensa
LEFT JOIN DONACION_RECOMPENSA dr 
  ON dr.idDonacion = d.idDonacion
LEFT JOIN EJEMPLAR e_rec 
  ON e_rec.idEjemplar = dr.idEjemplar
LEFT JOIN LIBRO b2 
  ON e_rec.idLibro = b2.idLibro
LEFT JOIN book_authors ba2 
  ON ba2.idLibro = b2.idLibro
GROUP BY 
  u.idUsuario, u.nombre, d.idDonacion, d.fechaSolicitud
ORDER BY d.fechaSolicitud DESC;

/* 7
- Obtener los usuarios cuyo saldo de puntos de donación 
(suma de puntosAsignados) supere el promedio de puntos donados por usuario.

Permite identificar a los moyores donadores que aportan por encima del promedio
 de la comunidad, para reconocerlos o premiarlos.
 */

SELECT 
  u.idUsuario,
  u.nombre,
  s.total_puntos
FROM (
  -- saldo por usuario
  SELECT 
    idUsuario, 
    SUM(puntosAsignados) AS total_puntos
  FROM DONACION
  GROUP BY idUsuario
) s
JOIN USUARIO u ON u.idUsuario = s.idUsuario
WHERE s.total_puntos > (
  -- promedio de todos los saldos
  SELECT AVG(total_puntos) 
  FROM (
    SELECT SUM(puntosAsignados) AS total_puntos
    FROM DONACION
    GROUP BY idUsuario
  )
);

/* 8
Listar los libros que han sido donados (aparecen en EJEMPLAR) 
pero nunca han sido intercambiados (no aparecen en INTERCAMBIO_LIBRO). 

Ayuda a detectar ejemplares que siguen en inventario de donación y nunca
entraron a ningún intercambio, para impulsar su circulación.
*/

-- Libros donados
SELECT DISTINCT e.idLibro
FROM EJEMPLAR e
MINUS
-- Libros intercambiados
SELECT DISTINCT e2.idLibro
FROM INTERCAMBIO_LIBRO il
JOIN EJEMPLAR e2 ON il.idEjemplar = e2.idEjemplar;


/* 9
Mostrar todas las donaciones junto con la fecha de recompensa (si existe), incluyendo
 las donaciones que aún no tienen ejemplares asignados como recompensa. 

Permite ver de un vistazo qué donaciones están pendientes de 
recompensa y cuáles ya se completaron
 */

 SELECT
  d.idDonacion,
  d.fechaSolicitud,
  dr.fechaRecompensa
FROM DONACION d
LEFT JOIN DONACION_RECOMPENSA dr
  ON d.idDonacion = dr.idDonacion
ORDER BY d.fechaSolicitud;

/* 10

Obtener un reporte detallado del inventario de ejemplares, mostrando para cada combinación de tipo de ejemplar
 (DIGITAL/FISICO) y calidad (Nuevo/Usado), el total de ejemplares, cuántos 
están disponibles, cuántos no están disponibles y el porcentaje de disponibilidad. 
Permite a los administradores de la plataforma:

- Evaluar rápidamente la salud del inventario.

- Identificar categorías (tipo+calidad) con bajo nivel de disponibilidad.

- Planear compra de licencias digitales o reacondicionamiento de ejemplares físicos.
*/

SELECT
  e.tipoEjemplar,
  e.calidad,
  COUNT(*) AS total_ejemplares,
  SUM(CASE WHEN e.disponibilidad = 1 THEN 1 ELSE 0 END) AS disponibles,
  SUM(CASE WHEN e.disponibilidad = 0 THEN 1 ELSE 0 END) AS no_disponibles,
  ROUND(
    100 * SUM(CASE WHEN e.disponibilidad = 1 THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0),
    2
  ) AS pct_disponibles
FROM EJEMPLAR e
GROUP BY
  e.tipoEjemplar,
  e.calidad
ORDER BY
  e.tipoEjemplar,
  e.calidad;
