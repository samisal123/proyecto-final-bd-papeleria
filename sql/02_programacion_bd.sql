-- =============================================================================
-- Proyecto final de Bases de Datos 2027-1
-- Sistema de información para una cadena de papelerías
-- Script 02: programación a nivel base de datos (PL/pgSQL)
--
-- Contenido
--   1. Número de venta con formato VENT-001
--   2. Triggers del detalle de venta: stock, precios, totales y alerta
--   3. Reglas de consistencia (triggers diferidos)
--   4. Procedimiento para registrar una venta
--   5. Funciones de consulta: ventas por periodo y utilidad
--   6. Vistas: factura, ventas por día, top 10 y productos con stock bajo
--   7. Rol de solo lectura para el dashboard (DCL)
--
-- Ejecutar conectado a la base papeleria, después del script 01:
--   psql -U postgres -d papeleria -f 02_programacion_bd.sql
-- =============================================================================

set client_min_messages = warning;

-- =============================================================================
-- 1. Número de venta
-- =============================================================================

-- Toma el siguiente valor de la secuencia y le da formato:
-- 1 -> VENT-001, 25 -> VENT-025, 1000 -> VENT-1000 (lpad sola recortaría los
-- números de 4 cifras, por eso el ancho mínimo es 3 y crece con el número).
create or replace function fn_nuevo_num_venta()
returns varchar
language plpgsql
as $$
declare
  v_num text := nextval('seq_num_venta')::text;
begin
  return 'VENT-' || lpad(v_num, greatest(3, length(v_num)), '0');
end;
$$;

alter table venta alter column num_venta set default fn_nuevo_num_venta();

-- =============================================================================
-- 2. Triggers del detalle de venta
-- =============================================================================

-- 2.1 Antes de insertar, actualizar o borrar un artículo de una venta.
--   INSERT: bloquea el producto, valida y decrementa el stock, toma los precios
--           vigentes y calcula el total del artículo.
--   UPDATE: ajusta el stock por la diferencia de cantidad y recalcula el total
--           con el precio con el que se vendió (no con el precio actual).
--   DELETE: regresa la cantidad al stock.
-- Regla del negocio: si con la venta el stock llega a cero, se aborta la
-- transacción completa (RAISE EXCEPTION deshace todo lo hecho en ella).
create or replace function fn_tg_detalle_venta_antes()
returns trigger
language plpgsql
as $$
declare
  v_stock          producto.stock%type;
  v_precio_venta   producto.precio_venta%type;
  v_precio_compra  producto.precio_compra%type;
  v_nombre         producto.nombre%type;
  v_diferencia     int;
begin
  if tg_op = 'DELETE' then
    update producto
       set stock = stock + old.cantidad
     where codigo_barras = old.codigo_barras;
    return old;
  end if;

  if tg_op = 'UPDATE' then
    -- pg_trigger_depth() = 1 indica un UPDATE escrito directamente sobre la
    -- tabla; los cambios en cascada de las llaves foráneas sí se permiten.
    if pg_trigger_depth() = 1
       and (new.num_venta <> old.num_venta or new.codigo_barras <> old.codigo_barras) then
      raise exception 'No se puede cambiar la venta ni el producto de un artículo vendido'
        using hint = 'Elimine el artículo de la venta y agréguelo de nuevo.';
    end if;
    -- se conservan los precios con los que se hizo la venta
    new.precio_unitario := old.precio_unitario;
    new.costo_unitario  := old.costo_unitario;
    v_diferencia := new.cantidad - old.cantidad;
  else
    v_diferencia := new.cantidad;
  end if;

  if v_diferencia <> 0 then
    -- FOR UPDATE bloquea el renglón del producto hasta el fin de la transacción
    -- para que dos ventas simultáneas no lean el mismo stock
    select stock, precio_venta, precio_compra, nombre
      into v_stock, v_precio_venta, v_precio_compra, v_nombre
      from producto
     where codigo_barras = new.codigo_barras
       for update;

    if not found then
      raise exception 'El producto con código de barras % no existe', new.codigo_barras;
    end if;

    if v_diferencia > 0 and v_stock - v_diferencia <= 0 then
      raise exception 'Venta abortada: el stock de "%" (código %) llegaría a % (hay %, se piden %)',
        v_nombre, new.codigo_barras, v_stock - v_diferencia, v_stock, v_diferencia
        using hint = 'Una venta no puede dejar el stock en cero; reabastezca el producto o venda menos piezas.';
    end if;

    update producto
       set stock = stock - v_diferencia
     where codigo_barras = new.codigo_barras;
  end if;

  if tg_op = 'INSERT' then
    new.precio_unitario := v_precio_venta;
    new.costo_unitario  := v_precio_compra;
  end if;

  new.total_articulo := new.cantidad * new.precio_unitario;
  return new;
