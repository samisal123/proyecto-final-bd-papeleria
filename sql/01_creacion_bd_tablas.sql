-- =============================================================================
-- Proyecto final de Bases de Datos 2027-1
-- Sistema de información para una cadena de papelerías
-- Script 01: creación de la base de datos, tablas, secuencia e índices
--
-- Ejecutar conectado a la base "postgres" con un usuario que pueda crear bases:
--   psql -U postgres -f 01_creacion_bd_tablas.sql
-- En servicios en la nube (Neon, Supabase, etc.) la base ya viene creada: se
-- conecta uno directamente a ella y se ejecuta a partir de la sección 2.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Base de datos
-- -----------------------------------------------------------------------------
drop database if exists papeleria;

create database papeleria
  with encoding = 'UTF8'
       template = template0;

comment on database papeleria is 'Sistema de ventas e inventario de la cadena de papelerías';

\connect papeleria

-- -----------------------------------------------------------------------------
-- 2. Tablas
-- -----------------------------------------------------------------------------
set client_min_messages = warning;

drop table if exists detalle_venta, venta, email_cliente, cliente,
                     producto, telefono_proveedor, proveedor, codigo_postal cascade;
drop sequence if exists seq_num_venta;

-- -----------------------------------------------------------------------------
-- Catálogo de códigos postales
-- Sale de la normalización del domicilio: el código postal determina el estado
-- (cp -> estado). Si el estado se guardara en cada domicilio habría una
-- dependencia transitiva y se rompería la 3FN.
-- -----------------------------------------------------------------------------
create table codigo_postal(
  cp      char(5)     not null,
  estado  varchar(40) not null,
  constraint pk_codigo_postal primary key (cp),
  constraint chk_codigo_postal_cp check (cp ~ '^[0-9]{5}$')
);

-- -----------------------------------------------------------------------------
-- Proveedores
-- -----------------------------------------------------------------------------
create table proveedor(
  id_proveedor  int          generated always as identity,
  razon_social  varchar(120) not null,
  nombre        varchar(80)  not null,
  cp            char(5)      not null,
  colonia       varchar(60)  not null,
  calle         varchar(80)  not null,
  numero        varchar(10)  not null,
  constraint pk_proveedor primary key (id_proveedor),
  constraint uq_proveedor_razon_social unique (razon_social),
  constraint fk_proveedor_cp foreign key (cp) references codigo_postal(cp)
    on update cascade on delete restrict
);

-- Atributo multivaluado: un proveedor puede tener varios teléfonos
create table telefono_proveedor(
  id_proveedor  int         not null,
  telefono      varchar(10) not null,
  constraint pk_telefono_proveedor primary key (id_proveedor, telefono),
  constraint fk_telefono_proveedor foreign key (id_proveedor) references proveedor(id_proveedor)
    on update cascade on delete cascade,
  constraint chk_telefono_proveedor check (telefono ~ '^[0-9]{10}$')
);

