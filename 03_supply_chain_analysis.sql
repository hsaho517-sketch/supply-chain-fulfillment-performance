-- ============================================================
-- SUPPLY CHAIN & FULFILLMENT PERFORMANCE
-- 03 - SUPPLY CHAIN ANALYSIS
-- ============================================================


-- 1. Overall fulfillment performance
SELECT
    COUNT(*) FILTER (
        WHERE shipment_status = 'Delivered'
    ) AS delivered_orders,

    ROUND(
        100.0 * SUM(on_time_delivery)
        FILTER (WHERE shipment_status = 'Delivered')
        / COUNT(*) FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(fulfillment_days)
        FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS avg_fulfillment_days

FROM analytics.fulfillment_performance;


-- 2. Delivery performance by warehouse
SELECT
    warehouse_id,
    warehouse_name,

    ROUND(
        100.0 * AVG(on_time_delivery)
        FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(fulfillment_days)
        FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS avg_fulfillment_days

FROM analytics.fulfillment_performance
GROUP BY warehouse_id, warehouse_name
ORDER BY on_time_delivery_pct DESC;


-- 3. Monthly on-time delivery trend by warehouse
SELECT
    DATE_TRUNC('month', order_date) AS month,
    warehouse_id,
    warehouse_name,

    ROUND(
        100.0 * AVG(on_time_delivery)
        FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS on_time_delivery_pct

FROM analytics.fulfillment_performance
GROUP BY
    DATE_TRUNC('month', order_date),
    warehouse_id,
    warehouse_name
ORDER BY month, warehouse_id;


-- 4. Supplier performance by year
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    supplier_id,
    supplier_name,

    COUNT(*) AS purchase_orders,

    ROUND(AVG(actual_lead_time_days), 2)
        AS avg_lead_time_days,

    ROUND(
        100.0 * AVG(on_time_supplier_delivery),
        2
    ) AS supplier_on_time_pct,

    ROUND(
        100.0 * AVG(received_in_full),
        2
    ) AS received_in_full_pct

FROM analytics.supplier_performance
GROUP BY
    EXTRACT(YEAR FROM order_date),
    supplier_id,
    supplier_name
ORDER BY supplier_id, year;


-- 5. Supplier G performance deterioration
SELECT
    EXTRACT(YEAR FROM order_date) AS year,

    ROUND(
        100.0 * AVG(on_time_supplier_delivery),
        2
    ) AS supplier_on_time_pct,

    ROUND(
        AVG(actual_lead_time_days),
        2
    ) AS avg_lead_time_days

FROM analytics.supplier_performance
WHERE supplier_id = 'S007'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;


-- 6. Stockout rate by warehouse and year
SELECT
    EXTRACT(YEAR FROM snapshot_date) AS year,
    warehouse_id,

    ROUND(
        100.0 * AVG(stockout),
        2
    ) AS stockout_rate_pct

FROM analytics.inventory_health
GROUP BY
    EXTRACT(YEAR FROM snapshot_date),
    warehouse_id
ORDER BY warehouse_id, year;


-- 7. Stockout rate for Supplier G products
SELECT
    EXTRACT(YEAR FROM snapshot_date) AS year,

    ROUND(
        100.0 * AVG(stockout),
        2
    ) AS stockout_rate_pct

FROM analytics.inventory_health
WHERE supplier_id = 'S007'
GROUP BY EXTRACT(YEAR FROM snapshot_date)
ORDER BY year;


-- 8. Valencia DC fulfillment deterioration during 2026
SELECT
    CASE
        WHEN order_date < DATE '2026-03-01'
            THEN 'Jan-Feb 2026'
        ELSE 'Mar-Aug 2026'
    END AS period,

    ROUND(
        AVG(fulfillment_days)
        FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS avg_fulfillment_days,

    ROUND(
        100.0 * AVG(on_time_delivery)
        FILTER (WHERE shipment_status = 'Delivered'),
        2
    ) AS on_time_delivery_pct

FROM analytics.fulfillment_performance
WHERE warehouse_id = 'W03'
  AND order_date >= DATE '2026-01-01'
  AND order_date < DATE '2026-09-01'

GROUP BY
    CASE
        WHEN order_date < DATE '2026-03-01'
            THEN 'Jan-Feb 2026'
        ELSE 'Mar-Aug 2026'
    END
ORDER BY MIN(order_date);