end;
$$;

drop trigger if exists tg_detalle_venta_antes on detalle_venta;
create trigger tg_detalle_venta_antes
  before insert or update or delete on detalle_venta
  for each row
  execute function fn_tg_detalle_venta_antes();

-- 2.2 Después de cualquier cambio en el detalle se recalcula el total de la
-- venta afectada como la suma de sus artículos.
create or replace function fn_tg_detalle_venta_total()
returns trigger
language plpgsql
as $$
begin
  if tg_op in ('INSERT', 'UPDATE') then
    update venta
       set total_venta = (select coalesce(sum(d.total_articulo), 0)
                            from detalle_venta d
                           where d.num_venta = new.num_venta)
     where num_venta = new.num_venta;
  end if;

  if tg_op = 'DELETE' then
    update venta
       set total_venta = (select coalesce(sum(d.total_articulo), 0)
                            from detalle_venta d
                           where d.num_venta = old.num_venta)
     where num_venta = old.num_venta;
  end if;

  return null;
end;
$$;

drop trigger if exists tg_detalle_venta_total on detalle_venta;
create trigger tg_detalle_venta_total
  after insert or update or delete on detalle_venta
  for each row
  execute function fn_tg_detalle_venta_total();

-- 2.3 Alerta de stock bajo.
-- Es un trigger de restricción DIFERIDO: se ejecuta al confirmar la
-- transacción (COMMIT), es decir, solo cuando el pedido se completó. Si la
-- venta se abortó, no se emite ninguna alerta.
create or replace function fn_tg_alerta_stock()
returns trigger
language plpgsql
as $$
declare
  v_stock   producto.stock%type;
  v_nombre  producto.nombre%type;
begin
  select stock, nombre
    into v_stock, v_nombre
    from producto
   where codigo_barras = new.codigo_barras;

  if found and v_stock < 3 then
    raise warning 'ALERTA DE STOCK: quedan % pieza(s) de "%" (código %) después de la venta %',
      v_stock, v_nombre, new.codigo_barras, new.num_venta;
  end if;

  return null;
end;
$$;

drop trigger if exists tg_alerta_stock_bajo on detalle_venta;
create constraint trigger tg_alerta_stock_bajo
  after insert or update of cantidad on detalle_venta
  deferrable initially deferred
  for each row
  execute function fn_tg_alerta_stock();

-- =============================================================================
-- 3. Reglas de consistencia
-- =============================================================================

-- 3.1 total_venta es un atributo calculado: al insertar una venta empieza en
-- cero y no se puede modificar a mano (solo lo cambian los triggers del
-- detalle). Tampoco se aceptan ventas con fecha futura.
create or replace function fn_tg_venta_consistencia()
returns trigger
language plpgsql
as $$
begin
  if new.fecha_venta > current_date then
    raise exception 'La fecha de venta (%) no puede ser posterior a hoy', new.fecha_venta;
  end if;

  if tg_op = 'INSERT' then
    new.total_venta := 0;
  elsif new.total_venta is distinct from old.total_venta and pg_trigger_depth() = 1 then
    raise exception 'total_venta es un atributo calculado y no se modifica directamente'
      using hint = 'Modifique los artículos de la venta en detalle_venta.';
  end if;

  return new;
end;
$$;

drop trigger if exists tg_venta_consistencia on venta;
create trigger tg_venta_consistencia
  before insert or update on venta
  for each row
  execute function fn_tg_venta_consistencia();

-- 3.2 Toda venta debe tener al menos un artículo (se revisa al COMMIT).
create or replace function fn_tg_venta_con_detalle()
returns trigger
language plpgsql
as $$
declare
  v_num_venta venta.num_venta%type;
begin
  if tg_table_name = 'venta' then
    v_num_venta := new.num_venta;
  else
    v_num_venta := old.num_venta;
  end if;

  -- si la venta completa se borró, no hay nada que revisar
  if exists (select 1 from venta where num_venta = v_num_venta)
     and not exists (select 1 from detalle_venta where num_venta = v_num_venta) then
    raise exception 'La venta % no tiene artículos; toda venta debe incluir al menos uno', v_num_venta;
  end if;

  return null;
end;
$$;

drop trigger if exists tg_venta_con_detalle on venta;
create constraint trigger tg_venta_con_detalle
  after insert on venta
  deferrable initially deferred
  for each row
  execute function fn_tg_venta_con_detalle();

