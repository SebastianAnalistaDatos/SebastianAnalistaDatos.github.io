create database Amazon;
use amazon;

-- Llamar las tablas para mirar los datos

select*from ordenes;
select*from ubicacion;

-- Desactivar la seguridad para permitir eliminación y modificación (Limpieza)

SET SQL_SAFE_UPDATES = 0;

-- Limpieza de los datos CSV luego de power query

Delete from ubicacion
where
Store_Latitude <= "0,0000000" or
Store_Longitude <= "0,0000000" or
Drop_Latitude <= "0,0000000" or
Drop_Longitude <= "0,0000000";

DELETE FROM ordenes
where Agent_Rating IS NULL;

delete from ordenes
where order_time = "NaN ";

select order_date from ordenes
where order_date is null;

-- Corregir columna Order_date ya que no tenia el formato YYYY-MM-DD

SELECT *
FROM `amazon`.`ordenes`
WHERE STR_TO_DATE(`Order_Date`, '%d/%m/%Y') IS NULL
AND `Order_Date` IS NOT NULL;

UPDATE `amazon`.`ordenes`
SET `Order_Date` = DATE_FORMAT(STR_TO_DATE(`Order_Date`, '%d/%m/%Y'), '%Y-%m-%d')
WHERE STR_TO_DATE(`Order_Date`, '%d/%m/%Y') IS NOT NULL;

-- Activa de nuevo la seguridad luego de la limpieza adicional

SET SQL_SAFE_UPDATES = 1;

-- Consultas pertinentes con el proyecto

-- Promedio del tiempo de entrega por tipo de vehículo
SELECT vehicle, AVG(delivery_time) AS PromedioTiempoEntrega
FROM ordenes
GROUP BY vehicle
ORDER BY PromedioTiempoEntrega;

-- Promedio del tiempo de entrega por ciudad o zona
SELECT area, AVG(delivery_time) AS PromedioTiempoEntrega
FROM ordenes
GROUP BY area
ORDER BY PromedioTiempoEntrega DESC;

-- Validación de la columna order_time para futuras consultas
select order_time from ordenes
order by order_time desc;

-- Promedio del tiempo de entrega por hora del día
SELECT HOUR(order_time) AS HoraDelPedido, AVG(delivery_time) AS PromedioTiempoEntrega
FROM ordenes
GROUP BY HoraDelPedido
ORDER BY HoraDelPedido;

-- Conteo de pedidos por tipo de vehículo y zona
SELECT vehicle, area, COUNT(*) AS TotalPedidos
FROM ordenes
GROUP BY vehicle, area
ORDER BY area, TotalPedidos DESC;

-- Tendencia del tiempo de entrega a lo largo del tiempo (por mes)
SELECT DATE_FORMAT(order_date, '%Y-%m') AS MesDelPedido, AVG(delivery_time) AS PromedioTiempoEntrega
FROM ordenes
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY DATE_FORMAT(order_date, '%Y-%m');

-- Conteo de pedidos de acuerdo al trafico y clima
select delivery_time, traffic, weather, area, count(*)
from ordenes
where delivery_time > 245
group by delivery_time, traffic, weather, area
order by delivery_time asc;

-- Visualización de pedidos de acuerdo a la ubicación de la tienda y el vehiculo sea motocicleta
select o.order_id, o.vehicle, o.delivery_time, o.weather, o.traffic , u.store_latitude, u.store_longitude
from ordenes o
join ubicacion u on o.id_ubicacion = u.id_ubicacion
where o.vehicle = "motorcycle"
order by delivery_time asc;