

CREATE DATABASE ejercicio_practico_4
USE ejercicio_practico_4
DROP DATABASE ejercicio_practico_4


CREATE USER 'rapid_mart'@'localhost' IDENTIFIED BY 'Rapid_mart_2024';
GRANT ALL PRIVILEGES ON *.* TO 'rapid_mart'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;


CREATE TABLE categorias (
    id_categoria CHAR(36) NOT NULL DEFAULT (UUID()),
    nombre_categoria VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE proveedores (
    id_proveedor CHAR(36) NOT NULL DEFAULT (UUID()),
    nombre_proveedor VARCHAR(50) NOT NULL,
    direccion_proveedor VARCHAR(50),
    telefono_proveedor VARCHAR(10),
    PRIMARY KEY (id_proveedor)
);

CREATE TABLE productos (
    id_producto CHAR(36) NOT NULL DEFAULT (UUID()),
    nombre_producto VARCHAR(50) NOT NULL,
    descripcion_producto VARCHAR(255),
    precio_unitario DECIMAL(10,2) NOT NULL,
    id_categoria CHAR(36) NOT NULL,
    id_proveedor CHAR(36) NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE inventarios (
    id_inventario CHAR(36) NOT NULL DEFAULT (UUID()),
    id_producto CHAR(36) NOT NULL,
    cantidad_disponible INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    PRIMARY KEY (id_inventario),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE movimientos_inventarios (
    id_movimiento_inventario CHAR(36) NOT NULL DEFAULT (UUID()),
    id_inventario CHAR(36) NOT NULL,
    tipo_movimiento ENUM('Entrada', 'Salida') NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    PRIMARY KEY (id_movimiento_inventario),
    FOREIGN KEY (id_inventario) REFERENCES inventarios(id_inventario)
);




INSERT INTO categorias (nombre_categoria) VALUES
('Electrónica'),
('Ropa'),
('Alimentos'),
('Juguetes'),
('Libros'),
('Herramientas'),
('Jardinería'),
('Deportes'),
('Muebles'),
('Cosméticos');

INSERT INTO proveedores (nombre_proveedor, direccion_proveedor, telefono_proveedor) VALUES
('Proveedor A', 'Dirección A', '1234567890'),
('Proveedor B', 'Dirección B', '2345678901'),
('Proveedor C', 'Dirección C', '3456789012'),
('Proveedor D', 'Dirección D', '4567890123'),
('Proveedor E', 'Dirección E', '5678901234'),
('Proveedor F', 'Dirección F', '6789012345'),
('Proveedor G', 'Dirección G', '7890123456'),
('Proveedor H', 'Dirección H', '8901234567'),
('Proveedor I', 'Dirección I', '9012345678'),
('Proveedor J', 'Dirección J', '0123456789');



INSERT INTO productos (nombre_producto, descripcion_producto, precio_unitario, id_categoria, id_proveedor) 
VALUES
('Producto 1', 'Descripción del Producto 1', 100.00, (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'Categoría Específica'), (SELECT id_proveedor FROM proveedores WHERE nombre_proveedor = 'Proveedor Específico')),
('Producto 2', 'Descripción del Producto 2', 150.00, (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'Otra Categoría'), (SELECT id_proveedor FROM proveedores WHERE nombre_proveedor = 'Otro Proveedor')),

;



DELIMITER $$
 
CREATE TRIGGER ajustar_inventario
AFTER INSERT ON movimientos_inventarios
FOR EACH ROW
BEGIN
    IF NEW.tipo_movimiento = 'Entrada' THEN
        UPDATE inventarios
        SET cantidad_disponible = cantidad_disponible + NEW.cantidad
        WHERE id_inventario = NEW.id_inventario;
    ELSEIF NEW.tipo_movimiento = 'Salida' THEN
        UPDATE inventarios
        SET cantidad_disponible = cantidad_disponible - NEW.cantidad
        WHERE id_inventario = NEW.id_inventario;
    END IF;
END$$
 
DELIMITER ;


DELIMITER $$
 
CREATE PROCEDURE insertar_categoria(IN nombre_categoria VARCHAR(50))
BEGIN
    INSERT INTO categorias (nombre_categoria) VALUES (nombre_categoria);
END$$
 
DELIMITER ;

DELIMITER $$
 
CREATE PROCEDURE insertar_proveedor(IN nombre_proveedor VARCHAR(50), IN direccion_proveedor VARCHAR(50), IN telefono_proveedor VARCHAR(10))
BEGIN
    INSERT INTO proveedores (nombre_proveedor, direccion_proveedor, telefono_proveedor) VALUES (nombre_proveedor, direccion_proveedor, telefono_proveedor);
END$$
 
DELIMITER ;

DELIMITER $$
 
CREATE PROCEDURE insertar_producto(IN nombre_producto VARCHAR(50), IN descripcion_producto VARCHAR(255), IN precio_unitario DECIMAL(10,2), IN nombre_categoria VARCHAR(50), IN nombre_proveedor VARCHAR(50))
BEGIN
    DECLARE cat_id CHAR(36);
    DECLARE prov_id CHAR(36);
 
    SELECT id_categoria INTO cat_id FROM categorias WHERE nombre_categoria = nombre_categoria LIMIT 1;
    SELECT id_proveedor INTO prov_id FROM proveedores WHERE nombre_proveedor = nombre_proveedor LIMIT 1;
 
    INSERT INTO productos (nombre_producto, descripcion_producto, precio_unitario, id_categoria, id_proveedor) 
    VALUES (nombre_producto, descripcion_producto, precio_unitario, cat_id, prov_id);
END$$
 
DELIMITER ;

DELIMITER $$
 
CREATE PROCEDURE insertar_inventario(IN nombre_producto VARCHAR(50), IN cantidad_disponible INT, IN fecha_ingreso DATE)
BEGIN
    DECLARE prod_id CHAR(36);
 
    SELECT id_producto INTO prod_id FROM productos WHERE nombre_producto = nombre_producto LIMIT 1;
 
    INSERT INTO inventarios (id_producto, cantidad_disponible, fecha_ingreso) 
    VALUES (prod_id, cantidad_disponible, fecha_ingreso);
END$$
 
DELIMITER ;

DELIMITER $$
 
CREATE PROCEDURE insertar_movimiento_inventario(IN nombre_producto VARCHAR(50), IN tipo_movimiento ENUM('Entrada', 'Salida'), IN cantidad INT, IN fecha_movimiento DATE)
BEGIN
    DECLARE inv_id CHAR(36);
 
    SELECT id_inventario INTO inv_id FROM inventarios 
    JOIN productos ON inventarios.id_producto = productos.id_producto
    WHERE productos.nombre_producto = nombre_producto LIMIT 1;
 
    INSERT INTO movimientos_inventarios (id_inventario, tipo_movimiento, cantidad, fecha_movimiento) 
    VALUES (inv_id, tipo_movimiento, cantidad, fecha_movimiento);
END$$
 
DELIMITER ;

CALL insertar_categoria('Electrónica');


CALL insertar_categoria('Electrónica');
CALL insertar_categoria('Ropa');
CALL insertar_categoria('Alimentos');
CALL insertar_categoria('Juguetes');
CALL insertar_categoria('Libros');
CALL insertar_categoria('Herramientas');
CALL insertar_categoria('Jardinería');
CALL insertar_categoria('Deportes');
CALL insertar_categoria('Muebles');
CALL insertar_categoria('Cosméticos');

CALL insertar_proveedor('Proveedor A', 'Dirección A', '1234567890');
CALL insertar_proveedor('Proveedor B', 'Dirección B', '2345678901');
CALL insertar_proveedor('Proveedor C', 'Dirección C', '3456789012');
CALL insertar_proveedor('Proveedor D', 'Dirección D', '4567890123');
CALL insertar_proveedor('Proveedor E', 'Dirección E', '5678901234');
CALL insertar_proveedor('Proveedor F', 'Dirección F', '6789012345');
CALL insertar_proveedor('Proveedor G', 'Dirección G', '7890123456');
CALL insertar_proveedor('Proveedor H', 'Dirección H', '8901234567');
CALL insertar_proveedor('Proveedor I', 'Dirección I', '9012345678');
CALL insertar_proveedor('Proveedor J', 'Dirección J', '0123456789');


CALL insertar_producto('Producto 1', 'Descripción del Producto 1', 100.00, 'Electrónica', 'Proveedor A');
CALL insertar_producto('Producto 2', 'Descripción del Producto 2', 150.00, 'Ropa', 'Proveedor B');
CALL insertar_producto('Producto 3', 'Descripción del Producto 3', 200.00, 'Alimentos', 'Proveedor C');
CALL insertar_producto('Producto 4', 'Descripción del Producto 4', 250.00, 'Juguetes', 'Proveedor D');
CALL insertar_producto('Producto 5', 'Descripción del Producto 5', 300.00, 'Libros', 'Proveedor E');
CALL insertar_producto('Producto 6', 'Descripción del Producto 6', 350.00, 'Herramientas', 'Proveedor F');
CALL insertar_producto('Producto 7', 'Descripción del Producto 7', 400.00, 'Jardinería', 'Proveedor G');
CALL insertar_producto('Producto 8', 'Descripción del Producto 8', 450.00, 'Deportes', 'Proveedor H');
CALL insertar_producto('Producto 9', 'Descripción del Producto 9', 500.00, 'Muebles', 'Proveedor I');
CALL insertar_producto('Producto 10', 'Descripción del Producto 10', 550.00, 'Cosméticos', 'Proveedor J');

CALL insertar_proveedor('Proveedor A', 'Dirección A', '1234567890');
CALL insertar_proveedor('Proveedor B', 'Dirección B', '2345678901');
CALL insertar_proveedor('Proveedor C', 'Dirección C', '3456789012');
CALL insertar_proveedor('Proveedor D', 'Dirección D', '4567890123');
CALL insertar_proveedor('Proveedor E', 'Dirección E', '5678901234');
CALL insertar_proveedor('Proveedor F', 'Dirección F', '6789012345');
CALL insertar_proveedor('Proveedor G', 'Dirección G', '7890123456');
CALL insertar_proveedor('Proveedor H', 'Dirección H', '8901234567');
CALL insertar_proveedor('Proveedor I', 'Dirección I', '9012345678');
CALL insertar_proveedor('Proveedor J', 'Dirección J', '0123456789');

SELECT * FROM categorias;

