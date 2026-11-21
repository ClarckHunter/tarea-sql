
-- =========================================================
-- DDL: CREATE 3 TABLAS
-- =========================================================
CREATE TABLE estados (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150)
);

CREATE TABLE etiquetas (
    id_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    color VARCHAR(20)
);

CREATE TABLE tareas (
    id_tarea INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_limite DATE,
    estado_id INT,
    etiqueta_id INT
);

-- =========================================================
-- DDL: ALTER TABLE — 2 por tabla
-- =========================================================

-- estados: 2 ALTER
ALTER TABLE estados
    ADD CONSTRAINT uq_estados_nombre UNIQUE (nombre);

ALTER TABLE estados
    ADD CONSTRAINT chk_estados_nombre CHECK (nombre <> '');

-- etiquetas: 2 ALTER
ALTER TABLE etiquetas
    ADD CONSTRAINT uq_etiquetas_nombre UNIQUE (nombre);

ALTER TABLE etiquetas
    ADD CONSTRAINT chk_etiquetas_nombre CHECK (nombre <> '');

-- tareas: 2 ALTER — aquí se agregan las llaves foráneas
ALTER TABLE tareas
    ADD CONSTRAINT fk_tareas_estado
    FOREIGN KEY (estado_id) REFERENCES estados(id_estado);

ALTER TABLE tareas
    ADD CONSTRAINT fk_tareas_etiqueta
    FOREIGN KEY (etiqueta_id) REFERENCES etiquetas(id_etiqueta);

-- =========================================================
-- DML: INSERT
-- 3 estados
-- =========================================================
INSERT INTO estados (id_estado, nombre, descripcion) VALUES
(1, 'Pendiente',  'Tarea pendiente de iniciar'),
(2, 'En proceso', 'Tarea que se está realizando'),
(3, 'Terminada',  'Tarea finalizada correctamente');

-- 3 etiquetas/categorías
INSERT INTO etiquetas (id_etiqueta, nombre, color) VALUES
(1, 'Hogar',    '#FF0000'),
(2, 'Trabajo',  '#0000FF'),
(3, 'Personal', '#00AA00');

-- 5 tareas
INSERT INTO tareas (id_tarea, nombre, descripcion, fecha_creacion, fecha_limite, estado_id, etiqueta_id) VALUES
(1, 'Sacar la basura',          'Sacar la basura antes de las 8 pm', '2026-01-05 09:00:00', '2026-01-05', 2, 1),
(2, 'Comprar víveres',          'Comprar fruta, verdura y leche',    '2026-02-10 10:30:00', '2026-02-11', 3, 1),
(3, 'Preparar reporte mensual', 'Preparar reporte de ventas',        '2026-03-15 08:00:00', '2026-03-20', 2, 2),
(4, 'Llamar al médico',         'Agendar cita médica',               '2025-12-20 16:00:00', '2025-12-22', 3, 3),
(5, 'Limpiar escritorio',       'Organizar documentos y cables',     '2026-01-20 11:00:00', '2026-01-21', 1, 1);

-- =========================================================
-- DML: SELECT
-- =========================================================

-- Buscar la tarea por nombre "Sacar la basura"
SELECT *
FROM tareas
WHERE nombre = 'Sacar la basura';

-- Buscar tareas completadas/terminadas
SELECT t.*
FROM tareas t
INNER JOIN estados e ON t.estado_id = e.id_estado
WHERE e.nombre = 'Terminada';

-- Tareas ordenadas de la más antigua a la más reciente
SELECT *
FROM tareas
ORDER BY fecha_creacion ASC;

-- SELECT adicionales para cubrir 2 por tabla
SELECT *
FROM estados;

SELECT e.nombre AS estado, COUNT(t.id_tarea) AS total_tareas
FROM estados e
LEFT JOIN tareas t ON t.estado_id = e.id_estado
GROUP BY e.id_estado, e.nombre;

SELECT *
FROM etiquetas;

SELECT et.nombre AS etiqueta, COUNT(t.id_tarea) AS total_tareas
FROM etiquetas et
LEFT JOIN tareas t ON t.etiqueta_id = et.id_etiqueta
GROUP BY et.id_etiqueta, et.nombre;

-- =========================================================
-- DML: UPDATE — 1 por tabla
-- =========================================================

-- Actualizar una tarea de "En proceso" a "Terminada"
UPDATE tareas
SET estado_id = (SELECT id_estado FROM estados WHERE nombre = 'Terminada')
WHERE nombre = 'Sacar la basura'
  AND estado_id = (SELECT id_estado FROM estados WHERE nombre = 'En proceso');

-- UPDATE adicionales para cubrir 1 por tabla
UPDATE estados
SET descripcion = 'Tarea pendiente de iniciar o asignar'
WHERE nombre = 'Pendiente';

UPDATE etiquetas
SET color = '#CC0000'
WHERE nombre = 'Hogar';

-- =========================================================
-- DML: DELETE — 2 por tabla
-- =========================================================

-- Borrar 2 tareas
DELETE FROM tareas
WHERE nombre = 'Limpiar escritorio';

DELETE FROM tareas
WHERE nombre = 'Llamar al médico';

-- Para poder borrar 2 etiquetas, reasignamos las tareas a "Hogar"
UPDATE tareas
SET etiqueta_id = 1
WHERE etiqueta_id IN (2, 3);

DELETE FROM etiquetas
WHERE nombre = 'Trabajo';

DELETE FROM etiquetas
WHERE nombre = 'Personal';

-- Para poder borrar 2 estados, reasignamos las tareas a "Terminada"
UPDATE tareas
SET estado_id = 3
WHERE estado_id IN (1, 2);

DELETE FROM estados
WHERE nombre = 'Pendiente';

DELETE FROM estados
WHERE nombre = 'En proceso';

-- =========================================================
-- DDL: DROP — eliminar la tabla de categorías/etiquetas
-- =========================================================
-- Primero se elimina la FK que apunta a etiquetas
ALTER TABLE tareas
    DROP FOREIGN KEY fk_tareas_etiqueta;

-- Luego se elimina la tabla de categorías/etiquetas
DROP TABLE etiquetas;