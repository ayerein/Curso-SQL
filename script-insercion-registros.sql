INSERT INTO descuentos(descuento_nombre)
VALUES (""), ("2do al 80%"), ("30%"), ("15%"), ("2x1");

INSERT INTO categorias(nombre_categoria)
VALUES  ("Almacén"), ("Bebidas"), ("Limpieza"), ("Kiosco");

INSERT INTO productos(nombre_producto, marca_producto, precio_producto, img_producto, categoria_producto, descuentos, stock)
VALUES 
("Fideos Spaghetti N7 Lucchetti 500 Gr.",  "Lucchetti", 1, "url img", 3, 1, 30),
("Fideos Tirabuzon N28 Matarazzo 500 Gr.",  "Matarazzo", 1575, "url img", 1, 1, 47),
("Harina Leudante Pureza 1 Kg.",  "Pureza",  1280, "url img", 1, 2, 54),
("Gaseosa Coca-Ca Sabor Original 2.25 Lt.",  "Coca-Cola", 4100, "url img", 2, 5, 34),
("Coca Cola Zero 1,25 Lt.",  "Coca-Cola", 2280, "url img", 2, 1, 47),
("Gaseosa Sprite Lima-Limón 2,25 Lt.",  "Sp", 4100, "url img", 2, 5, 27),
("Lavandina Ayudín Original 1 Lt.",  "Ayudín", 860, "url img", 3, 3, 32),
("Limpiador Desinfectante Ayudín Lavanda 900 Ml.",  "Ayudín", 1510, "url img", 3, 1, 40),
("Limpiador Poett Líquido Fragancia Primavera 900 Ml.",  "Poett", 1500, "url img", 3, 1, 43),
("Chocolate con Maní Cofler Block 38 Gr.",  "Cofler", 345, "url img", 4, 3, 30),
("Chicle Bubbaloo Menta 5 Gr.",  "Bubbaloo", 80, "url img", 4, 4, 52),
("Alfajor Tita 36 Gr.",  "Tita", 745, "url img", 4, 4, 6)
;



CALL AgregarProducto("Gaseosa Cola Light Cunnington 2,25 Lt.", "CUNNINGTON",1645, "url img", 2, 2, 20);
CALL ModificarNombreProducto(4, "Gaseosa Coca-Cola Sabor Original 2.25 Lt.2");
CALL ModificarMarcaProducto(6, "Sprite");
CALL ModificarImgProducto(7, "Nueva url");
CALL ModificarPrecioProducto(1, 1365);
CALL ModificarCategoriaProducto(1, 1);
CALL ModificarDescuentoProducto(12, 5);
CALL ModificarStock(12, 40);
CALL EliminarProducto(5);
CALL EliminarProducto(6);
CALL RecuperarProductoEliminado(5);

CALL RegistrarCliente("Gabriel", "Ferrari", 33331239, "email1@prueba.com");
CALL RegistrarCliente("Ariel", "Hernandez", 21331239, "email2@prueba.com");
CALL RegistrarCliente("Laura", "chavez", 24531239, "email3@prueba.com");
CALL RegistrarCliente("Horacio", "Caceres", 30831239, "email4@prueba.com");
CALL RegistrarCliente("Lina", "Nahuel", 20331239, "email5@prueba.com");
CALL RegistrarCliente("Carlos", "Sanchez", 43331239, "email6@prueba.com");
CALL RegistrarCliente("Maria", "Fernandez", 22331239, "email7@prueba.com");

CALL AgregarProductoAlCarrito(1,2,7);
CALL AgregarProductoAlCarrito(1,3,2);
CALL AgregarProductoAlCarrito(1,1,3);
CALL AgregarProductoAlCarrito(2,7,6);
CALL AgregarProductoAlCarrito(2,3,1);
CALL AgregarProductoAlCarrito(3,1,2);
CALL AgregarProductoAlCarrito(3,3,1);
CALL AgregarProductoAlCarrito(3,8,3);
CALL AgregarProductoAlCarrito(3,9,4);
CALL AgregarProductoAlCarrito(4,9,1);
CALL AgregarProductoAlCarrito(5,12,6);
CALL AgregarProductoAlCarrito(5,11,4);
CALL AgregarProductoAlCarrito(5,2,1);
CALL AgregarProductoAlCarrito(5,1,2);
CALL AgregarProductoAlCarrito(6,9,3);
CALL AgregarProductoAlCarrito(6,8,4);
CALL AgregarProductoAlCarrito(7,7,1);
CALL AgregarProductoAlCarrito(7,3,2);
CALL AgregarProductoAlCarrito(7,1,1);

CALL CrearOrdenDeCompra(1, "Direccion 12", "tarjeta");
CALL CrearOrdenDeCompra(2, "Direccion 13", "app");
CALL CrearOrdenDeCompra(3, "Direccion 14", "efectivo");
CALL CrearOrdenDeCompra(4, "Direccion 31", "tarjeta");
CALL CrearOrdenDeCompra(5, "Direccion 21", "app");
CALL CrearOrdenDeCompra(6, "Direccion 22", "tarjeta");
CALL CrearOrdenDeCompra(7, "Direccion 51", "tarjeta");

-- Ventas por mes
SELECT 
    DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes,
    COUNT(*) AS total_pedidos,
    SUM(total) AS ingresos_totales
FROM ordenes_compra
GROUP BY mes
ORDER BY mes;

-- Productos más vendidos
SELECT 
    p.id_producto,
    p.nombre_producto,
    SUM(od.cantidad) AS total_vendido
FROM 
    orden_detalle od
JOIN 
    productos p ON od.id_producto = p.id_producto
GROUP BY 
    p.id_producto
ORDER BY 
    total_vendido DESC;

-- Productos agotados o sin stock
SELECT * FROM productos WHERE stock = 0 AND nombre_producto != 'Producto eliminado';

-- Metodos de pago más utilizados
SELECT metodo_pago, COUNT(*) AS cantidad_ordenes FROM ordenes_compra GROUP BY metodo_pago ORDER BY cantidad_ordenes DESC;

-- Descuentos más usados
SELECT 
	d.descuento_nombre,
    SUM(p.descuentos) AS total_vendido_descuento
FROM 
    productos p
JOIN 
	orden_detalle od ON od.id_producto = p.id_producto
JOIN
	descuentos d ON d.id_descuento = p.descuentos
GROUP BY 
    descuentos
ORDER BY 
    total_vendido_descuento DESC;

-- Ventas por categoria 
SELECT 
    c.nombre_categoria AS Categoría,
    SUM(od.cantidad * p.precio_producto) AS Ingresos_Totales,
    COUNT(DISTINCT oc.id_orden) AS Órdenes,
    SUM(od.cantidad) AS Unidades_Vendidas
FROM 
    orden_detalle od
JOIN 
    productos p ON od.id_producto = p.id_producto
JOIN 
    categorias c ON p.categoria_producto = c.id_categoria
JOIN 
    ordenes_compra oc ON od.id_orden = oc.id_orden
GROUP BY 
    c.nombre_categoria
ORDER BY 
    Ingresos_Totales DESC;