-- -----------------------------------------------------------------------------
-- Clientes
-- El RFC mide 13 caracteres en personas físicas y 12 en personas morales.
-- Para ventas al público en general se usa el RFC genérico XAXX010101000.
-- -----------------------------------------------------------------------------
create table cliente(
  rfc          varchar(13) not null,
  nombre       varchar(80) not null,
  ap_paterno   varchar(50) null,
  ap_materno   varchar(50) null,
  cp           char(5)     not null,
  colonia      varchar(60) not null,
  calle        varchar(80) not null,
  numero       varchar(10) not null,
  constraint pk_cliente primary key (rfc),
  constraint chk_cliente_rfc check (rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$'),
  constraint fk_cliente_cp foreign key (cp) references codigo_postal(cp)
    on update cascade on delete restrict
);

-- Atributo multivaluado: un cliente tiene al menos un email
-- (la regla de "al menos uno" se valida con un trigger diferido en el script 02)
create table email_cliente(
  rfc    varchar(13)  not null,
  email  varchar(100) not null,
  constraint pk_email_cliente primary key (rfc, email),
  constraint fk_email_cliente foreign key (rfc) references cliente(rfc)
    on update cascade on delete cascade,
  constraint chk_email_cliente check (email ~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$')
);

-- -----------------------------------------------------------------------------
-- Productos (inventario)
-- Jerarquía PRODUCTO -> {REGALO, PAPELERIA, IMPRESION, RECARGA}, disjunta y total.
-- Como los subtipos no tienen atributos propios, se transformó a una sola
-- relación con el atributo discriminante "tipo".
-- precio_venta: precio al público; precio_compra: precio al que se compró.
-- foto: ruta o URL de la imagen del producto.
-- -----------------------------------------------------------------------------
create table producto(
  codigo_barras  varchar(13)   not null,
  nombre         varchar(60)   not null,
  marca          varchar(40)   not null,
  descripcion    varchar(150)  not null,
  tipo           varchar(10)   not null,
  precio_venta   numeric(10,2) not null,
  precio_compra  numeric(10,2) not null,
  foto           varchar(200)  not null,
  fecha_compra   date          not null default current_date,
  stock          int           not null default 0,
  id_proveedor   int           not null,
  constraint pk_producto primary key (codigo_barras),
  constraint chk_producto_codigo check (codigo_barras ~ '^[0-9]{8,13}$'),
  constraint chk_producto_tipo check (tipo in ('REGALO', 'PAPELERIA', 'IMPRESION', 'RECARGA')),
  constraint chk_producto_precio_compra check (precio_compra > 0),
  constraint chk_producto_precio_venta check (precio_venta >= precio_compra),
  constraint chk_producto_stock check (stock >= 0),
  constraint fk_producto_proveedor foreign key (id_proveedor) references proveedor(id_proveedor)
    on update cascade on delete restrict
);

-- -----------------------------------------------------------------------------
-- Ventas
-- num_venta tiene el formato VENT-001; el valor lo genera la función
-- fn_nuevo_num_venta() (script 02) a partir de la secuencia seq_num_venta.
-- total_venta es calculado (C) y lo mantienen los triggers de detalle_venta.
-- -----------------------------------------------------------------------------
create sequence seq_num_venta
  as int
  start with 1
  increment by 1
  minvalue 1
  no cycle;

create table venta(
  num_venta    varchar(12)   not null,
  fecha_venta  date          not null default current_date,
  total_venta  numeric(12,2) not null default 0,
  rfc_cliente  varchar(13)   not null,
  constraint pk_venta primary key (num_venta),
  constraint chk_venta_num check (num_venta ~ '^VENT-[0-9]{3,}$'),
  constraint chk_venta_total check (total_venta >= 0),
  constraint fk_venta_cliente foreign key (rfc_cliente) references cliente(rfc)
    on update cascade on delete restrict
);

alter sequence seq_num_venta owned by venta.num_venta;

-- -----------------------------------------------------------------------------
-- Detalle de cada venta (relación M:M entre venta y producto)
-- precio_unitario y costo_unitario guardan los precios vigentes al momento de
-- la venta (atributos con histórico): si después cambia el precio del producto,
-- las ventas pasadas conservan su importe y su ganancia reales.
-- total_articulo es calculado (C) = cantidad * precio_unitario.
-- -----------------------------------------------------------------------------
create table detalle_venta(
  num_venta        varchar(12)   not null,
  codigo_barras    varchar(13)   not null,
  cantidad         int           not null,
  precio_unitario  numeric(10,2) not null,
  costo_unitario   numeric(10,2) not null,
  total_articulo   numeric(12,2) not null,
  constraint pk_detalle_venta primary key (num_venta, codigo_barras),
  constraint chk_detalle_cantidad check (cantidad > 0),
  constraint fk_detalle_venta foreign key (num_venta) references venta(num_venta)
    on update cascade on delete cascade,
  constraint fk_detalle_producto foreign key (codigo_barras) references producto(codigo_barras)
    on update cascade on delete restrict
);

-- -----------------------------------------------------------------------------
-- Índice idx_venta_fecha (B-tree sobre venta.fecha_venta)
-- Las consultas por fecha o por periodo (fn_ventas_periodo, v_ventas_por_dia y
-- el dashboard) filtran por rangos de fechas. Un B-tree guarda las llaves
-- ordenadas, así que resuelve "=" y "between" sin recorrer toda la tabla, y
-- venta es la tabla que más crece.
-- -----------------------------------------------------------------------------
create index idx_venta_fecha on venta using btree (fecha_venta);

-- -----------------------------------------------------------------------------
-- Comentarios del diccionario de datos
-- -----------------------------------------------------------------------------
comment on table codigo_postal is 'Catálogo de códigos postales y el estado al que pertenecen';
comment on table proveedor is 'Proveedores de la cadena de papelerías';
comment on table telefono_proveedor is 'Teléfonos de cada proveedor (atributo multivaluado)';
comment on table cliente is 'Clientes; el RFC XAXX010101000 representa al público en general';
comment on table email_cliente is 'Correos de cada cliente (atributo multivaluado, al menos uno)';
comment on table producto is 'Inventario de productos: regalos, papelería, impresiones y recargas';
comment on table venta is 'Encabezado de cada venta';
comment on table detalle_venta is 'Artículos vendidos en cada venta';
comment on column producto.tipo is 'Discriminante de la jerarquía: REGALO, PAPELERIA, IMPRESION o RECARGA';
comment on column producto.stock is 'Ejemplares en bodega';
comment on column venta.total_venta is 'Calculado: suma de detalle_venta.total_articulo';
comment on column detalle_venta.precio_unitario is 'Precio de venta vigente al momento de la venta';
comment on column detalle_venta.costo_unitario is 'Precio de compra vigente al momento de la venta';
comment on column detalle_venta.total_articulo is 'Calculado: cantidad * precio_unitario';
