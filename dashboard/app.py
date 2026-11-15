"""
Dashboard de ventas e inventario de la cadena de papelerías.

  1. Ingresos por día: monto vendido contra la ganancia real (v_ventas_por_dia)
  2. Top 10 de productos más vendidos (v_top10_productos)
  3. Productos no disponibles o con bajo stock (v_productos_stock_bajo)

La conexión se toma de DATABASE_URL, por ejemplo
  postgresql://usr_dashboard:clave@localhost:5432/papeleria
o de las variables estándar de PostgreSQL (PGHOST, PGUSER, ...).

Ejecutar:
  pip install -r requirements.txt
  streamlit run app.py
"""

import os

import pandas as pd
import plotly.graph_objects as go
import psycopg
import streamlit as st

AZUL, NARANJA, GRIS, REJILLA = "#2a78d6", "#eb6834", "#52514e", "#e6e5e1"

st.set_page_config(page_title="Papelerías | Ventas e inventario", layout="wide")


@st.cache_resource
def conexion():
    return psycopg.connect(os.environ.get("DATABASE_URL", ""), autocommit=True)


def consulta(sql, params=None):
    with conexion().cursor() as cur:
        cur.execute(sql, params)
        return pd.DataFrame(cur.fetchall(), columns=[c.name for c in cur.description])


def estilo(fig, alto):
    fig.update_layout(height=alto, margin=dict(l=8, r=8, t=8, b=8),
                      plot_bgcolor="white", font=dict(size=13),
                      legend=dict(orientation="h", y=1.02, yanchor="bottom", x=0))
    fig.update_xaxes(showgrid=False, tickfont=dict(color=GRIS))
    fig.update_yaxes(gridcolor=REJILLA, zeroline=False, tickfont=dict(color=GRIS))
    return fig


st.title("Papelerías: ventas e inventario")

diario = consulta("select * from v_ventas_por_dia order by fecha")
if diario.empty:
    st.info("Todavía no hay ventas registradas.")
    st.stop()

rango = st.date_input("Periodo", value=(diario.fecha.min(), diario.fecha.max()),
                      min_value=diario.fecha.min(), max_value=diario.fecha.max(),
                      format="DD/MM/YYYY")
inicio, fin = rango if len(rango) == 2 else (rango[0], rango[0])
diario = diario[(diario.fecha >= inicio) & (diario.fecha <= fin)]

# 1. Ingresos por día
st.subheader("Ingresos por día: monto vendido contra ganancia real")
fig = go.Figure()
fig.add_scatter(x=diario.fecha, y=diario.total_vendido, name="Monto vendido",
                line=dict(color=AZUL, width=2), fill="tozeroy",
                fillcolor="rgba(42,120,214,0.10)",
                hovertemplate="Vendido: $%{y:,.2f}<extra></extra>")
fig.add_scatter(x=diario.fecha, y=diario.ganancia, name="Ganancia real",
                line=dict(color=NARANJA, width=2),
                hovertemplate="Ganancia: $%{y:,.2f}<extra></extra>")
fig.update_layout(hovermode="x unified")
fig.update_xaxes(tickformat="%d/%m", hoverformat="%d/%m/%Y")
fig.update_yaxes(tickprefix="$", tickformat=",.0f", rangemode="tozero")
st.plotly_chart(estilo(fig, 380), use_container_width=True)

c1, c2 = st.columns([3, 2])

# 2. Top 10 de productos más vendidos
with c1:
    st.subheader("Top 10 de productos más vendidos")
    top = consulta("select * from v_top10_productos").iloc[::-1]
    fig = go.Figure(go.Bar(x=top.unidades_vendidas, y=top.nombre, orientation="h",
                           marker=dict(color=AZUL, cornerradius=4),
                           text=top.unidades_vendidas, textposition="outside",
                           customdata=top.importe_vendido,
                           hovertemplate="%{y}<br>%{x} piezas<br>"
                                         "Importe: $%{customdata:,.2f}<extra></extra>"))
    fig.update_layout(bargap=0.45)
    fig.update_xaxes(title_text="Piezas vendidas", showgrid=True, gridcolor=REJILLA)
    st.plotly_chart(estilo(fig, 420), use_container_width=True)

# 3. Productos no disponibles o con bajo stock
with c2:
    st.subheader("Productos no disponibles o con bajo stock")
    bajo = consulta("select nombre, stock, estado, proveedor from v_productos_stock_bajo")
    bajo["estado"] = bajo.estado.map({"NO DISPONIBLE": "⛔ No disponible",
                                      "STOCK BAJO": "⚠️ Stock bajo"})
    st.dataframe(bajo.rename(columns=str.capitalize), hide_index=True,
                 use_container_width=True)
