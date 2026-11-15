-- =============================================================================
-- Proyecto final de Bases de Datos 2027-1
-- Sistema de información para una cadena de papelerías
-- Script 03: carga de información
--
-- Ejecutar conectado a la base papeleria, después de los scripts 01 y 02:
--   psql -U postgres -d papeleria -f 03_carga_datos.sql
-- Las ventas se registran con sp_registrar_venta, así que pasan por los mismos
-- triggers que una venta real (descuento de stock, precios y totales).
-- Los datos de personas y empresas son ficticios.
-- =============================================================================

set client_min_messages = warning;

-- -----------------------------------------------------------------------------
-- Códigos postales
-- -----------------------------------------------------------------------------
insert into codigo_postal(cp, estado) values
  ('01000', 'Ciudad de México'),
  ('03100', 'Ciudad de México'),
  ('04510', 'Ciudad de México'),
  ('06000', 'Ciudad de México'),
  ('53100', 'Estado de México'),
  ('54000', 'Estado de México'),
  ('57000', 'Estado de México'),
  ('50000', 'Estado de México'),
  ('62000', 'Morelos'),
  ('72000', 'Puebla'),
  ('76000', 'Querétaro'),
  ('44100', 'Jalisco'),
  ('64000', 'Nuevo León'),
  ('42000', 'Hidalgo');

-- -----------------------------------------------------------------------------
-- Proveedores y sus teléfonos
-- -----------------------------------------------------------------------------
insert into proveedor(razon_social, nombre, cp, colonia, calle, numero) values
  ('Distribuidora Papelera del Valle S.A. de C.V.', 'Papelera del Valle', '03100', 'Del Valle Centro', 'Av. Insurgentes Sur', '1235'),
  ('Comercializadora Escolar Azteca S.A. de C.V.', 'Escolar Azteca', '54000', 'Tlalnepantla Centro', 'Av. Hidalgo', '48'),
  ('Regalos y Detalles Monarca S.A. de C.V.', 'Detalles Monarca', '72000', 'Centro', 'Calle 5 de Mayo', '212'),
  ('Suministros de Oficina del Bajío S.A. de C.V.', 'Oficina del Bajío', '76000', 'Centro', 'Av. Corregidora Norte', '87'),
  ('Recargas y Servicios Digitales MX S.A. de C.V.', 'RecargaMX', '06000', 'Centro', 'República de Uruguay', '61-B'),
  ('Insumos de Impresión Toluca S.A. de C.V.', 'Insumos Toluca', '50000', 'Centro', 'Av. Independencia Poniente', '305');

insert into telefono_proveedor(id_proveedor, telefono)
select p.id_proveedor, t.telefono
  from proveedor p
  join (values
    ('Distribuidora Papelera del Valle S.A. de C.V.', '5552841190'),
    ('Distribuidora Papelera del Valle S.A. de C.V.', '5552841191'),
    ('Comercializadora Escolar Azteca S.A. de C.V.', '5553907712'),
    ('Regalos y Detalles Monarca S.A. de C.V.', '2222461085'),
    ('Regalos y Detalles Monarca S.A. de C.V.', '2222461086'),
    ('Suministros de Oficina del Bajío S.A. de C.V.', '4422153340'),
    ('Recargas y Servicios Digitales MX S.A. de C.V.', '5551306624'),
    ('Insumos de Impresión Toluca S.A. de C.V.', '7222149958'),
    ('Insumos de Impresión Toluca S.A. de C.V.', '7222149950')
  ) as t(razon_social, telefono) on t.razon_social = p.razon_social;

-- -----------------------------------------------------------------------------
-- Productos (inventario inicial)
-- -----------------------------------------------------------------------------
insert into producto(codigo_barras, nombre, marca, descripcion, tipo, precio_venta, precio_compra,
                     foto, fecha_compra, stock, id_proveedor)
