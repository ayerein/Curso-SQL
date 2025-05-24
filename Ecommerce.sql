CREATE DATABASE IF NOT EXISTS ecommerce;

USE ecommerce;

CREATE TABLE categorias (
	id_categoria INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE productos (
	id_producto INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre_producto VARCHAR(150) NOT NULL,
    marca_producto VARCHAR(50) NOT NULL,
    precio_producto DECIMAL(10, 2) NOT NULL,
    img_producto VARCHAR(200) NOT NULL,
    categoria_producto INT NOT NULL,
    descuentos INT NOT NULL DEFAULT 1,
    stock INT NOT NULL DEFAULT 0,
    FOREIGN KEY (categoria_producto) REFERENCES categorias(id_categoria)
);

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre_cliente VARCHAR(50) NOT NULL,
    apellido_cliente VARCHAR(50) NOT NULL
);

CREATE TABLE carrito (
	id_carrito INT PRIMARY KEY NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE carrito_items (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_carrito) REFERENCES carrito(id_carrito),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE descuentos (
id_descuento INT AUTO_INCREMENT PRIMARY KEY,
descuento_nombre VARCHAR(150) NOT NULL
);

INSERT INTO descuentos(descuento_nombre)
VALUES (""), ("2do al 80%"), ("30%"), ("15%"), ("2x1");

INSERT INTO categorias(nombre_categoria)
VALUES  ("Almacén"), ("Bebidas"), ("Limpieza"), ("Kiosco");

INSERT INTO productos(nombre_producto, marca_producto, precio_producto, img_producto, categoria_producto, descuentos, stock)
VALUES 
("Fideos Spaghetti N7 Lucchetti 500 Gr.",  "Lucchetti", 1365, "url img", 1, 1, 0),
("Fideos Tirabuzon N28 Matarazzo 500 Gr.",  "Matarazzo", 1575, "url img", 1, 1, 17),
("Harina Leudante Pureza 1 Kg.",  "Pureza",  1280, "url img", 1, 2, 54),
("Gaseosa Coca-Cola Sabor Original 2.25 Lt.",  "Coca-Cola", 4100, "url img", 2, 5, 34),
("Coca Cola Zero 1,25 Lt.",  "Coca-Cola", 2280, "url img", 2, 1, 47),
("Gaseosa Sprite Lima-Limón 2,25 Lt.",  "Sprite", 4100, "url img", 2, 5, 7),
("Lavandina Ayudín Original 1 Lt.",  "Ayudín", 860, "url img", 3, 3, 2),
("Limpiador Desinfectante Ayudín Lavanda 900 Ml.",  "Ayudín", 1510, "url img", 3, 1, 0),
("Limpiador Poett Líquido Fragancia Primavera 900 Ml.",  "Poett", 1500, "url img", 3, 1, 3),
("Chocolate con Maní Cofler Block 38 Gr.",  "Cofler", 345, "url img", 4, 3, 10),
("Chicle Bubbaloo Menta 5 Gr.",  "Bubbaloo", 80, "url img", 4, 4, 2),
("Alfajor Tita 36 Gr.",  "Tita", 745, "url img", 4, 4, 6)
;


INSERT INTO clientes (nombre_cliente, apellido_cliente)
VALUES ("Luciana", "Rodriguez"), ("Pedro", "Rojas"), ("Alberto", "Garay"), ("Florencia", "Perez");

INSERT INTO carrito(id_carrito, id_cliente)
VALUES (1, 3), (2, 2), (3, 1);

INSERT INTO carrito_items(id_carrito, id_producto, cantidad)
VALUES (1, 2, 4), (2, 3, 1), (2, 6, 4), (2, 4, 2), (3, 12, 2), (3, 10, 5), (3, 5, 4), (3, 1, 3);


CREATE VIEW view_productos AS
SELECT
	p.nombre_producto,
    p.marca_producto,
    p.precio_producto,
    p.img_producto,
    p.stock,
    c.nombre_categoria,
    d.descuento_nombre
FROM productos p
JOIN categorias c ON p.categoria_producto = c.id_categoria
JOIN descuentos d ON d.id_descuento = p.descuentos;

CREATE VIEW view_productos_descuentos AS
SELECT
	p.nombre_producto,
    p.marca_producto,
    p.precio_producto,
    p.img_producto,
    p.stock,
    c.nombre_categoria,
    d.descuento_nombre
FROM productos p 
JOIN categorias c ON p.categoria_producto = c.id_categoria
JOIN descuentos d ON d.id_descuento = p.descuentos
WHERE p.stock > 0 
AND d.descuento_nombre <> "";


DELIMITER //

CREATE PROCEDURE AgregarProducto (
    IN p_nombre_producto VARCHAR(150),
    IN p_marca_producto VARCHAR(50),
    IN p_precio_producto decimal(10,2),
    IN p_img_producto VARCHAR(200),
    IN p_categoria_producto INT,
    IN p_descuentos INT,
    IN p_stock INT
)
BEGIN
	INSERT INTO productos (
		nombre_producto, marca_producto, precio_producto, img_producto, categoria_producto, descuentos, stock
    )
    VALUES (
		p_nombre_producto, p_marca_producto, p_precio_producto, p_img_producto, p_categoria_producto, p_descuentos, p_stock
    );        
END //

DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarStock (
	IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
	DECLARE stock_actual INT;
    DECLARE nuevo_stock INT;
    
    SELECT stock INTO stock_actual FROM productos WHERE id_producto = p_id_producto;
    
    SET nuevo_stock = stock_actual + p_cantidad;
    
	UPDATE productos SET stock = nuevo_stock  WHERE id_producto = p_id_producto;
END //

DELIMITER ;

DELIMITER //
CREATE FUNCTION calcular_total_carrito(
    p_id_carrito INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    
    SELECT SUM(p.precio_producto * ci.cantidad) INTO total
    FROM carrito_items ci
    JOIN productos p ON ci.id_producto = p.id_producto
    WHERE ci.id_carrito = p_id_carrito;
    
    RETURN IFNULL(total, 0);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER actualizar_stock_after_insert
AFTER INSERT ON carrito_items
FOR EACH ROW
BEGIN
    UPDATE productos 
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END //
DELIMITER ;