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
    categoria_producto INT,
    descuentos INT DEFAULT 1,
    stock INT NOT NULL DEFAULT 0,
    producto_disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_producto) REFERENCES categorias(id_categoria)
);

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre_cliente VARCHAR(50) NOT NULL,
    apellido_cliente VARCHAR(50) NOT NULL,
    dni_cliente INT UNIQUE NOT NULL,
    email_cliente VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE carrito (
	id_carrito INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE carrito_items (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    subtotal DECIMAL(12, 2) NOT NULL,
	descuento DECIMAL(12, 2) DEFAULT 0.00,
	total DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (id_carrito) REFERENCES carrito(id_carrito),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE descuentos (
id_descuento INT AUTO_INCREMENT PRIMARY KEY,
descuento_nombre VARCHAR(150) NOT NULL
);

CREATE TABLE ordenes_compra(
id_orden INT PRIMARY KEY AUTO_INCREMENT,
id_carrito INT NOT NULL,
id_cliente INT NOT NULL,
fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
estado ENUM('pendiente', 'entregada', 'cancelado') DEFAULT 'pendiente',
subtotal DECIMAL(12, 2) NOT NULL,
descuento DECIMAL(12, 2) DEFAULT 0.00,
total DECIMAL(12, 2) NOT NULL,
direccion_envio TEXT NOT NULL,
metodo_pago ENUM('tarjeta', 'app', 'efectivo') NOT NULL,
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE orden_detalle(
id_detalle INT PRIMARY KEY AUTO_INCREMENT,
id_orden INT NOT NULL,
id_cliente INT NOT NULL,
id_producto INT NOT NULL,
cantidad INT NOT NULL,
FOREIGN KEY (id_orden) REFERENCES ordenes_compra(id_orden)
);

CREATE TABLE auditoria_productos (
	id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
	id_producto INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    fecha_modificado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operacion ENUM('INSERT', 'UPDATE', 'DELETE', 'RECOVER') NOT NULL,
    observaciones TEXT,
    datos_anteriores JSON,
    datos_nuevos JSON,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE productos_eliminados (
	id_eliminacion INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    nombre_producto VARCHAR(150) NOT NULL,
    marca_producto VARCHAR(50) NOT NULL,
    precio_producto DECIMAL(10, 2) NOT NULL,
    img_producto VARCHAR(200) NOT NULL,
    categoria_producto INT NOT NULL,
    descuentos INT NOT NULL DEFAULT 1,
    stock INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


CREATE VIEW view_productos_disponibles AS
SELECT
	p.id_producto,
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
WHERE p.producto_disponible = 1;


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
CREATE PROCEDURE ModificarNombreProducto (
	IN p_id_producto INT,
    IN p_nuevo_valor VARCHAR(150)
)
proc: BEGIN
	DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
	UPDATE productos
	SET nombre_producto = p_nuevo_valor
	WHERE id_producto = p_id_producto;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarMarcaProducto (
	IN p_id_producto INT,
    IN p_nuevo_valor VARCHAR(50)
)
proc: BEGIN
	DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
	UPDATE productos
	SET marca_producto = p_nuevo_valor
	WHERE id_producto = p_id_producto;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarImgProducto (
	IN p_id_producto INT,
    IN p_nuevo_valor VARCHAR(200)
)
proc: BEGIN
	DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
	UPDATE productos
	SET img_producto = p_nuevo_valor
	WHERE id_producto = p_id_producto;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarPrecioProducto (
	IN p_id_producto INT,
    IN p_nuevo_valor decimal(10,2)
)
proc: BEGIN
	DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
	UPDATE productos
	SET precio_producto = p_nuevo_valor
	WHERE id_producto = p_id_producto;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarCategoriaProducto (
	IN p_id_producto INT,
    IN p_nuevo_valor int
)
proc:BEGIN
	DECLARE max_valor INT;
	DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
	SELECT COUNT(*) INTO max_valor FROM categorias;
    IF 0 < p_nuevo_valor < max_valor THEN
		UPDATE productos
		SET categoria_producto = p_nuevo_valor
		WHERE id_producto = p_id_producto;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarDescuentoProducto (
	IN p_id_producto INT,
    IN p_nuevo_valor int
)
proc: BEGIN
	DECLARE max_valor INT;
	DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
	SELECT COUNT(*) INTO max_valor FROM descuentos;
    IF 0 < p_nuevo_valor < max_valor THEN
		UPDATE productos
		SET descuentos = p_nuevo_valor
		WHERE id_producto = p_id_producto;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ModificarStock (
	IN p_id_producto INT,
    IN p_cantidad INT
)
proc: BEGIN
	DECLARE stock_actual INT;
    DECLARE nuevo_stock INT;
    DECLARE v_producto_disponible INT DEFAULT 0;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
    SELECT stock INTO stock_actual FROM productos WHERE id_producto = p_id_producto;
    
    SET nuevo_stock = stock_actual + p_cantidad;
    
	UPDATE productos SET stock = nuevo_stock  WHERE id_producto = p_id_producto;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE EliminarProducto(
	IN p_id_producto INT
)
BEGIN 
	DECLARE v_existe_producto INT;
    
    SELECT COUNT(*) INTO v_existe_producto FROM productos WHERE id_producto = p_id_producto;
	
    IF v_existe_producto = 0 THEN
        SELECT 'El producto no existe.' AS message;
    ELSE
        
		INSERT INTO productos_eliminados(
			id_producto,
			nombre_producto,
			marca_producto,
			precio_producto,
			img_producto,
			categoria_producto,
			descuentos,
			stock
        )
        SELECT 
			p.id_producto,
			p.nombre_producto,
			p.marca_producto,
			p.precio_producto,
			p.img_producto,
			p.categoria_producto,
			p.descuentos,
			p.stock
		FROM
			productos p
		WHERE
			p.id_producto = p_id_producto;
        
		UPDATE 
			productos 
		SET 
			nombre_producto = "Producto eliminado",
            marca_producto = "",
            precio_producto = 0,
            img_producto = "",
            categoria_producto = null,
            descuentos = null,
            stock = 0
        WHERE 
			id_producto = p_id_producto;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE RecuperarProductoEliminado(
	IN p_id_producto INT
)
BEGIN 
	DECLARE v_existe_producto INT;
    DECLARE v_existe_en_productos INT;
    
    SELECT COUNT(*) INTO v_existe_producto FROM productos_eliminados WHERE id_producto = p_id_producto;
	SELECT COUNT(*) INTO v_existe_en_productos;
    
    IF v_existe_producto = 0 THEN
        SELECT 'El producto no existe en la tabla de eliminados' AS message;
    ELSEIF v_existe_en_productos = 0 THEN
        SELECT 'Error: No existe un producto con ese ID para recuperar' AS message;
    ELSE
		UPDATE 
			productos p
		JOIN productos_eliminados pe ON p.id_producto = pe.id_producto
		SET 
			p.nombre_producto = pe.nombre_producto,
			p.marca_producto = pe.marca_producto,
			p.precio_producto = pe.precio_producto,
			p.img_producto = pe.img_producto,
			p.categoria_producto = pe.categoria_producto,
			p.descuentos = pe.descuentos,
			p.stock = pe.stock
		WHERE
			pe.id_producto = p_id_producto;
            
		DELETE FROM productos_eliminados WHERE id_producto = p_id_producto;
        
        INSERT INTO auditoria_productos (
            id_producto,
            operacion,
            observaciones,
            datos_anteriores,
            datos_nuevos
        ) VALUES (
            p_id_producto,
            'RECOVER',
            'Producto recuperado de eliminados',
            NULL,
            (SELECT JSON_OBJECT(
                'nombre_producto', nombre_producto,
                'marca_producto', marca_producto,
                'precio_producto', precio_producto,
                'stock', stock
            ) FROM productos WHERE id_producto = p_id_producto)
        );
	END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE RegistrarCliente(
	IN p_nombre_cliente VARCHAR(50),
    IN p_apellido_cliente VARCHAR(50),
    IN p_dni_cliente INT,
    IN p_email_cliente VARCHAR(100)
)
BEGIN
	INSERT INTO clientes(
		nombre_cliente,
		apellido_cliente,
		dni_cliente,
        email_cliente
	) VALUES (
		p_nombre_cliente,
        p_apellido_cliente,
        p_dni_cliente,
        p_email_cliente
    );
END //
DELIMITER ;

    
DELIMITER //
CREATE PROCEDURE AgregarProductoAlCarrito (
    IN p_id_carrito INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
proc: BEGIN
	DECLARE v_existe_carrito INT DEFAULT 0;
	DECLARE v_existe_producto INT DEFAULT 0;
    DECLARE v_producto_disponible INT DEFAULT 0;
    DECLARE v_cantidad_actual INT;
    DECLARE v_nueva_cantidad INT;
    DECLARE v_stock_disponible INT;
    
    SELECT stock INTO v_stock_disponible FROM productos WHERE id_producto = p_id_producto;
    
    SELECT COUNT(*) INTO v_existe_carrito FROM carrito WHERE id_carrito = p_id_carrito;
    IF v_existe_carrito = 0 THEN
        SELECT 'El carrito ingresado no existe.' AS message;
        LEAVE proc;
    END IF;
    
    SELECT producto_disponible INTO v_producto_disponible FROM productos WHERE id_producto = p_id_producto;
    IF v_producto_disponible = FALSE THEN
		SELECT 'El producto no esta disponible.' AS message;
        LEAVE proc;
    END IF;
    
    IF p_cantidad <= 0 THEN
        SELECT 'Debes ingresar una cantidad valida.' AS message;
        LEAVE proc;
    END IF;
    
    IF p_cantidad > v_stock_disponible THEN
        SELECT 'La cantidad ingresada supera al stock disponible.' AS message;
        LEAVE proc;
    END IF;
    
    SELECT COUNT(*) INTO v_existe_producto FROM carrito_items WHERE id_carrito = p_id_carrito AND id_producto = p_id_producto;
	IF v_existe_producto = 0 THEN
			INSERT INTO carrito_items(id_carrito, id_producto, cantidad, subtotal, descuento, total)
			VALUES (
            p_id_carrito, 
            p_id_producto, 
            p_cantidad, 
            calcular_subtotal(p_id_producto, p_cantidad),
            calcular_descuento(p_id_producto, p_cantidad),
            calcular_subtotal(p_id_producto, p_cantidad) - calcular_descuento(p_id_producto, p_cantidad)
            );
		ELSE 
			SELECT cantidad INTO v_cantidad_actual FROM carrito_items WHERE id_producto = p_id_producto;
            
			SET v_nueva_cantidad = v_cantidad_actual + p_cantidad;
			UPDATE carrito_items 
            SET cantidad = v_nueva_cantidad, 
				subtotal = calcular_subtotal(p_id_producto, v_nueva_cantidad),
                descuento = calcular_descuento(p_id_producto, v_nueva_cantidad),
                total = subtotal - descuento
            WHERE id_carrito = p_id_carrito AND id_producto = p_id_producto;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE VerCarrito (
	IN p_id_carrito INT
)
BEGIN
	SELECT p.nombre_producto, i.cantidad, p.precio_producto, calcular_total_carrito(p_id_carrito)
	FROM clientes c
    INNER JOIN carrito ca ON ca.id_cliente = c.id_cliente
    INNER JOIN carrito_items i ON i.id_carrito = ca.id_carrito
    INNER JOIN productos p ON p.id_producto = i.id_producto
	WHERE ca.id_carrito = p_id_carrito;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CrearOrdenDeCompra (
	IN p_id_carrito INT,
    IN p_direccion_envio VARCHAR(100),
    IN p_metodo_pago VARCHAR(20)
)
BEGIN
    DECLARE v_id_cliente INT;
	DECLARE v_id_orden INT;
    DECLARE v_subtotal DECIMAL (12, 2);
    DECLARE v_descuentos DECIMAL (12, 2);
    DECLARE v_total DECIMAL (12, 2);
    
    SELECT id_cliente INTO v_id_cliente FROM carrito WHERE p_id_carrito = id_carrito;
    SET v_subtotal = calcular_subtotal_carrito(p_id_carrito);
    SET v_descuentos = calcular_total_descuento_carrito(p_id_carrito);
	SET v_total = calcular_total_final_carrito(p_id_carrito);
    
	INSERT INTO ordenes_compra (
		id_carrito,
        id_cliente, 
        metodo_pago, 
        subtotal, 
        descuento, 
        total, 
        direccion_envio
	) 
    VALUES (
		p_id_carrito,
        v_id_cliente,
        p_metodo_pago,
        v_subtotal,
		v_descuentos,
        v_total,
        p_direccion_envio
	);


	SET v_id_orden = LAST_INSERT_ID();
    
	INSERT INTO orden_detalle (id_orden, id_cliente, id_producto, cantidad)
	SELECT 
		v_id_orden, 
        ca.id_cliente,
		ci.id_producto, 
		ci.cantidad 
	FROM 
		carrito_items ci 
    JOIN productos p ON ci.id_producto = p.id_producto 
    JOIN carrito ca ON p_id_carrito = ca.id_carrito
	WHERE ci.id_carrito = p_id_carrito;
    
    DELETE FROM carrito_items WHERE id_carrito = p_id_carrito;
	DELETE FROM carrito WHERE id_carrito = p_id_carrito;
    INSERT INTO carrito (id_cliente) VALUES (v_id_cliente);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE VerOrdenCompra (
	IN p_id_orden INT
)
BEGIN
	SELECT
		oc.id_producto,
		oc.cantidad,
		p.nombre_producto,
		p.precio_producto
	FROM orden_detalle oc
	JOIN productos p ON p.id_producto = oc.id_producto
    WHERE oc.id_orden = p_id_orden;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE VerProductosPorCategoria (
	IN p_id_categoria INT
)
BEGIN
DECLARE max_valor INT;

	SELECT COUNT(*) INTO max_valor FROM categorias;
    
    IF 0 < p_id_categoria  < max_valor THEN
		SELECT p.id_producto, p.nombre_producto, p.marca_producto, p.precio_producto, p.img_producto, p.stock, c.nombre_categoria, d.descuento_nombre
		FROM productos p
		INNER JOIN categorias c ON p.categoria_producto = c.id_categoria
		INNER JOIN descuentos d	ON p.descuentos = d.id_descuento
		WHERE p.categoria_producto = p_id_categoria;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE VerProductosPorDescuento (
	IN p_id_descuento INT
)
BEGIN
	DECLARE max_valor INT;

	SELECT COUNT(*) INTO max_valor FROM descuentos;
    
    IF 0 < p_id_descuento < max_valor THEN
		SELECT p.id_producto, p.nombre_producto, p.marca_producto, p.precio_producto, p.img_producto, p.stock, c.nombre_categoria, d.descuento_nombre
		FROM productos p
		INNER JOIN categorias c ON p.categoria_producto = c.id_categoria
		INNER JOIN descuentos d	ON p.descuentos = d.id_descuento
		
		WHERE d.id_descuento = p_id_descuento;
	END IF;
END //
DELIMITER ;
DROP PROCEDURE VerProductosPorDescuento;



DELIMITER //
CREATE FUNCTION calcular_subtotal(
    p_id_producto INT,
    p_cantidad INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    
    SELECT SUM(p.precio_producto * p_cantidad) INTO v_subtotal
    FROM productos p
    WHERE p.id_producto = p_id_producto;
    
    RETURN IFNULL(v_subtotal, 0);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION calcular_descuento(
    p_id_producto INT,
    p_cantidad INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_descuento INT;
    DECLARE v_pares INT;
    DECLARE v_precio_producto DECIMAL(10,2);
    
    SELECT descuentos INTO v_descuento FROM productos WHERE id_producto = p_id_producto;
    SELECT precio_producto INTO v_precio_producto FROM productos WHERE id_producto = p_id_producto;
    
    IF v_descuento = 2 THEN
		IF p_cantidad >= 2 THEN
			SET v_pares = FLOOR(p_cantidad / 2);
			SET v_total = (v_pares * (v_precio_producto * .8));
		ELSE
			SET v_total = 0;
		END IF;
	END IF;
    
    IF v_descuento = 3 THEN
		SELECT SUM(p.precio_producto * p_cantidad * 0.3) INTO v_total
		FROM productos p 
		WHERE p.id_producto = p_id_producto;
	END IF;
    
    IF v_descuento = 4 THEN
		SELECT SUM(p.precio_producto * p_cantidad * 0.15) INTO v_total
		FROM productos p 
		WHERE p.id_producto = p_id_producto;
	END IF;
    
    IF v_descuento = 5 THEN
		IF p_cantidad >= 2 THEN
			SET v_pares = FLOOR(p_cantidad / 2);
			SET v_total = (v_pares * v_precio_producto);
		ELSE
			SET v_total = 0;
		END IF;
	END IF;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION calcular_subtotal_carrito(
    p_id_carrito INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    
    SELECT SUM(subtotal) INTO v_subtotal
    FROM carrito_items
    WHERE id_carrito = p_id_carrito;
    
    RETURN IFNULL(v_subtotal, 0);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION calcular_total_descuento_carrito(
    p_id_carrito INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total_descuento DECIMAL(10,2) DEFAULT 0;
    
    SELECT SUM(descuento) INTO v_total_descuento
    FROM carrito_items
    WHERE id_carrito = p_id_carrito;
    
    RETURN IFNULL(v_total_descuento, 0);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION calcular_total_final_carrito(
    p_id_carrito INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total_final_carrito DECIMAL(10,2) DEFAULT 0;
    
	SET v_total_final_carrito = calcular_subtotal_carrito(p_id_carrito) - calcular_total_descuento_carrito(p_id_carrito);
    
    RETURN IFNULL(v_total_final_carrito, 0);
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER after_registrar_clientes
AFTER INSERT ON clientes 
FOR EACH ROW
BEGIN
		INSERT INTO carrito (id_cliente) VALUES (NEW.id_cliente);
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

DELIMITER //
CREATE TRIGGER after_insertar_producto
AFTER INSERT ON productos 
FOR EACH ROW
BEGIN
	INSERT INTO auditoria_productos (
		id_producto,
        cantidad,
        operacion,
        observaciones
    ) VALUES (
		NEW.id_producto,
        NEW.stock,
        'INSERT',
        'Producto agregado al stock'
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_modificar_producto
AFTER UPDATE ON productos 
FOR EACH ROW
BEGIN
	IF OLD.nombre_producto != NEW.nombre_producto AND NEW.nombre_producto != "Producto eliminado" OR 
		OLD.marca_producto != NEW.marca_producto AND NEW.marca_producto != "" OR 
		OLD.precio_producto != NEW.precio_producto AND NEW.precio_producto != 0 OR 
        OLD.img_producto != NEW.img_producto AND NEW.img_producto != "" OR
		OLD.categoria_producto != NEW.categoria_producto AND NEW.marca_producto != null OR
		OLD.descuentos != NEW.descuentos AND NEW.descuentos != null THEN
    
		INSERT INTO auditoria_productos (
			id_producto,
			operacion,
			observaciones,
            datos_anteriores,
            datos_nuevos
		) VALUES (
			NEW.id_producto,
			'UPDATE',
			'Producto modificado',
            JSON_OBJECT('nombre_producto', OLD.nombre_producto,
						'marca_producto', OLD.marca_producto,
						'precio_producto', OLD.precio_producto,
						'img_producto', OLD.img_producto,
						'categoria_producto', OLD.categoria_producto,
                        'descuentos', OLD.descuentos
						),
			JSON_OBJECT('nombre_producto', NEW.nombre_producto,
						'marca_producto', NEW.marca_producto,
						'precio_producto', NEW.precio_producto,
						'img_producto', NEW.img_producto,
						'categoria_producto', NEW.categoria_producto,
                        'descuentos', NEW.descuentos
						)
			);
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_modificar_stock
AFTER UPDATE ON productos 
FOR EACH ROW
BEGIN
	IF OLD.stock != NEW.stock 
    AND	NEW.nombre_producto != "Producto eliminado"
    THEN
    
		INSERT INTO auditoria_productos (
			id_producto,
            cantidad,
			operacion,
			observaciones,
            datos_anteriores,
            datos_nuevos
		) VALUES (
			NEW.id_producto,
            NEW.stock,
			'UPDATE',
			'Stock modificado',
            JSON_OBJECT('stock', OLD.stock),
			JSON_OBJECT('stock', NEW.stock)
			);
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER actualizar_disponibilidad
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock <= 0 THEN
        SET NEW.producto_disponible = FALSE;
    ELSE
        SET NEW.producto_disponible = TRUE;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_eliminar_producto
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF (OLD.nombre_producto != '' AND NEW.nombre_producto = 'Producto eliminado') OR 
       (OLD.marca_producto != '' AND NEW.marca_producto = '') THEN
	
		INSERT INTO auditoria_productos (
			id_producto,
			operacion,
			observaciones,
			datos_anteriores,
			datos_nuevos
		) VALUES (
			OLD.id_producto,
			'DELETE',
			'Producto eliminado',
			JSON_OBJECT(
				'nombre_producto', OLD.nombre_producto,
				'marca_producto', OLD.marca_producto,
				'precio_producto', OLD.precio_producto,
				'img_producto', OLD.img_producto,
				'categoria_producto', OLD.categoria_producto,
				'descuentos', OLD.descuentos,
				'stock', OLD.stock
			),
			NULL
		);
    END IF;
END //
DELIMITER ;


