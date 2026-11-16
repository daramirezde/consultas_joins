-- Módulo 5: Pre-entrega - Consultas con JOINs y UNION ALL

USE Ventas_Tech_DB;
GO

-- ============================================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- ============================================================================
SELECT 
    v.id_venta,
    v.fecha_venta AS fecha,
    c.id_cliente,
    c.nombre AS cliente,
    c.ciudad AS region,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
GO

-- Hallazgo: Las 10 ventas registradas concentran el mayor volumen de facturación en la categoría Computación.

-- ============================================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que aún no han realizado ninguna compra.
-- ============================================================================
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- Hallazgo: No hay clientes registrados que no hayan comprado (0 de 5 clientes). Para la organización esto implica que el foco con la BD debe estar en retención y recompra.

-- ============================================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo que no tienen movimiento, para que el área de producto evalúe promociones o ajustes de inventario.
-- ============================================================================
SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- Hallazgo:No hay productos sin ventas (0 de 6 productos). Para el área de producto esto confirma que todo el portafolio tiene rotación activa y no existe inventario que requiera liquidación o promociones.

-- ============================================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: simular y comparar el rendimiento comercial entre dos canales operativos (Online vs. Presencial) segmentando las transacciones por período.
-- ============================================================================
SELECT 
    canal, 
    COUNT(*) AS cantidad_operaciones,
    SUM(total) AS total_canal
FROM (
    SELECT 
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE cantidad <= 2
    
    UNION ALL
    
    SELECT 
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE cantidad >= 2
) AS consolidado
GROUP BY canal
ORDER BY total_canal DESC;
GO

-- Hallazgo: El canal Online (más de 2 unidades vendidas) facturó $5310.00 en 6 operaciones, frente a los $4674.00.
