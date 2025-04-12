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
    FOREIGN KEY (categoria_producto) REFERENCES categorias(id_categoria)
);

CREATE TABLE stock (
	id_producto INT,
    stock_producto INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
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


INSERT INTO categorias(nombre_categoria)
VALUES  ("Almacén"), ("Bebidas"), ("Limpieza"), ("Kiosco");

INSERT INTO productos(nombre_producto, marca_producto, precio_producto, img_producto, categoria_producto)
VALUES 
("Fideos Spaghetti N7 Lucchetti 500 Gr.",  "Lucchetti", 1365, "url img", 1),
("Fideos Tirabuzon N28 Matarazzo 500 Gr.",  "Matarazzo", 1575, "url img", 1),
("Harina Leudante Pureza 1 Kg.",  "Pureza",  1280, "url img", 1),
("Gaseosa Coca-Cola Sabor Original 2.25 Lt.",  "Coca-Cola", 4100, "url img", 2),
("Coca Cola Zero 1,25 Lt.",  "Coca-Cola", 2280, "url img", 2),
("Gaseosa Sprite Lima-Limón 2,25 Lt.",  "Sprite", 4100, "url img", 2),
("Lavandina Ayudín Original 1 Lt.",  "Ayudín", 860, "url img", 3),
("Limpiador Desinfectante Ayudín Lavanda 900 Ml.",  "Ayudín", 1510, "url img", 3),
("Limpiador Poett Líquido Fragancia Primavera 900 Ml.",  "Poett", 1500, "url img", 3),
("Chocolate con Maní Cofler Block 38 Gr.",  "Cofler", 345, "url img", 4),
("Chicle Bubbaloo Menta 5 Gr.",  "Bubbaloo", 80, "url img", 4),
("Alfajor Tita 36 Gr.",  "Tita", 745, "url img", 4)
;

INSERT INTO stock(id_producto, stock_producto)
VALUES (1, 33), (2, 45),(9, 12);

INSERT INTO clientes (nombre_cliente, apellido_cliente)
VALUES ("Luciana", "Rodriguez"), ("Pedro", "Rojas"), ("Alberto", "Garay");

INSERT INTO carrito(id_carrito, id_cliente)
VALUES (1, 3), (2, 2);
INSERT INTO carrito(id_carrito, id_cliente)
VALUES (3, 1);

INSERT INTO carrito_items(id_carrito, id_producto, cantidad)
VALUES (1, 2, 4), (2, 3, 1);
INSERT INTO carrito_items(id_carrito, id_producto, cantidad)
VALUES (2, 6, 4), (2, 4, 2);
INSERT INTO carrito_items(id_carrito, id_producto, cantidad)
VALUES (3, 12, 2), (3, 10, 5), (3, 5, 4), (3, 1, 3);


SELECT c.id_cliente, c.nombre_cliente, c.apellido_cliente, ca.id_carrito, i.id_producto, p.nombre_producto, i.cantidad
	FROM clientes c
    INNER JOIN carrito ca ON ca.id_cliente = c.id_cliente
    INNER JOIN carrito_items i ON i.id_carrito = ca.id_carrito
    INNER JOIN productos p ON p.id_producto = i.id_producto
	WHERE ca.id_carrito = 3;