drop trigger if exists tg_detalle_venta_minimo on detalle_venta;
create constraint trigger tg_detalle_venta_minimo
  after delete or update on detalle_venta
  deferrable initially deferred
  for each row
  execute function fn_tg_venta_con_detalle();

-- 3.3 Todo cliente debe tener al menos un email (se revisa al COMMIT, así se
-- puede insertar el cliente y después sus correos en la misma transacción).
create or replace function fn_tg_cliente_con_email()
returns trigger
language plpgsql
as $$
declare
  v_rfc cliente.rfc%type;
begin
  if tg_table_name = 'cliente' then
    v_rfc := new.rfc;
  else
    v_rfc := old.rfc;
  end if;

  if exists (select 1 from cliente where rfc = v_rfc)
     and not exists (select 1 from email_cliente where rfc = v_rfc) then
    raise exception 'El cliente % debe tener al menos un email registrado', v_rfc;
  end if;

  return null;
end;
$$;

drop trigger if exists tg_cliente_con_email on cliente;
create constraint trigger tg_cliente_con_email
  after insert or update on cliente
  deferrable initially deferred
  for each row
  execute function fn_tg_cliente_con_email();

drop trigger if exists tg_email_cliente_minimo on email_cliente;
create constraint trigger tg_email_cliente_minimo
  after delete or update on email_cliente
  deferrable initially deferred
  for each row
  execute function fn_tg_cliente_con_email();

-- =============================================================================
-- 4. Procedimiento
-- =============================================================================

-- 4.1 Registra una venta completa en una sola transacción.
--   p_codigos y p_cantidades van en el mismo orden (un renglón por artículo).
--   Los triggers de detalle_venta validan y descuentan el stock y calculan los
--   totales; si algún artículo falla se aborta la venta completa.
-- Ejemplo:
--   call sp_registrar_venta('XAXX010101000',
--                           array['7509000412705', '7509000413818'],
--                           array[2, 3]);
create or replace procedure sp_registrar_venta(
  p_rfc_cliente     varchar,
  p_codigos         varchar[],
  p_cantidades      int[],
  p_fecha           date default current_date,
  inout p_num_venta varchar default null
)
language plpgsql
as $$
declare
  v_total venta.total_venta%type;
begin
  if coalesce(cardinality(p_codigos), 0) = 0
     or cardinality(p_codigos) <> coalesce(cardinality(p_cantidades), 0) then
    raise exception 'La venta debe tener al menos un artículo y una cantidad por cada código';
  end if;

  insert into venta(fecha_venta, rfc_cliente)
  values (p_fecha, p_rfc_cliente)
  returning num_venta into p_num_venta;

  for i in 1 .. cardinality(p_codigos) loop
    insert into detalle_venta(num_venta, codigo_barras, cantidad)
    values (p_num_venta, p_codigos[i], p_cantidades[i]);
  end loop;

  select total_venta into v_total from venta where num_venta = p_num_venta;
  raise notice 'Venta % registrada. Total a pagar: $%', p_num_venta, v_total;
end;
$$;

-- =============================================================================
-- 5. Funciones de consulta
-- =============================================================================

-- 5.1 Dada una fecha, o una fecha de inicio y una de fin, regresa lo que se
-- vendió y la ganancia del periodo.
--   ganancia = suma de cantidad * (precio_unitario - costo_unitario)
-- Ejemplos:
--   select * from fn_ventas_periodo('2026-10-15');
--   select * from fn_ventas_periodo('2026-10-01', '2026-10-31');
create or replace function fn_ventas_periodo(
  p_fecha_inicio  date,
  p_fecha_fin     date default null
)
returns table(
  fecha_inicio        date,
  fecha_fin           date,
  num_ventas          bigint,
  articulos_vendidos  bigint,
  total_vendido       numeric,
  costo_total         numeric,
  ganancia            numeric
)
language plpgsql
stable
as $$
declare
  v_fin date := coalesce(p_fecha_fin, p_fecha_inicio);
begin
  if p_fecha_inicio is null then
    raise exception 'Debe indicar al menos una fecha';
  end if;

  if v_fin < p_fecha_inicio then
    raise exception 'La fecha final (%) es anterior a la fecha inicial (%)', v_fin, p_fecha_inicio;
  end if;

  return query
  select p_fecha_inicio,
         v_fin,
         count(distinct v.num_venta),
         coalesce(sum(d.cantidad), 0)::bigint,
         coalesce(sum(d.total_articulo), 0),
         coalesce(sum(d.cantidad * d.costo_unitario), 0),
         coalesce(sum(d.total_articulo - d.cantidad * d.costo_unitario), 0)
    from venta v
    join detalle_venta d on d.num_venta = v.num_venta
   where v.fecha_venta between p_fecha_inicio and v_fin;
