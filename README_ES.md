# Análisis de Rendimiento de Supply Chain y Fulfillment

🌐 Idioma: [English](README.md) | **Español**

## Resumen Ejecutivo

Este proyecto end-to-end de Supply Chain Analytics investiga dónde se está perdiendo eficiencia operativa a través del rendimiento de proveedores, la disponibilidad de inventario, el fulfillment y el servicio de entrega.

El análisis identificó dos áreas claras de deterioro en 2026. El rendimiento on-time del Supplier G cayó del **59,55% al 0,31%**, mientras que su lead time medio aumentó de **10,97 a 18,77 días**. Al mismo tiempo, los stockouts de los productos suministrados por Supplier G aumentaron del **0,02% al 26,47%**.

Un segundo deterioro operativo apareció en Valencia DC a partir de marzo de 2026. El tiempo medio de fulfillment aumentó de **2,1 a 4,4 días**, mientras que el on-time delivery cayó del **55,64% al 18,24%**.

La evidencia sugiere que management debería priorizar la investigación de la fiabilidad inbound de Supplier G y del proceso de fulfillment de Valencia DC, mientras monitoriza la disponibilidad de inventario como un riesgo operativo conectado.

---

## Problema de Negocio

Una empresa de distribución está experimentando problemas operativos, incluyendo retrasos en entregas, stockouts y diferencias significativas de rendimiento entre proveedores y centros de distribución.

Operations Management quiere entender:

> **¿Dónde está perdiendo eficiencia operativa la supply chain y qué proveedores, productos u operaciones de fulfillment debería investigar primero management?**

El análisis sigue la cadena operativa:

**Proveedor → Inventario → Fulfillment → Entrega**

**Periodo de análisis:** enero de 2025 – agosto de 2026

---

## Dataset

El proyecto utiliza un dataset relacional sintético de supply chain que contiene:

- 18 proveedores
- 220 productos
- 4 centros de distribución
- 6.200 órdenes de compra
- 18.000 pedidos de clientes
- 45.007 líneas de pedido
- 18.000 envíos
- 535.160 snapshots diarios de inventario sin procesar

La evaluación inicial de calidad de datos identificó:

- 120 snapshots de inventario duplicados
- 2 proveedores con información de país ausente
- 1 almacén con información de capacidad ausente
- 17.858 envíos entregados
- 142 envíos todavía en tránsito

---

## Metodología

### 1. Calidad y Preparación de los Datos

Se utilizó PostgreSQL para inspeccionar el grain de las tablas, validar recuentos de filas, identificar valores ausentes, comprobar el estado de los envíos y detectar snapshots de inventario duplicados.

Los registros de inventario duplicados se eliminaron utilizando `ROW_NUMBER()`, mientras que los valores ausentes de país del proveedor se estandarizaron como `Unknown`.

Los envíos que todavía estaban en tránsito se excluyeron de los cálculos de rendimiento de entregas completadas.

### 2. Rendimiento de Proveedores

Los datos de órdenes de compra se utilizaron para medir:

- Lead time real del proveedor
- Retrasos en las entregas del proveedor
- Rendimiento on-time del proveedor
- Cantidad recibida en su totalidad

El rendimiento de los proveedores se comparó entre periodos para identificar deterioros operativos.

### 3. Disponibilidad de Inventario

Los snapshots diarios de inventario se conectaron con la información de productos y proveedores.

Se definió un stockout como:

> **Cantidad Disponible = 0**

Esto permitió analizar problemas de disponibilidad de inventario por almacén, proveedor, producto y periodo temporal.

### 4. Fulfillment y Entrega

Los pedidos de clientes y los envíos se utilizaron para medir:

- Tiempo de fulfillment
- Tiempo de tránsito
- Tiempo total de entrega
- On-time delivery

El rendimiento por almacén y las tendencias mensuales se compararon para identificar cambios en el rendimiento operativo a lo largo del tiempo.

### 5. Investigación de Causa Raíz

La investigación se centró después en las anomalías más fuertes identificadas en la visión general operativa:

- Deterioro del rendimiento de Supplier G
- Stockouts que afectan a productos de Supplier G
- Deterioro del fulfillment de Valencia DC a partir de marzo de 2026

---

## Principales Hallazgos

### 1. La fiabilidad general de las entregas es débil

Entre los envíos completados, solo el **57,11%** se entregaron a tiempo.

El tiempo medio de fulfillment fue de **2,10 días**, lo que indica la necesidad de investigar dónde se estaba deteriorando el rendimiento operativo por debajo del promedio global de la empresa.

### 2. Valencia DC presenta el peor rendimiento general de entrega

On-time delivery por centro de distribución:

- Seville DC: **61,76%**
- Madrid DC: **61,52%**
- Barcelona DC: **55,08%**
- Valencia DC: **50,33%**

La tendencia temporal mostró un deterioro especialmente fuerte en Valencia durante 2026.

### 3. Supplier G se deterioró fuertemente en 2026

El rendimiento on-time de Supplier G cayó de:

**59,55% → 0,31%**

Al mismo tiempo, el lead time medio aumentó de:

**10,97 → 18,77 días**

Esto representa el deterioro upstream de proveedor más claro identificado en el análisis.

### 4. Los stockouts aumentaron fuertemente en los productos de Supplier G

La tasa de stockout de los productos suministrados por Supplier G aumentó de:

**0,02% en 2025 → 26,47% en 2026**

El momento en el que se produce este deterioro coincide con la caída de la fiabilidad inbound de Supplier G, convirtiendo este grupo proveedor-producto en una prioridad para investigaciones posteriores.

### 5. Valencia DC experimentó una ruptura operativa a partir de marzo de 2026

En Valencia DC:

**Tiempo Medio de Fulfillment**

**2,1 días → 4,4 días**

**On-Time Delivery**

**55,64% → 18,24%**

El cambio que comienza en marzo de 2026 sugiere un problema adicional de fulfillment a nivel del centro de distribución, y no únicamente un problema upstream de proveedor.

---

## Recomendaciones de Negocio

1. **Priorizar la investigación de la fiabilidad inbound de Supplier G.** Revisar el deterioro del lead time, la consistencia de las entregas y el rendimiento frente a los niveles de servicio del proveedor antes de tomar decisiones estructurales de sourcing.

2. **Revisar las políticas de inventario de los productos de Supplier G.** Investigar puntos de reorden, niveles de safety stock, timing de reposición y posibles alternativas de suministro.

3. **Investigar las operaciones de Valencia DC a partir de marzo de 2026.** Revisar cambios en procesos de handling, carga de trabajo, staffing, limitaciones de capacidad u otros factores operativos que puedan explicar el aumento del tiempo de fulfillment.

4. **Monitorizar conjuntamente los KPIs operativos.** La fiabilidad de proveedores, la disponibilidad de inventario, el tiempo de fulfillment y el on-time delivery deberían monitorizarse como etapas conectadas de la supply chain y no como métricas aisladas.

---

## Limitaciones

- El dataset es sintético y está diseñado para práctica analítica.
- El análisis identifica asociaciones y patrones operativos, no relaciones causales.
- No se dispone de términos contractuales de proveedores, penalizaciones por SLA, costes de procurement ni capacidad de proveedores alternativos.
- No se dispone de datos detallados sobre mano de obra en almacén ni utilización de capacidad.
- No se incluyen costes de transporte ni precisión del demand forecast.
- Un almacén tiene información de capacidad ausente.
- Los 142 envíos en tránsito se excluyeron del rendimiento de entregas completadas.
- Los stockouts se miden utilizando snapshots diarios de inventario disponible.

---

## Próximos Pasos

El análisis podría ampliarse incorporando:

- Datos de SLA de proveedores y costes de procurement
- Patrones de demanda y reposición a nivel de producto
- Optimización de safety stock
- Utilización de capacidad y mano de obra de almacén
- Rendimiento de carriers
- Objetivos de KPIs operativos y alertas de excepciones

---

## Validación en Excel

Excel se utilizó como una capa independiente de validación entre el análisis realizado en SQL y el reporting en Power BI.

Se utilizó una PivotTable para conciliar los KPIs de fulfillment y entrega por almacén y año. La validación confirmó el deterioro general en 2026:

- El tiempo medio de fulfillment aumentó de **1,78 días en 2025 a 2,56 días en 2026**.
- El on-time delivery cayó del **62,76% al 48,41%**.
- W03 (Valencia DC) mostró el deterioro más fuerte, respaldando la posterior investigación de causa raíz en Power BI.

![Validación de KPIs en Excel](excel_validation.png)

---

## Dashboard

### Visión General Operativa

![Supply Chain Operational Overview](executive_overview.png)

### Análisis de Causa Raíz

![Supply Chain Root Cause Analysis](root_cause_analysis.png)

---

## Herramientas y Habilidades

### PostgreSQL

Validación de datos, joins, agregaciones, lógica condicional, window functions, vistas analíticas, análisis de rendimiento de proveedores, análisis de inventario y desarrollo de KPIs operativos.

### Excel / Power Query

Validación de datos, conciliación de KPIs, PivotTables y validación cruzada de resultados entre herramientas.

### Power BI

Modelado de datos, medidas DAX, desarrollo de KPIs, análisis temporal, comparación entre proveedores y almacenes, investigación de causa raíz y diseño de dashboards.

---

## Archivos del Repositorio

- `01_data_quality.sql` — auditoría de calidad de datos
- `02_analytics_layer.sql` — vistas analíticas limpias y métricas operativas
- `03_supply_chain_analysis.sql` — análisis de negocio y queries de causa raíz
- `Supply_Chain_Fulfillment_Performance_Analysis.pbix` — informe de Power BI
- `excel_validation.png` — PivotTable de Excel utilizada para validación de KPIs
- `executive_overview.png` — dashboard de visión general operativa
- `root_cause_analysis.png` — dashboard de análisis de causa raíz
