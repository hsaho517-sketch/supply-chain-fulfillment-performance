-- ============================================================
-- SUPPLY CHAIN & FULFILLMENT PERFORMANCE
-- 02 - ANALYTICS LAYER
-- ============================================================

CREATE SCHEMA IF NOT EXISTS analytics;


-- Clean supplier dimension
CREATE OR REPLACE VIEW analytics.suppliers_clean AS
SELECT
    supplier_id,
    supplier_name,
    COALESCE(country, 'Unknown') AS country,
    standard_lead_time_days,
    payment_terms_days
FROM suppliers;


-- Warehouse dimension
CREATE OR REPLACE VIEW analytics.warehouses_clean AS
SELECT *
FROM warehouses;


-- Remove duplicate inventory snapshots
CREATE OR REPLACE VIEW analytics.inventory_clean AS
SELECT
    snapshot_date,
    warehouse_id,
    product_id,
    on_hand_quantity,
    reserved_quantity,
    available_quantity
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY snapshot_date, warehouse_id, product_id
            ORDER BY snapshot_date
        ) AS rn
    FROM inventory
) i
WHERE rn = 1;


-- Supplier operational performance
CREATE OR REPLACE VIEW analytics.supplier_performance AS
SELECT
    po.purchase_order_id,
    po.product_id,
    po.supplier_id,
    s.supplier_name,
    po.warehouse_id,
    po.order_date,
    po.expected_delivery_date,
    po.actual_delivery_date,
    po.ordered_quantity,
    po.received_quantity,

    po.actual_delivery_date - po.order_date
        AS actual_lead_time_days,

    po.actual_delivery_date - po.expected_delivery_date
        AS delivery_delay_days,

    CASE
        WHEN po.actual_delivery_date <= po.expected_delivery_date
        THEN 1 ELSE 0
    END AS on_time_supplier_delivery,

    CASE
        WHEN po.received_quantity >= po.ordered_quantity
        THEN 1 ELSE 0
    END AS received_in_full

FROM purchase_orders po
JOIN analytics.suppliers_clean s
    ON po.supplier_id = s.supplier_id;


-- Inventory health
CREATE OR REPLACE VIEW analytics.inventory_health AS
SELECT
    i.snapshot_date,
    i.warehouse_id,
    i.product_id,
    p.category,
    p.supplier_id,
    i.on_hand_quantity,
    i.reserved_quantity,
    i.available_quantity,
    p.reorder_point,

    CASE
        WHEN i.available_quantity = 0 THEN 1 ELSE 0
    END AS stockout,

    CASE
        WHEN i.available_quantity < p.reorder_point THEN 1 ELSE 0
    END AS below_reorder_point

FROM analytics.inventory_clean i
JOIN products p
    ON i.product_id = p.product_id;


-- Fulfillment and delivery performance
CREATE OR REPLACE VIEW analytics.fulfillment_performance AS
SELECT
    o.order_id,
    o.order_date,
    o.warehouse_id,
    w.warehouse_name,
    o.customer_region,
    o.sales_channel,
    o.priority,

    s.carrier,
    s.ship_date,
    s.promised_delivery_date,
    s.actual_delivery_date,
    s.shipment_status,

    s.ship_date - o.order_date
        AS fulfillment_days,

    s.actual_delivery_date - s.ship_date
        AS transit_days,

    s.actual_delivery_date - o.order_date
        AS total_delivery_days,

    CASE
        WHEN s.shipment_status = 'Delivered'
         AND s.actual_delivery_date <= s.promised_delivery_date
        THEN 1
        WHEN s.shipment_status = 'Delivered'
        THEN 0
        ELSE NULL
    END AS on_time_delivery

FROM orders o
JOIN shipments s
    ON o.order_id = s.order_id
JOIN analytics.warehouses_clean w
    ON o.warehouse_id = w.warehouse_id;