select v.codigo_barras, v.nombre, v.marca, v.descripcion, v.tipo, v.precio_venta, v.precio_compra,
       v.foto, v.fecha_compra::date, v.stock, p.id_proveedor
  from (values
    ('7509000412705', 'Cuaderno profesional raya', 'Scribe', 'Cuaderno profesional de 100 hojas, raya, espiral metálico', 'PAPELERIA', 49.00, 32.00, 'img/productos/7509000412705.jpg', '2026-08-20', 201, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000413078', 'Cuaderno profesional cuadro chico', 'Scribe', 'Cuaderno profesional de 100 hojas, cuadro chico de 5 mm, espiral metálico', 'PAPELERIA', 49.00, 32.00, 'img/productos/7509000413078.jpg', '2026-08-31', 176, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000413443', 'Cuaderno forma francesa cuadro grande', 'Norma', 'Cuaderno forma francesa de 100 hojas, cuadro grande de 7 mm, cosido', 'PAPELERIA', 38.00, 24.00, 'img/productos/7509000413443.jpg', '2026-08-31', 83, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000413818', 'Bolígrafo azul punto mediano', 'BIC', 'Bolígrafo Cristal de tinta azul, punto mediano de 1.0 mm', 'PAPELERIA', 7.00, 4.20, 'img/productos/7509000413818.jpg', '2026-08-29', 361, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000414181', 'Bolígrafo negro punto mediano', 'BIC', 'Bolígrafo Cristal de tinta negra, punto mediano de 1.0 mm', 'PAPELERIA', 7.00, 4.20, 'img/productos/7509000414181.jpg', '2026-08-24', 379, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000414556', 'Bolígrafo de gel negro 0.7 mm', 'Pilot', 'Bolígrafo retráctil de tinta de gel negra, punto de 0.7 mm', 'PAPELERIA', 29.00, 18.00, 'img/productos/7509000414556.jpg', '2026-08-23', 178, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000414921', 'Lápiz de grafito No. 2', 'Mirado', 'Lápiz hexagonal de grafito No. 2 con goma', 'PAPELERIA', 6.50, 3.80, 'img/productos/7509000414921.jpg', '2026-08-29', 318, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000415294', 'Lápiz bicolor rojo y azul', 'Dixon', 'Lápiz de color bicolor, mitad rojo y mitad azul', 'PAPELERIA', 9.00, 5.00, 'img/productos/7509000415294.jpg', '2026-08-22', 121, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000415669', 'Goma blanca de migajón', 'Pelikan', 'Goma blanca de migajón para lápiz, tamaño mediano', 'PAPELERIA', 8.00, 4.00, 'img/productos/7509000415669.jpg', '2026-08-29', 139, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000416031', 'Sacapuntas metálico', 'Maped', 'Sacapuntas metálico de un orificio', 'PAPELERIA', 12.00, 6.00, 'img/productos/7509000416031.jpg', '2026-08-28', 103, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000416406', 'Marcatextos amarillo', 'Stabilo', 'Marcatextos fluorescente amarillo, punta biselada', 'PAPELERIA', 24.00, 14.00, 'img/productos/7509000416406.jpg', '2026-08-29', 111, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000416772', 'Corrector tipo pluma', 'Pentel', 'Corrector líquido tipo pluma de 7 ml, punta metálica', 'PAPELERIA', 35.00, 22.00, 'img/productos/7509000416772.jpg', '2026-08-31', 86, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000417144', 'Pegamento en barra 21 g', 'Pritt', 'Lápiz adhesivo en barra de 21 g, no tóxico', 'PAPELERIA', 36.00, 22.00, 'img/productos/7509000417144.jpg', '2026-08-30', 104, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000417519', 'Tijeras escolares punta roma', 'Maped', 'Tijeras escolares de 13 cm con punta roma', 'PAPELERIA', 32.00, 18.00, 'img/productos/7509000417519.jpg', '2026-08-27', 35, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000417885', 'Regla de plástico 30 cm', 'Maped', 'Regla transparente de plástico de 30 cm', 'PAPELERIA', 16.00, 9.00, 'img/productos/7509000417885.jpg', '2026-08-29', 115, 'Comercializadora Escolar Azteca S.A. de C.V.'),
    ('7509000418257', 'Juego de geometría 4 piezas', 'Barrilito', 'Juego de geometría con regla, escuadras y transportador', 'PAPELERIA', 45.00, 28.00, 'img/productos/7509000418257.jpg', '2026-08-29', 56, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000418622', 'Colores de madera 12 piezas', 'Crayola', 'Caja de 12 lápices de colores de madera', 'PAPELERIA', 69.00, 45.00, 'img/productos/7509000418622.jpg', '2026-08-20', 73, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000418998', 'Plumones lavables 10 piezas', 'Crayola', 'Paquete de 10 plumones lavables de punta gruesa', 'PAPELERIA', 89.00, 58.00, 'img/productos/7509000418998.jpg', '2026-08-20', 65, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000419360', 'Hojas blancas carta 100 piezas', 'Scribe', 'Paquete de 100 hojas blancas tamaño carta de 75 g', 'PAPELERIA', 59.00, 38.00, 'img/productos/7509000419360.jpg', '2026-08-20', 82, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000419735', 'Cartulina blanca', 'Bristol', 'Cartulina blanca de 50 x 65 cm', 'PAPELERIA', 8.00, 4.50, 'img/productos/7509000419735.jpg', '2026-08-19', 173, 'Distribuidora Papelera del Valle S.A. de C.V.'),
    ('7509000420106', 'Folder carta 10 piezas', 'Mapasa', 'Paquete de 10 folders tamaño carta color crema', 'PAPELERIA', 30.00, 18.00, 'img/productos/7509000420106.jpg', '2026-08-24', 114, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000420472', 'Cinta adhesiva transparente', 'Scotch', 'Cinta adhesiva transparente de 18 mm x 33 m', 'PAPELERIA', 20.00, 12.00, 'img/productos/7509000420472.jpg', '2026-08-18', 92, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000420847', 'Engrapadora estándar', 'Barrilito', 'Engrapadora metálica para grapas estándar 26/6', 'PAPELERIA', 89.00, 55.00, 'img/productos/7509000420847.jpg', '2026-08-30', 73, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000421219', 'Calculadora científica', 'Casio', 'Calculadora científica fx-82MS de 240 funciones', 'PAPELERIA', 329.00, 210.00, 'img/productos/7509000421219.jpg', '2026-08-21', 17, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000421585', 'Memoria USB 32 GB', 'Kingston', 'Memoria USB 3.2 DataTraveler de 32 GB', 'PAPELERIA', 149.00, 95.00, 'img/productos/7509000421585.jpg', '2026-08-20', 27, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000421950', 'Calculadora graficadora', 'Casio', 'Calculadora graficadora fx-9750GIII', 'PAPELERIA', 1399.00, 980.00, 'img/productos/7509000421950.jpg', '2026-11-11', 0, 'Suministros de Oficina del Bajío S.A. de C.V.'),
    ('7509000422322', 'Taza Feliz cumpleaños', 'Monarca', 'Taza de cerámica de 325 ml con mensaje de cumpleaños', 'REGALO', 89.00, 45.00, 'img/productos/7509000422322.jpg', '2026-08-22', 75, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000422698', 'Peluche oso 25 cm', 'Monarca', 'Oso de peluche café de 25 cm con moño', 'REGALO', 219.00, 120.00, 'img/productos/7509000422698.jpg', '2026-08-18', 24, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000423060', 'Peluche unicornio 30 cm', 'Monarca', 'Unicornio de peluche blanco de 30 cm', 'REGALO', 269.00, 150.00, 'img/productos/7509000423060.jpg', '2026-11-11', 0, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000423435', 'Bolsa de regalo mediana', 'Monarca', 'Bolsa de regalo de papel de 25 x 33 cm con asas', 'REGALO', 25.00, 12.00, 'img/productos/7509000423435.jpg', '2026-08-27', 68, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000423800', 'Tarjeta de felicitación', 'Hallmark', 'Tarjeta de felicitación con sobre, diseños surtidos', 'REGALO', 35.00, 18.00, 'img/productos/7509000423800.jpg', '2026-08-30', 91, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000424173', 'Globo metálico corazón', 'Anagram', 'Globo metálico en forma de corazón de 45 cm', 'REGALO', 45.00, 22.00, 'img/productos/7509000424173.jpg', '2026-08-28', 45, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000424548', 'Chocolates surtidos 12 piezas', 'Ferrero', 'Caja de 12 chocolates surtidos', 'REGALO', 185.00, 120.00, 'img/productos/7509000424548.jpg', '2026-08-23', 23, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000424913', 'Llavero decorativo', 'Monarca', 'Llavero metálico con figura decorativa', 'REGALO', 35.00, 15.00, 'img/productos/7509000424913.jpg', '2026-08-19', 54, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000425286', 'Portarretrato 4 x 6', 'Monarca', 'Portarretrato de madera para fotografía de 4 x 6 pulgadas', 'REGALO', 99.00, 55.00, 'img/productos/7509000425286.jpg', '2026-08-25', 17, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000425651', 'Moños para regalo 10 piezas', 'Monarca', 'Paquete de 10 moños adhesivos de colores', 'REGALO', 35.00, 18.00, 'img/productos/7509000425651.jpg', '2026-08-29', 82, 'Regalos y Detalles Monarca S.A. de C.V.'),
    ('7509000426023', 'Impresión blanco y negro carta', 'HP', 'Impresión láser en blanco y negro, una cara, tamaño carta', 'IMPRESION', 2.00, 0.45, 'img/productos/7509000426023.jpg', '2026-08-20', 935, 'Insumos de Impresión Toluca S.A. de C.V.'),
    ('7509000426399', 'Impresión a color carta', 'HP', 'Impresión de inyección a color, una cara, tamaño carta', 'IMPRESION', 8.00, 2.80, 'img/productos/7509000426399.jpg', '2026-08-24', 948, 'Insumos de Impresión Toluca S.A. de C.V.'),
    ('7509000426764', 'Copia blanco y negro carta', 'Xerox', 'Copia fotostática en blanco y negro, tamaño carta', 'IMPRESION', 1.50, 0.35, 'img/productos/7509000426764.jpg', '2026-08-24', 1165, 'Insumos de Impresión Toluca S.A. de C.V.'),
    ('7509000427136', 'Impresión fotográfica 4 x 6', 'Epson', 'Impresión de fotografía en papel brillante de 4 x 6 pulgadas', 'IMPRESION', 12.00, 3.50, 'img/productos/7509000427136.jpg', '2026-08-31', 285, 'Insumos de Impresión Toluca S.A. de C.V.'),
    ('7509000427501', 'Recarga Telcel 50', 'Telcel', 'Tiempo aire Telcel de 50 pesos', 'RECARGA', 50.00, 48.00, 'img/productos/7509000427501.jpg', '2026-08-29', 173, 'Recargas y Servicios Digitales MX S.A. de C.V.'),
    ('7509000427877', 'Recarga Telcel 100', 'Telcel', 'Tiempo aire Telcel de 100 pesos', 'RECARGA', 100.00, 96.00, 'img/productos/7509000427877.jpg', '2026-08-21', 186, 'Recargas y Servicios Digitales MX S.A. de C.V.'),
    ('7509000428249', 'Recarga AT&T 50', 'AT&T', 'Tiempo aire AT&T de 50 pesos', 'RECARGA', 50.00, 48.20, 'img/productos/7509000428249.jpg', '2026-08-20', 163, 'Recargas y Servicios Digitales MX S.A. de C.V.'),
    ('7509000428614', 'Recarga Movistar 50', 'Movistar', 'Tiempo aire Movistar de 50 pesos', 'RECARGA', 50.00, 48.30, 'img/productos/7509000428614.jpg', '2026-08-28', 108, 'Recargas y Servicios Digitales MX S.A. de C.V.'),
    ('7509000428980', 'Recarga Unefon 50', 'Unefon', 'Tiempo aire Unefon de 50 pesos', 'RECARGA', 50.00, 48.20, 'img/productos/7509000428980.jpg', '2026-08-30', 103, 'Recargas y Servicios Digitales MX S.A. de C.V.')
  ) as v(codigo_barras, nombre, marca, descripcion, tipo, precio_venta, precio_compra,
         foto, fecha_compra, stock, razon_social)
  join proveedor p on p.razon_social = v.razon_social;

-- -----------------------------------------------------------------------------
-- Clientes y sus correos
-- Van en la misma transacción porque todo cliente debe tener al menos un email
-- al confirmar (trigger diferido tg_cliente_con_email).
-- -----------------------------------------------------------------------------
begin;

insert into cliente(rfc, nombre, ap_paterno, ap_materno, cp, colonia, calle, numero) values
  ('XAXX010101000', 'PÚBLICO EN GENERAL', null, null, '04510', 'Ciudad Universitaria', 'Av. Universidad', '3000'),
  ('HERL82091968J', 'Laura', 'Hernández', 'Ruiz', '50000', 'Centro', 'Calle Hidalgo', '379'),
  ('TOSA75072701T', 'Miguel Ángel', 'Torres', 'Salinas', '06000', 'Centro', 'Calle Zaragoza', '290'),
  ('RACD030628N16', 'Daniela', 'Ramírez', 'Castro', '53100', 'Ciudad Satélite', 'Calle Pino', '328'),
  ('MELJ930627M52', 'Jorge', 'Mendoza', 'López', '76000', 'Centro', 'Av. Revolución', '313'),
  ('FOOV020406HZ9', 'Valeria', 'Flores', 'Ortiz', '04510', 'Ciudad Universitaria', 'Av. Juárez', '349'),
  ('GUNR010810MK0', 'Ricardo', 'Gutiérrez', 'Navarro', '44100', 'Centro', 'Av. Revolución', '116'),
  ('MOVF760314683', 'Fernanda', 'Morales', 'Vega', '54000', 'Tlalnepantla Centro', 'Av. Revolución', '171'),
  ('JIRC9406269P7', 'Carlos', 'Jiménez', 'Rojas', '50000', 'Centro', 'Av. Juárez', '253'),
  ('CAAX0012175R4', 'Ximena', 'Castillo', 'Aguilar', '62000', 'Centro', 'Calle Morelos', '312'),
  ('VAPL891022NB0', 'Luis', 'Vargas', 'Peña', '54000', 'Tlalnepantla Centro', 'Calle Hidalgo', '80'),
  ('RODA830927YZM', 'Andrea', 'Romero', 'Domínguez', '64000', 'Centro', 'Calle Pino', '208'),
  ('SAFO960814HHR', 'Óscar', 'Sánchez', 'Fuentes', '50000', 'Centro', 'Calle Zaragoza', '106'),
  ('CAMP911028TT4', 'Paola', 'Chávez', 'Medina', '03100', 'Del Valle Centro', 'Av. Universidad', '15'),
  ('RECE860215WKD', 'Emilio', 'Reyes', 'Cortés', '76000', 'Centro', 'Calle Allende', '21'),
  ('DEIM990815V6U', 'Mariana', 'Delgado', 'Ibarra', '62000', 'Centro', 'Calle Hidalgo', '102'),
  ('SICH840623CVA', 'Héctor', 'Silva', 'Campos', '44100', 'Centro', 'Calle Allende', '149'),
  ('CUER9903060MS', 'Regina', 'Cruz', 'Escobar', '06000', 'Centro', 'Calle Hidalgo', '16'),
  ('PAXD930507VCS', 'Diego', 'Pacheco', null, '53100', 'Ciudad Satélite', 'Av. Universidad', '385'),
  ('LUHS930112Z2T', 'Sofía', 'Luna', 'Herrera', '53100', 'Ciudad Satélite', 'Calle Guerrero', '320'),
  ('NUGR020606V69', 'Raúl', 'Núñez', 'Guerrero', '44100', 'Centro', 'Av. Reforma', '202'),
  ('CMS100215AB3', 'Colegio Montessori del Sur S.C.', null, null, '04510', 'Copilco Universidad', 'Calle Cerro del Agua', '120'),
  ('DCR180903K27', 'Despacho Contable Ramírez y Asociados S.C.', null, null, '03100', 'Del Valle Centro', 'Calle Pilares', '415');

insert into email_cliente(rfc, email) values
  ('XAXX010101000', 'facturacion@papeleria.ejemplo.mx'),
  ('HERL82091968J', 'laura.hernandez@ejemplo.mx'),
  ('HERL82091968J', 'lhernandez40@correo.ejemplo.mx'),
  ('TOSA75072701T', 'miguel.torres@ejemplo.mx'),
  ('TOSA75072701T', 'mtorres29@correo.ejemplo.mx'),
  ('RACD030628N16', 'daniela.ramirez@ejemplo.mx'),
  ('MELJ930627M52', 'jorge.mendoza@ejemplo.mx'),
  ('FOOV020406HZ9', 'valeria.flores@ejemplo.mx'),
  ('GUNR010810MK0', 'ricardo.gutierrez@ejemplo.mx'),
  ('MOVF760314683', 'fernanda.morales@ejemplo.mx'),
  ('JIRC9406269P7', 'carlos.jimenez@ejemplo.mx'),
  ('CAAX0012175R4', 'ximena.castillo@ejemplo.mx'),
  ('VAPL891022NB0', 'luis.vargas@ejemplo.mx'),
  ('VAPL891022NB0', 'lvargas65@correo.ejemplo.mx'),
  ('RODA830927YZM', 'andrea.romero@ejemplo.mx'),
  ('SAFO960814HHR', 'oscar.sanchez@ejemplo.mx'),
  ('CAMP911028TT4', 'paola.chavez@ejemplo.mx'),
  ('RECE860215WKD', 'emilio.reyes@ejemplo.mx'),
  ('DEIM990815V6U', 'mariana.delgado@ejemplo.mx'),
  ('SICH840623CVA', 'hector.silva@ejemplo.mx'),
  ('CUER9903060MS', 'regina.cruz@ejemplo.mx'),
  ('PAXD930507VCS', 'diego.pacheco@ejemplo.mx'),
  ('LUHS930112Z2T', 'sofia.luna@ejemplo.mx'),
  ('NUGR020606V69', 'raul.nunez@ejemplo.mx'),
  ('CMS100215AB3', 'compras@montessorisur.ejemplo.mx'),
  ('CMS100215AB3', 'direccion@montessorisur.ejemplo.mx'),
  ('DCR180903K27', 'administracion@contableramirez.ejemplo.mx');

commit;

-- -----------------------------------------------------------------------------
-- Ventas del 1 de septiembre al 13 de noviembre de 2026
-- Cada llamada registra una venta completa (cliente, códigos, cantidades, fecha)
-- y se confirma por separado, como en la operación real: una venta, una transacción.
-- -----------------------------------------------------------------------------
do $$
declare
  v varchar;
begin
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[2], '2026-09-01', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000412705', '7509000413818', '7509000416406', '7509000420106'], array[6, 5, 5, 6], '2026-09-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651'], array[1], '2026-09-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000415669'], array[3, 2], '2026-09-01', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000413443'], array[2], '2026-09-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651'], array[1], '2026-09-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000416406'], array[2, 3], '2026-09-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414921'], array[2, 1], '2026-09-02', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000422698'], array[1], '2026-09-02', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000413443', '7509000414181', '7509000427501'], array[2, 5, 1], '2026-09-02', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000413443', '7509000414921', '7509000427501'], array[2, 1, 1], '2026-09-02', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031'], array[2], '2026-09-02', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000414556', '7509000418622', '7509000428249'], array[12, 6, 1], '2026-09-02', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913', '7509000425286'], array[2, 1], '2026-09-02', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435', '7509000424173'], array[2, 2], '2026-09-02', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000413818', '7509000414181', '7509000419360', '7509000426764'], array[3, 4, 2, 3], '2026-09-02', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000424913', '7509000426399'], array[3, 1, 1], '2026-09-02', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000412705', '7509000413078'], array[3, 1], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294'], array[3], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000417519'], array[1, 1], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428614'], array[1], '2026-09-03', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000413078'], array[3], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772', '7509000427877'], array[1, 1], '2026-09-03', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000424548'], array[1], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556'], array[3], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[4], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000414921', '7509000418257'], array[3, 1, 1], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000414921'], array[3, 4], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[3], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427136', '7509000427877'], array[2, 1], '2026-09-03', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000413818'], array[5], '2026-09-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[4], '2026-09-04', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000418998'], array[6], '2026-09-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000417885'], array[1, 2], '2026-09-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[3], '2026-09-04', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000413818', '7509000415669', '7509000428249'], array[3, 1, 1], '2026-09-04', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000413818'], array[5], '2026-09-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000417885', '7509000426023'], array[3, 2, 3], '2026-09-04', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000415294', '7509000417885'], array[2, 2], '2026-09-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000414556', '7509000426764'], array[4, 1, 2], '2026-09-04', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000417519', '7509000424173'], array[1, 2], '2026-09-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000417144', '7509000423435'], array[1, 2, 2], '2026-09-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418998'], array[1], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000417885', '7509000423435'], array[2, 2, 2], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414181'], array[3, 4], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435'], array[1], '2026-09-05', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000423435'], array[2], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000418257', '7509000424913', '7509000426399'], array[1, 1, 2, 2], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000414181', '7509000416406'], array[3, 4, 2], '2026-09-05', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000413818', '7509000426764', '7509000427877'], array[4, 2, 1], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000417144', '7509000425651'], array[3, 1, 1], '2026-09-05', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000423435', '7509000427501', '7509000427877'], array[2, 1, 1], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000414921', '7509000426399', '7509000427501'], array[3, 3, 7, 1], '2026-09-05', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000419735'], array[3], '2026-09-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000421219'], array[1], '2026-09-05', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413818', '7509000420472'], array[6, 4], '2026-09-06', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000424548', '7509000428249'], array[1, 1], '2026-09-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[3], '2026-09-06', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000413443', '7509000423435', '7509000426399'], array[2, 2, 7], '2026-09-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000416031'], array[2, 1], '2026-09-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[6], '2026-09-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424173', '7509000426023', '7509000427501'], array[1, 1, 1], '2026-09-06', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000416772', '7509000423800', '7509000428249'], array[10, 1, 1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428614'], array[1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000418622'], array[3, 1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622'], array[1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423800'], array[1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428614'], array[1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031'], array[1], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000416406', '7509000417144'], array[2, 3, 2], '2026-09-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078'], array[3], '2026-09-07', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000415294', '7509000418998', '7509000423800'], array[1, 1, 2], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423800', '7509000424173', '7509000427501'], array[1, 2, 1], '2026-09-08', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000414556'], array[3], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[2], '2026-09-08', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000416772', '7509000418257'], array[1, 1], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000428614'], array[3, 1], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425286', '7509000426023'], array[1, 16], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413818', '7509000414921', '7509000416031'], array[2, 2, 2, 2], '2026-09-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000419735', '7509000427501'], array[1, 3, 1], '2026-09-09', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000428249'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[3], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000421219'], array[3, 1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424173'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427136'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414921', '7509000417885', '7509000424913'], array[1, 5, 1, 2], '2026-09-09', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000415294', '7509000415669', '7509000418622', '7509000420106'], array[1, 3, 1, 1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424548'], array[1], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000416031', '7509000417144'], array[2, 1, 2], '2026-09-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000419360', '7509000422322', '7509000426764'], array[1, 1, 1, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[5], '2026-09-10', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000413818', '7509000417885'], array[12, 3], '2026-09-10', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000417885'], array[2], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000428249'], array[1, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435'], array[1], '2026-09-10', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000413818', '7509000415294', '7509000419360'], array[3, 3, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000427501'], array[1], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360', '7509000427501'], array[2, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000419360'], array[1], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000423800'], array[3, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000414181', '7509000422698'], array[3, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000425651', '7509000426023'], array[1, 16], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772', '7509000420847', '7509000427501', '7509000428614'], array[1, 1, 1, 1], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651'], array[1], '2026-09-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424173', '7509000427877'], array[2, 1], '2026-09-11', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000414181', '7509000420847', '7509000422698'], array[1, 1, 1], '2026-09-11', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000413818', '7509000421585', '7509000428614'], array[5, 1, 1], '2026-09-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-09-11', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000413078', '7509000414921', '7509000419360'], array[2, 1, 2], '2026-09-11', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000427501', '7509000427877'], array[1, 1], '2026-09-11', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000419735'], array[4], '2026-09-11', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000416031', '7509000424548'], array[2, 1], '2026-09-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106', '7509000426399'], array[2, 10], '2026-09-11', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414181'], array[5], '2026-09-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078'], array[2], '2026-09-11', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000413078'], array[2], '2026-09-11', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000419360'], array[1], '2026-09-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000426023'], array[3, 8], '2026-09-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414556'], array[1, 3], '2026-09-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428614'], array[1], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000416772', '7509000417519'], array[6, 1, 1], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000418257'], array[1, 1], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000416406'], array[3, 1], '2026-09-12', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000428249'], array[1], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420847'], array[1], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000415669', '7509000427877'], array[2, 2, 1], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000426764'], array[2, 12], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443'], array[2], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257'], array[1], '2026-09-12', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000415669', '7509000426023'], array[3, 25], '2026-09-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000417519', '7509000426764'], array[3, 1, 20], '2026-09-12', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000420847', '7509000428614'], array[1, 1], '2026-09-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000420472'], array[2, 2], '2026-09-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000414181', '7509000415669'], array[1, 5, 2], '2026-09-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[3], '2026-09-13', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000415294'], array[8], '2026-09-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000424173'], array[4, 2], '2026-09-13', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000424173'], array[1], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000428249'], array[4, 1], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651', '7509000428249'], array[1, 1], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[3], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885', '7509000420106'], array[1, 1], '2026-09-14', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000419360', '7509000421219', '7509000426764'], array[1, 1, 2], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000421219', '7509000425286'], array[2, 1, 1], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000420847', '7509000426399'], array[1, 1, 8], '2026-09-14', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000413818', '7509000425286', '7509000427501'], array[30, 1, 1], '2026-09-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399', '7509000427136'], array[7, 1], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000428614'], array[1, 1], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[2], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000413443', '7509000414921', '7509000423800'], array[2, 1, 1, 2], '2026-09-15', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413078', '7509000413443', '7509000420472'], array[6, 2, 8], '2026-09-15', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000427136'], array[1], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426764'], array[6], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000418998'], array[2, 1], '2026-09-15', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000426023', '7509000427136'], array[2, 2], '2026-09-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427136'], array[4], '2026-09-15', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000414181', '7509000414556'], array[1, 1], '2026-09-16', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414921'], array[15], '2026-09-16', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000416406', '7509000419735', '7509000424548'], array[1, 3, 3, 1], '2026-09-16', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000413818'], array[5], '2026-09-16', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000418257'], array[2, 1], '2026-09-17', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000423800'], array[2], '2026-09-17', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414556', '7509000421585', '7509000425651'], array[6, 4, 1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556'], array[1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000414556'], array[1, 3], '2026-09-17', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000423435', '7509000426764', '7509000427877'], array[1, 7, 1], '2026-09-17', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000418998'], array[5], '2026-09-17', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000418998'], array[1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413818', '7509000414181', '7509000427877'], array[2, 5, 3, 1], '2026-09-17', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413818'], array[12], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427136'], array[1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360', '7509000423435'], array[1, 2], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735'], array[3], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443'], array[1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417519', '7509000418998', '7509000427136'], array[1, 1, 1], '2026-09-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000419735', '7509000423435'], array[5, 2, 2], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000427877'], array[1, 1], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023', '7509000427877'], array[9, 1], '2026-09-18', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000420106', '7509000424173'], array[1, 2], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435', '7509000426399'], array[2, 3], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144', '7509000428249'], array[2, 1], '2026-09-18', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000414181'], array[2], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913'], array[2], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360'], array[2], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000417519', '7509000426023'], array[5, 1, 7], '2026-09-18', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772'], array[1], '2026-09-18', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000413078', '7509000415669', '7509000424913'], array[3, 3, 1], '2026-09-19', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000413443', '7509000421219', '7509000426023', '7509000426764'], array[2, 1, 12, 6], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000413818', '7509000416406', '7509000423800'], array[1, 5, 1, 2], '2026-09-19', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000427877'], array[1], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414181', '7509000426764'], array[1, 5, 8], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257'], array[1], '2026-09-19', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000417885', '7509000423800'], array[3, 2], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420847', '7509000426023'], array[1, 1], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413818', '7509000421585', '7509000427877'], array[3, 1, 1, 1], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257', '7509000419735', '7509000426399'], array[1, 4, 4], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000428249'], array[3, 1], '2026-09-19', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000415669', '7509000425651'], array[2, 1], '2026-09-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556'], array[3], '2026-09-19', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000414556', '7509000414921', '7509000422322'], array[3, 6, 1], '2026-09-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000419735'], array[4, 1], '2026-09-20', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000415669'], array[2], '2026-09-20', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000426764'], array[18], '2026-09-20', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000412705', '7509000413818'], array[6, 18], '2026-09-20', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000414181', '7509000418998'], array[2, 1], '2026-09-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[4], '2026-09-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144', '7509000426764'], array[2, 11], '2026-09-20', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000416772'], array[1], '2026-09-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000425286'], array[1, 1], '2026-09-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-09-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[4], '2026-09-21', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000413443'], array[2], '2026-09-21', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000413078', '7509000417885', '7509000420106'], array[3, 1, 1], '2026-09-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705'], array[2], '2026-09-21', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000416772', '7509000419360', '7509000426764'], array[6, 8, 15], '2026-09-21', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000413078', '7509000413818', '7509000414181'], array[3, 3, 1], '2026-09-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427877'], array[1], '2026-09-21', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000422698'], array[1], '2026-09-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000422322', '7509000423435'], array[2, 1, 1], '2026-09-21', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000426023'], array[12], '2026-09-22', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000417885'], array[2], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000415669', '7509000425651'], array[3, 2, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000427877'], array[2, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000414556', '7509000427501'], array[2, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885'], array[2], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[7], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[2], '2026-09-22', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000414181', '7509000426764'], array[5, 5], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426764', '7509000427501'], array[2, 8, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000415669', '7509000417519', '7509000420847'], array[2, 1, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000426023'], array[1, 13], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[1], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000416031', '7509000422322'], array[3, 1, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106', '7509000427501'], array[1, 1], '2026-09-22', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000412705', '7509000413818', '7509000426023', '7509000427501'], array[2, 24, 4, 1], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[1], '2026-09-23', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000414921'], array[5], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000415669', '7509000417885', '7509000424173'], array[1, 1, 2, 2], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000424173', '7509000427501'], array[2, 2, 1], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[9], '2026-09-23', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000426399'], array[2], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472', '7509000428249'], array[1, 1], '2026-09-23', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000419360'], array[2], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414556', '7509000416031', '7509000428614'], array[2, 2, 2, 1], '2026-09-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000424913'], array[3, 2], '2026-09-23', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000412705'], array[3], '2026-09-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000426023', '7509000428614'], array[3, 11, 1], '2026-09-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428249'], array[1], '2026-09-24', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000417144', '7509000426399', '7509000427501'], array[2, 2, 1], '2026-09-24', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000420106'], array[1], '2026-09-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426764'], array[3, 7], '2026-09-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[2], '2026-09-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735'], array[4], '2026-09-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000415669', '7509000424173'], array[2, 3, 2], '2026-09-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418998'], array[1], '2026-09-25', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000417144', '7509000423435'], array[1, 2], '2026-09-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000417144', '7509000419360'], array[2, 1, 1], '2026-09-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000416406', '7509000427501', '7509000427877'], array[1, 3, 1, 1], '2026-09-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000426399'], array[1, 9], '2026-09-25', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000418998'], array[4], '2026-09-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[1], '2026-09-25', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000414181'], array[4], '2026-09-25', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000419360', '7509000426399'], array[1, 3], '2026-09-25', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000415669', '7509000427136'], array[3, 1], '2026-09-25', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000418257'], array[1], '2026-09-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000426764', '7509000427501'], array[1, 11, 1], '2026-09-26', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000413443', '7509000418998'], array[2, 1], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000419360'], array[1, 2], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427136'], array[2], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000415294', '7509000424173'], array[5, 2, 1], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[2], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000416031'], array[2, 1], '2026-09-26', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000415669'], array[12], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000417885', '7509000426399'], array[4, 1, 4], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913'], array[2], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000415669', '7509000428249'], array[2, 2, 1], '2026-09-26', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000413818'], array[3], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413443'], array[1, 2], '2026-09-26', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000421585'], array[1], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[2], '2026-09-26', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000414556'], array[2], '2026-09-26', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000421219', '7509000421585', '7509000426023', '7509000427501'], array[3, 6, 13, 1], '2026-09-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000427501'], array[1, 1], '2026-09-27', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000416031'], array[1], '2026-09-27', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000421219', '7509000423435'], array[1, 2], '2026-09-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000419735', '7509000424913'], array[2, 5, 2], '2026-09-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[3], '2026-09-27', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000420472', '7509000422322'], array[4, 1], '2026-09-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[1], '2026-09-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424548'], array[1], '2026-09-28', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000416772'], array[1], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000426399'], array[5, 4], '2026-09-28', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000417144', '7509000423435', '7509000426764'], array[1, 2, 4], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[2], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000421585', '7509000428249'], array[1, 1], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[3], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000426399'], array[2, 6], '2026-09-28', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000419735'], array[5], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414921', '7509000425286'], array[4, 1, 1], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[2], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885', '7509000419735', '7509000426399'], array[2, 4, 1], '2026-09-28', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000412705', '7509000414921', '7509000424173'], array[3, 3, 2], '2026-09-28', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000427877'], array[1], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000419360', '7509000426023'], array[2, 2, 16], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735', '7509000420472'], array[3, 2], '2026-09-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360', '7509000419735'], array[1, 4], '2026-09-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000416772', '7509000427877', '7509000428249'], array[1, 2, 1, 1], '2026-09-29', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000414181'], array[2], '2026-09-29', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000414556', '7509000419735'], array[3, 4], '2026-09-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000416031'], array[1, 2], '2026-09-29', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000412705', '7509000416772'], array[3, 1], '2026-09-29', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000419735'], array[1], '2026-09-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[8], '2026-09-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[2], '2026-09-29', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000428614'], array[1], '2026-09-29', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000426399'], array[1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443'], array[1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426764'], array[1], '2026-09-30', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413443'], array[4], '2026-09-30', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000428980'], array[1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399', '7509000428614'], array[1, 1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000415669', '7509000424173', '7509000426764'], array[2, 3, 2, 2], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000421585'], array[3, 1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360'], array[1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000418257', '7509000428614'], array[6, 1, 1], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000414921', '7509000424913'], array[2, 2, 2], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000426399'], array[6, 4], '2026-09-30', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000426023'], array[4], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772', '7509000417144', '7509000426399'], array[1, 2, 4], '2026-09-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885'], array[2], '2026-10-01', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000427877'], array[1], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000417144', '7509000419735'], array[3, 1, 4], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000421585', '7509000428980'], array[1, 1, 1], '2026-10-01', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000420106'], array[1], '2026-10-01', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000426023'], array[5], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423800'], array[2], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[9], '2026-10-01', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000414181'], array[1], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000426764'], array[4, 3], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428249'], array[1], '2026-10-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000419360'], array[3, 1], '2026-10-01', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000414556'], array[2], '2026-10-01', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000412705'], array[6], '2026-10-01', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000425651'], array[1], '2026-10-02', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000417144'], array[2], '2026-10-02', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[3], '2026-10-02', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000426023'], array[10], '2026-10-02', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000416031', '7509000417144', '7509000423435', '7509000426764'], array[1, 2, 1, 7], '2026-10-02', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000420106', '7509000426399'], array[1, 8], '2026-10-02', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[5], '2026-10-02', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000414556', '7509000419735', '7509000426023'], array[3, 1, 22], '2026-10-02', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000413078', '7509000425651'], array[2, 1], '2026-10-02', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000416031', '7509000427136', '7509000427877'], array[1, 7, 1], '2026-10-02', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000416772', '7509000420106', '7509000420472'], array[1, 2, 2], '2026-10-02', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000417519'], array[1], '2026-10-03', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000412705', '7509000415294', '7509000418622', '7509000423800'], array[1, 2, 1, 2], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000416406', '7509000418257', '7509000427136'], array[1, 1, 1, 4], '2026-10-03', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000414921'], array[1], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360'], array[2], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322', '7509000426023', '7509000428614'], array[1, 10, 1], '2026-10-03', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000416406', '7509000426399', '7509000427501'], array[2, 6, 1], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772'], array[2], '2026-10-03', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000414921', '7509000424173'], array[12, 1], '2026-10-03', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000424548'], array[1], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417519', '7509000421585'], array[1, 1], '2026-10-03', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000413078', '7509000413818', '7509000420847'], array[1, 1, 1], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000420472', '7509000423435'], array[1, 2, 2], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000414181'], array[2, 4], '2026-10-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000417144', '7509000418622'], array[3, 1, 1], '2026-10-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106', '7509000428249'], array[1, 1], '2026-10-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000426023'], array[3, 11], '2026-10-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000419735'], array[1, 5], '2026-10-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472', '7509000422322', '7509000426023', '7509000428249'], array[2, 1, 2, 1], '2026-10-05', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000414181'], array[3], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000423435'], array[1, 2], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425286'], array[1], '2026-10-05', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000420106'], array[2], '2026-10-05', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000414181', '7509000418622'], array[3, 1], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[1], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[2], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[3], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000417885', '7509000427501'], array[2, 2, 1], '2026-10-05', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000420106', '7509000425286', '7509000427501'], array[1, 1, 1], '2026-10-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000426764'], array[2, 4], '2026-10-05', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000417144', '7509000418257'], array[5, 4], '2026-10-06', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000412705'], array[6], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000426023'], array[3, 5], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435'], array[2], '2026-10-06', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000416406'], array[1], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[1], '2026-10-06', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000414556', '7509000417144', '7509000426023'], array[1, 2, 1], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[4], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427877'], array[1], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000413818', '7509000418622', '7509000426399'], array[3, 5, 1, 2], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885'], array[2], '2026-10-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[2], '2026-10-07', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413078', '7509000414556', '7509000425651'], array[15, 4, 1], '2026-10-07', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000416406', '7509000417519', '7509000423800'], array[3, 1, 1], '2026-10-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[7], '2026-10-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000423800'], array[4, 1], '2026-10-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000423800'], array[3, 2], '2026-10-07', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000413078', '7509000427501'], array[2, 1], '2026-10-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[4], '2026-10-07', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000420106'], array[6], '2026-10-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[2], '2026-10-07', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000413818', '7509000414921', '7509000419735', '7509000427501'], array[4, 5, 1, 1], '2026-10-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[4], '2026-10-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000418998', '7509000419735', '7509000427501'], array[2, 1, 3, 1], '2026-10-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000426399'], array[3, 10], '2026-10-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-10-08', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000414181', '7509000426764'], array[5, 5], '2026-10-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000427136'], array[2, 1], '2026-10-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000417144', '7509000426023', '7509000426399'], array[1, 2, 6, 8], '2026-10-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360', '7509000426764'], array[2, 13], '2026-10-08', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000420472', '7509000421219', '7509000428614'], array[1, 1, 1], '2026-10-08', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000427501'], array[1], '2026-10-08', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000420106'], array[1], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735'], array[4], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144', '7509000417519', '7509000423800'], array[1, 1, 1], '2026-10-09', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000426399'], array[3], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000419360'], array[3, 2], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000413818', '7509000422698'], array[2, 4, 1], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[1], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000419735', '7509000428249'], array[1, 1, 1], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443'], array[2], '2026-10-09', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000426023'], array[4], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[3], '2026-10-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360', '7509000419735'], array[1, 4], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418998'], array[1], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-10-10', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000412705', '7509000414921'], array[3, 2], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913', '7509000426764'], array[1, 5], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[4], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705'], array[2], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000427877'], array[1, 1], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[4], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000419735', '7509000425651'], array[4, 1, 1], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[5], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000425651'], array[3, 1], '2026-10-10', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000414181'], array[4], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622'], array[1], '2026-10-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885', '7509000419735'], array[1, 2], '2026-10-11', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000418622'], array[2], '2026-10-11', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000415294', '7509000420472'], array[2, 2], '2026-10-11', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000413078', '7509000413443', '7509000425651'], array[2, 1, 1], '2026-10-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735'], array[5], '2026-10-11', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000413078'], array[1], '2026-10-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106', '7509000425651'], array[2, 1], '2026-10-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417519'], array[1], '2026-10-11', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000414921'], array[5], '2026-10-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144', '7509000424173'], array[1, 2], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000426764'], array[5, 4], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000419735'], array[2, 4], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000416031'], array[3, 2], '2026-10-12', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000419735'], array[12], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[2], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000428614'], array[6, 1], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000424548'], array[3, 1], '2026-10-12', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000419360'], array[2], '2026-10-12', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000426023'], array[2], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000425651'], array[1, 1], '2026-10-12', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000416406'], array[3], '2026-10-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000414181'], array[2, 5], '2026-10-13', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000416031'], array[1], '2026-10-13', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000423435', '7509000423800', '7509000424548'], array[2, 2, 1], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144', '7509000420472'], array[2, 1], '2026-10-13', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000417144', '7509000425286'], array[2, 1], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000415669'], array[3, 2], '2026-10-13', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000427501'], array[1], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[3], '2026-10-13', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000413818', '7509000414181', '7509000427501', '7509000427877'], array[3, 5, 1, 1], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000418622', '7509000422322'], array[2, 1, 1], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885'], array[2], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705'], array[3], '2026-10-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322'], array[1], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360', '7509000420847'], array[1, 1], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427877'], array[1], '2026-10-14', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000421219'], array[1], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427877'], array[1], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000426023'], array[3, 8], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322', '7509000424548'], array[1, 1], '2026-10-14', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000413078', '7509000426764'], array[1, 2], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735'], array[1], '2026-10-14', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000414181', '7509000426764'], array[1, 15], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-10-14', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413078', '7509000415669', '7509000416031', '7509000419360'], array[9, 12, 8, 6], '2026-10-14', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000416406'], array[2, 1], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425286'], array[1], '2026-10-15', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000415294', '7509000418622', '7509000420106', '7509000426023'], array[2, 1, 1, 13], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772', '7509000426023'], array[1, 6], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322', '7509000428249'], array[1, 1], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[2], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000419735'], array[3, 2], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000415669', '7509000416772', '7509000420472'], array[1, 3, 1, 1], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257'], array[1], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417519', '7509000423435'], array[1, 1], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000413443', '7509000419735', '7509000426023'], array[3, 2, 3, 10], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031'], array[2], '2026-10-15', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-10-15', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000416406', '7509000418257', '7509000425651'], array[3, 1, 1], '2026-10-16', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000415294', '7509000426023'], array[3, 13], '2026-10-16', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000415294'], array[3], '2026-10-16', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000417144'], array[1, 2], '2026-10-16', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000412705', '7509000427501'], array[1, 1], '2026-10-16', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428249'], array[1], '2026-10-16', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000415294', '7509000417144'], array[3, 2], '2026-10-16', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000414556', '7509000416406', '7509000428614'], array[2, 3, 1], '2026-10-16', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000420472', '7509000426399'], array[1, 1], '2026-10-16', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435'], array[1], '2026-10-17', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000419360', '7509000424548', '7509000425286'], array[2, 1, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414556', '7509000415669'], array[2, 3, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000426023'], array[8], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000419360', '7509000425651'], array[2, 2, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[1], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000422698', '7509000423800'], array[2, 1, 2], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[1], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000415669', '7509000424173'], array[3, 1, 2], '2026-10-17', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000418257', '7509000427877'], array[1, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414181', '7509000418998', '7509000424548', '7509000425286'], array[9, 6, 1, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423800'], array[2], '2026-10-17', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000424173'], array[2], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322'], array[1], '2026-10-17', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000414181', '7509000414921', '7509000424173'], array[18, 6, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000413443', '7509000427501'], array[1, 1], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000423435'], array[2, 2], '2026-10-17', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[1], '2026-10-18', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000426023'], array[7], '2026-10-18', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000413443'], array[1], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000424173'], array[2, 2], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[2], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000420106', '7509000425286'], array[1, 2, 1], '2026-10-19', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000414556'], array[4], '2026-10-19', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000426764'], array[12], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000416406', '7509000419360', '7509000427877'], array[4, 3, 1, 1], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322', '7509000425286'], array[1, 1], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420847'], array[1], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472', '7509000423435'], array[2, 1], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000414181'], array[1, 4], '2026-10-19', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422698', '7509000427501'], array[1, 1], '2026-10-20', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000413818', '7509000414181', '7509000426023', '7509000426399'], array[12, 12, 8, 4], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735', '7509000422698'], array[4, 1], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000418257', '7509000427877'], array[4, 1, 1], '2026-10-20', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000413818'], array[1], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472', '7509000427136'], array[2, 2], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[2], '2026-10-20', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000417144', '7509000426023'], array[2, 3], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000423435'], array[5, 2], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000418257'], array[1, 1], '2026-10-20', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000417519', '7509000428249'], array[2, 1, 1], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000426399', '7509000426764'], array[1, 1, 7], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000416406', '7509000419360'], array[2, 1, 1], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426764'], array[3], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472', '7509000426399', '7509000426764'], array[1, 3, 16], '2026-10-21', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000414181', '7509000417885', '7509000424173', '7509000426023'], array[4, 1, 1, 8], '2026-10-21', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000413078', '7509000424173', '7509000426399'], array[3, 1, 1], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435'], array[2], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000418998', '7509000419360', '7509000419735'], array[1, 1, 2, 1], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[3], '2026-10-21', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418998'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427877'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423435'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399', '7509000427877'], array[10, 1], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000422322'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000423800'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000423800'], array[2, 2], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419360'], array[1], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000415294', '7509000420106', '7509000426764'], array[1, 1, 2, 2], '2026-10-22', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000418998', '7509000419360'], array[1, 1, 1], '2026-10-22', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000413078', '7509000414181', '7509000415294'], array[2, 4, 3], '2026-10-22', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000426023', '7509000428614'], array[8, 1], '2026-10-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000423800'], array[2, 1], '2026-10-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000420106', '7509000426399'], array[1, 1, 2], '2026-10-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000427501'], array[5, 1], '2026-10-23', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000417519'], array[2], '2026-10-23', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000413443', '7509000416031'], array[1, 1], '2026-10-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257', '7509000426399'], array[1, 3], '2026-10-23', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000413443', '7509000424913'], array[1, 1], '2026-10-23', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000420472', '7509000426023', '7509000427877'], array[4, 15, 1], '2026-10-23', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000413078', '7509000414921'], array[1, 6], '2026-10-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322', '7509000426023'], array[1, 10], '2026-10-23', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000413078', '7509000417144', '7509000427136'], array[3, 1, 6], '2026-10-23', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413443'], array[1, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000418257', '7509000428249', '7509000428614'], array[1, 1, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000427136'], array[3, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000413443', '7509000414181', '7509000417885'], array[2, 1, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000414181'], array[4], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000421219'], array[1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472'], array[1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[6], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000418257', '7509000427501', '7509000428249'], array[4, 1, 1, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000417144', '7509000417885', '7509000428614'], array[3, 5, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000421219'], array[1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000417519'], array[1, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000416406', '7509000417144'], array[2, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000415294', '7509000419360'], array[2, 2, 2], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000421585', '7509000426023'], array[1, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078'], array[1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426764', '7509000428249'], array[7, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705'], array[3], '2026-10-24', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000413443', '7509000418998'], array[2, 1], '2026-10-24', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000414181'], array[3, 3], '2026-10-25', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000416406', '7509000419735', '7509000426764'], array[2, 3, 4], '2026-10-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000419735'], array[2, 5], '2026-10-25', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257'], array[1], '2026-10-25', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000418998'], array[1], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651', '7509000427501'], array[1, 1], '2026-10-26', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000416406', '7509000419735'], array[3, 4], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[1], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257', '7509000419735', '7509000427501', '7509000428249'], array[1, 2, 1, 1], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000420472'], array[1, 2], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000427136'], array[1, 4], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000426023', '7509000427877'], array[3, 4, 1], '2026-10-26', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000412705', '7509000416406', '7509000426764'], array[2, 1, 12], '2026-10-26', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000423800'], array[1], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000420472', '7509000422698'], array[6, 1, 1], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144', '7509000419735', '7509000427136'], array[2, 4, 1], '2026-10-26', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000422322'], array[2, 1], '2026-10-27', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000413443', '7509000422322', '7509000425651'], array[1, 1, 1], '2026-10-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000423435'], array[3, 1], '2026-10-27', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000426023'], array[8], '2026-10-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[3], '2026-10-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443'], array[1], '2026-10-27', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000413443', '7509000418998', '7509000427877'], array[1, 1, 1], '2026-10-27', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000417885'], array[10], '2026-10-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622', '7509000426023', '7509000427877'], array[1, 5, 1], '2026-10-27', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000428614'], array[1], '2026-10-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424548'], array[1], '2026-10-27', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000414921', '7509000427501'], array[2, 1, 1], '2026-10-28', v); commit;
  call sp_registrar_venta('CUER9903060MS', array['7509000420472'], array[2], '2026-10-28', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000416031', '7509000417885', '7509000426764'], array[1, 1, 4], '2026-10-28', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000413443', '7509000427136'], array[2, 8], '2026-10-28', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000413078'], array[2], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000418998'], array[3, 1], '2026-10-28', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000415294'], array[2], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031'], array[1], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424173', '7509000428249'], array[2, 1], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[3], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000420847', '7509000424548', '7509000428614'], array[4, 1, 1, 1], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294', '7509000416406'], array[1, 2], '2026-10-28', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414921', '7509000421585', '7509000422698'], array[3, 4, 1], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000428249'], array[1, 1], '2026-10-28', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000415294', '7509000427501'], array[1, 3, 1], '2026-10-29', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000418998', '7509000427877'], array[1, 1], '2026-10-29', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000418257', '7509000426023'], array[1, 8], '2026-10-29', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000414181', '7509000425286'], array[4, 1], '2026-10-29', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000417144'], array[10], '2026-10-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426764'], array[5, 2], '2026-10-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413818', '7509000419360', '7509000423800'], array[2, 1, 1, 1], '2026-10-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[2], '2026-10-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000423435', '7509000426764'], array[3, 1, 5], '2026-10-29', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000416031', '7509000424173'], array[6, 1], '2026-10-29', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000414921', '7509000426399'], array[5, 2], '2026-10-29', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000423800'], array[2], '2026-10-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735', '7509000420106', '7509000424913'], array[5, 1, 2], '2026-10-29', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000416772', '7509000422698'], array[1, 2, 1], '2026-10-30', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000415294'], array[5], '2026-10-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[4], '2026-10-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818'], array[4], '2026-10-30', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000418622'], array[4], '2026-10-30', v); commit;
  call sp_registrar_venta('RODA830927YZM', array['7509000420106', '7509000426764'], array[1, 8], '2026-10-30', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000414921', '7509000422322'], array[6, 1], '2026-10-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078'], array[3], '2026-10-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426764'], array[5, 1], '2026-10-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413443', '7509000425651'], array[2, 1], '2026-10-30', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000426399'], array[4], '2026-10-30', v); commit;
  call sp_registrar_venta('HERL82091968J', array['7509000413818'], array[3], '2026-10-30', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705'], array[2], '2026-10-30', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000414921'], array[6], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418622'], array[1], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000428614'], array[3, 1], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000416031'], array[2, 1], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913'], array[2], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000414181', '7509000424913', '7509000428249'], array[4, 2, 2, 1], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[2], '2026-10-31', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000425651', '7509000426764', '7509000428614'], array[1, 10, 1], '2026-10-31', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000420472', '7509000421585'], array[1, 1], '2026-10-31', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000416031', '7509000419735', '7509000423435'], array[12, 10, 1], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418998', '7509000421585', '7509000426023'], array[1, 1, 5], '2026-10-31', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000415294'], array[3, 3], '2026-10-31', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000413443'], array[12], '2026-11-01', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000426399', '7509000427136'], array[3, 2], '2026-11-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-11-01', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000414181', '7509000414921', '7509000424548', '7509000426023'], array[4, 1, 1, 18], '2026-11-01', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000414556'], array[3], '2026-11-01', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000424913', '7509000426023'], array[1, 20], '2026-11-01', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-11-02', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000414921'], array[4], '2026-11-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000419735', '7509000425651'], array[5, 5, 1], '2026-11-03', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000412705', '7509000417144'], array[1, 1], '2026-11-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000426764'], array[5, 30], '2026-11-03', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000413443', '7509000416031', '7509000424913', '7509000427501'], array[2, 2, 2, 1], '2026-11-03', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000424913'], array[2], '2026-11-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000418622'], array[2, 1], '2026-11-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000419735', '7509000426764', '7509000427877'], array[4, 2, 16, 1], '2026-11-03', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000426764'], array[2, 10], '2026-11-03', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414556', '7509000415294', '7509000415669'], array[12, 8, 3], '2026-11-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000416406', '7509000420106', '7509000425651'], array[5, 2, 2, 1], '2026-11-04', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000420847'], array[1], '2026-11-04', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000420472', '7509000427501'], array[10, 1], '2026-11-04', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000418622'], array[1], '2026-11-04', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000416406', '7509000423435'], array[2, 1], '2026-11-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000421219', '7509000425651', '7509000428980'], array[1, 1, 1, 1], '2026-11-04', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000417885'], array[2], '2026-11-04', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[1], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000416772'], array[4, 1], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000417144'], array[3, 2], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000418257', '7509000428614'], array[1, 1], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000414556', '7509000423435'], array[3, 3, 2], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000427136'], array[1, 1], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416772'], array[1], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181'], array[5], '2026-11-05', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426023'], array[5, 4], '2026-11-05', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000420472', '7509000427877'], array[1, 1], '2026-11-05', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000414181', '7509000414921'], array[1, 4], '2026-11-06', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000413818'], array[4], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406', '7509000417144', '7509000427501'], array[3, 1, 1], '2026-11-06', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000413818'], array[2], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[1], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417519', '7509000418257', '7509000423435'], array[1, 1, 1], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000419360', '7509000428614'], array[5, 2, 1], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415294'], array[1], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000416031', '7509000419360', '7509000427136'], array[3, 1, 2, 3], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031'], array[2], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426023'], array[3], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913'], array[1], '2026-11-06', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413078', '7509000419360'], array[3, 3, 2], '2026-11-06', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000427136'], array[1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426399'], array[4, 1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921', '7509000426023'], array[1, 9], '2026-11-07', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000413078', '7509000426399'], array[3, 2], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414921'], array[5], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651'], array[1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420472', '7509000426764'], array[1, 3], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000420106', '7509000423435', '7509000428614'], array[1, 1, 2, 1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705'], array[2], '2026-11-07', v); commit;
  call sp_registrar_venta('MELJ930627M52', array['7509000419735', '7509000427136'], array[1, 1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000420472', '7509000427501'], array[1, 1, 1], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[3], '2026-11-07', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422698'], array[1], '2026-11-08', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414556', '7509000415294', '7509000418622', '7509000420847'], array[10, 10, 6, 2], '2026-11-08', v); commit;
  call sp_registrar_venta('NUGR020606V69', array['7509000421585'], array[1], '2026-11-08', v); commit;
  call sp_registrar_venta('VAPL891022NB0', array['7509000421219'], array[1], '2026-11-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427877'], array[1], '2026-11-08', v); commit;
  call sp_registrar_venta('RECE860215WKD', array['7509000426023'], array[17], '2026-11-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000415294', '7509000420847', '7509000428980'], array[3, 1, 1, 1], '2026-11-08', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[2], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000425651'], array[1], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426764'], array[24], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078', '7509000428249'], array[1, 1], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[2], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416406'], array[3], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000416031', '7509000426023'], array[1, 10], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417144'], array[2], '2026-11-09', v); commit;
  call sp_registrar_venta('MOVF760314683', array['7509000419735', '7509000426764', '7509000427501'], array[3, 20, 1], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426764'], array[13], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106'], array[2], '2026-11-09', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-11-09', v); commit;
  call sp_registrar_venta('SICH840623CVA', array['7509000427501'], array[1], '2026-11-09', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000413818', '7509000414556', '7509000415669'], array[5, 1, 3], '2026-11-10', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000412705', '7509000413818', '7509000420472'], array[1, 3, 1], '2026-11-10', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000416772', '7509000426023'], array[1, 9], '2026-11-10', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000412705'], array[1], '2026-11-10', v); commit;
  call sp_registrar_venta('PAXD930507VCS', array['7509000423435', '7509000428614'], array[1, 1], '2026-11-10', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000412705', '7509000423800'], array[6, 2], '2026-11-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078'], array[1], '2026-11-10', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000414921', '7509000426399', '7509000426764'], array[2, 2, 10], '2026-11-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669', '7509000418998', '7509000426399'], array[2, 1, 3], '2026-11-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413818', '7509000426399', '7509000427877'], array[4, 1, 1], '2026-11-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000423800'], array[2], '2026-11-10', v); commit;
  call sp_registrar_venta('CAAX0012175R4', array['7509000414181'], array[5], '2026-11-10', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422322'], array[1], '2026-11-10', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000416772', '7509000427877'], array[2, 1], '2026-11-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000421585'], array[1], '2026-11-11', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000416031'], array[1], '2026-11-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000413443', '7509000427501'], array[3, 2, 1], '2026-11-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000427501'], array[1], '2026-11-11', v); commit;
  call sp_registrar_venta('DEIM990815V6U', array['7509000427136'], array[2], '2026-11-11', v); commit;
  call sp_registrar_venta('GUNR010810MK0', array['7509000413078', '7509000414181', '7509000416772'], array[2, 5, 1], '2026-11-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399', '7509000426764', '7509000427877'], array[2, 21, 1], '2026-11-11', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414181', '7509000414921', '7509000426023'], array[5, 10, 6], '2026-11-11', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000422698'], array[1], '2026-11-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414181', '7509000416031', '7509000427877'], array[1, 1, 1], '2026-11-11', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000424913', '7509000428980'], array[1, 1], '2026-11-11', v); commit;
  call sp_registrar_venta('FOOV020406HZ9', array['7509000425651', '7509000426023'], array[1, 2], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556', '7509000420106', '7509000426764', '7509000427877'], array[3, 1, 24, 1], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428249'], array[1], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000419735', '7509000423435', '7509000426764'], array[1, 2, 6], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422698'], array[1], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000414556'], array[1], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000428980'], array[1], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000412705', '7509000419360', '7509000426023', '7509000427501'], array[3, 2, 3, 1], '2026-11-12', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000420106', '7509000422322'], array[1, 1], '2026-11-12', v); commit;
  call sp_registrar_venta('CAMP911028TT4', array['7509000419360', '7509000424173', '7509000426764'], array[2, 1, 9], '2026-11-12', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000414181'], array[25], '2026-11-12', v); commit;
  call sp_registrar_venta('JIRC9406269P7', array['7509000414556', '7509000414921'], array[3, 6], '2026-11-13', v); commit;
  call sp_registrar_venta('LUHS930112Z2T', array['7509000412705', '7509000413818', '7509000415294'], array[3, 5, 2], '2026-11-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000417885'], array[1], '2026-11-13', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000427877'], array[1], '2026-11-13', v); commit;
  call sp_registrar_venta('CMS100215AB3', array['7509000425651'], array[1], '2026-11-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000422698'], array[1], '2026-11-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000413078'], array[3], '2026-11-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000426399'], array[10], '2026-11-13', v); commit;
  call sp_registrar_venta('RACD030628N16', array['7509000415294', '7509000426023'], array[3, 6], '2026-11-13', v); commit;
  call sp_registrar_venta('DCR180903K27', array['7509000414921', '7509000426764'], array[20, 30], '2026-11-13', v); commit;
  call sp_registrar_venta('SAFO960814HHR', array['7509000412705', '7509000413078', '7509000424173', '7509000427501'], array[3, 3, 2, 1], '2026-11-13', v); commit;
  call sp_registrar_venta('XAXX010101000', array['7509000415669'], array[3], '2026-11-13', v); commit;
  call sp_registrar_venta('TOSA75072701T', array['7509000414556'], array[1], '2026-11-13', v); commit;
end;
$$;

-- actualiza las estadísticas que usa el optimizador después de la carga
analyze;