end;
$$;

-- 5.2 Utilidad de un producto a partir de su código de barras:
--   utilidad = precio_venta - precio_compra (por pieza)
create or replace function fn_utilidad(p_codigo_barras varchar)
returns numeric
language plpgsql
stable
as $$
declare
  v_utilidad numeric(10,2);
begin
  select precio_venta - precio_compra
    into v_utilidad
    from producto
   where codigo_barras = p_codigo_barras;

  if not found then
    raise exception 'El producto con código de barras % no existe', p_codigo_barras;
  end if;

  return v_utilidad;
end;
$$;

-- =============================================================================
-- 6. Vistas
-- =============================================================================

-- 6.1 Factura: un renglón por artículo con los datos del cliente y los totales
-- de la venta. Una sola vista sirve para todas las ventas: las vistas se
-- calculan al consultarlas, así que cada venta nueva aparece en automático.
-- Los precios incluyen IVA (16 %); subtotal e IVA se desglosan del total.
--   select * from v_factura where num_venta = 'VENT-001';
create or replace view v_factura as
select v.num_venta,
       v.fecha_venta,
       c.rfc                                                   as rfc_cliente,
       concat_ws(' ', c.nombre, c.ap_paterno, c.ap_materno)    as cliente,
       concat_ws(', ', c.calle || ' ' || c.numero,
                       'Col. ' || c.colonia,
                       'C.P. ' || c.cp,
                       cp.estado)                              as domicilio_cliente,
       (select string_agg(e.email, ', ' order by e.email)
          from email_cliente e
         where e.rfc = c.rfc)                                  as email_cliente,
       d.codigo_barras,
       p.nombre                                                as producto,
       p.marca,
       p.descripcion,
       d.cantidad,
       d.precio_unitario,
       d.total_articulo                                        as importe,
       round(v.total_venta / 1.16, 2)                          as subtotal,
       v.total_venta - round(v.total_venta / 1.16, 2)          as iva,
       v.total_venta
  from venta v
  join cliente c        on c.rfc = v.rfc_cliente
  join codigo_postal cp on cp.cp = c.cp
  join detalle_venta d  on d.num_venta = v.num_venta
  join producto p       on p.codigo_barras = d.codigo_barras;

-- 6.2 Ventas por día: monto vendido contra la ganancia real (dashboard 1)
create or replace view v_ventas_por_dia as
select v.fecha_venta                                          as fecha,
       count(distinct v.num_venta)                            as num_ventas,
       sum(d.total_articulo)                                  as total_vendido,
       sum(d.cantidad * d.costo_unitario)                     as costo,
       sum(d.total_articulo - d.cantidad * d.costo_unitario)  as ganancia
  from venta v
  join detalle_venta d on d.num_venta = v.num_venta
 group by v.fecha_venta;

-- 6.3 Top 10 de productos más vendidos por piezas (dashboard 2)
create or replace view v_top10_productos as
select p.codigo_barras,
       p.nombre,
       p.marca,
       sum(d.cantidad)        as unidades_vendidas,
       sum(d.total_articulo)  as importe_vendido
  from detalle_venta d
  join producto p on p.codigo_barras = d.codigo_barras
 group by p.codigo_barras, p.nombre, p.marca
 order by unidades_vendidas desc, importe_vendido desc
 limit 10;

-- 6.4 Productos no disponibles o con menos de 3 piezas (dashboard 3).
-- Incluye al proveedor para saber a quién pedir.
create or replace view v_productos_stock_bajo as
select p.codigo_barras,
       p.nombre,
       p.marca,
       p.tipo,
       p.stock,
       case when p.stock = 0 then 'NO DISPONIBLE' else 'STOCK BAJO' end  as estado,
       pr.razon_social                                                     as proveedor
  from producto p
  join proveedor pr on pr.id_proveedor = p.id_proveedor
 where p.stock < 3
 order by p.stock, p.nombre;

-- =============================================================================
-- 7. Rol de solo lectura para el dashboard (DCL)
-- El usuario con el que se conecta el dashboard se crea en el despliegue:
--   create user usr_dashboard password '********' in role rol_dashboard;
-- =============================================================================
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'rol_dashboard') then
    create role rol_dashboard nologin;
  end if;
  execute format('grant connect on database %I to rol_dashboard', current_database());
end;
$$;

grant usage on schema public to rol_dashboard;
grant select on all tables in schema public to rol_dashboard;
grant execute on function fn_ventas_periodo(date, date), fn_utilidad(varchar)
   to rol_dashboard;
