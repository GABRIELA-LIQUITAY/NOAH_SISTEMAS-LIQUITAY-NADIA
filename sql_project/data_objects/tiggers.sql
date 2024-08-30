USE noah_sistemas;

-- Trigger para almacenar registros modificados si la reserva se cancela:


CREATE TABLE 
    LOG_CAMBIOS (
        id_log          INT NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,   tabla_afectada  VARCHAR (50)
    ,   accion          VARCHAR(50)
    ,   fecha           DATETIME
    ,   idcliente       INT
    ,   usuario         VARCHAR(50)
    );



DELIMITER //

CREATE TRIGGER after_insert_trigger
AFTER INSERT ON CLIENTE
FOR EACH ROW
BEGIN
    INSERT INTO LOG_CAMBIOS (tabla_afectada, accion, fecha,idcliente,usuario)
    VALUES ('CLIENTE', 'INSERT', NOW() , NEW.IDCLIENTE,USER());
END //

DELIMITER ;



--  Trigger para almacenar registros modificados si la reserva se cancela

DELIMITER //

CREATE TRIGGER after_update_cancelacion_trigger
AFTER UPDATE ON PEDIDO
FOR EACH ROW
BEGIN
    IF OLD.CANCELACION IS NULL AND NEW.CANCELACION IS NOT NULL THEN
        INSERT INTO LOG_CAMBIOS (tabla_afectada, accion, fecha,idcliente,usuario)
        VALUES ('PEDIDO', 'CANCELACION', NOW());
    END IF;
END //

DELIMITER ;


-- Trigger para verificar si el correo electrónico de un cliente es único al insertar un nuevo cliente

DELIMITER //

CREATE TRIGGER before_insert_cliente_trigger
BEFORE INSERT ON CLIENTE
FOR EACH ROW
BEGIN
    DECLARE correo_count INT;
    
    SELECT COUNT(*) INTO correo_count
        FROM CLIENTE
    WHERE CORREO = NEW.CORREO;
    
    IF correo_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo electrónico ya está en uso.';
    END IF;
END //

DELIMITER ;


-- Trigger para verificar si un cliente ya tiene una reserva hecha en la misma hora y mesa y que no esté cancelada:


DELIMITER //

CREATE TRIGGER before_insert_pedido_trigger
BEFORE INSERT ON PEDIDO
FOR EACH ROW
BEGIN
    DECLARE pedido_count INT;
    
    SELECT COUNT(*) INTO pedido_count
        FROM PEDIDO
    WHERE IDCLIENTE = NEW.IDCLIENTE
        AND IDPRODUCTO = NEW.IDPRODUCTO
        AND FECHA = NEW.FECHA
        AND CANCELACION IS NULL;
        
    IF pedido_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente ya realizo un pedido del mismo producto en la misma fecha y hora.';
    END IF;
END //

DELIMITER ;

