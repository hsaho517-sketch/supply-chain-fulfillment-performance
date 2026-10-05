-- ============================================================
-- SUPPLY CHAIN & FULFILLMENT PERFORMANCE
-- 01 - DATA QUALITY AUDIT
-- ============================================================

-- Row counts
SELECT 'suppliers' AS table_name, COUNT(*) AS rows FROM suppliers
UNION ALL
SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory;


-- Missing supplier country values
SELECT
    COUNT(*) AS total_suppliers,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country
FROM suppliers;


-- Missing warehouse capacity values
SELECT
    COUNT(*) AS total_warehouses,
    COUNT(*) FILTER (WHERE capacity_units IS NULL) AS missing_capacity
FROM warehouses;


-- Duplicate inventory snapshots
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (snapshot_date, warehouse_id, product_id)) AS unique_snapshots,
    COUNT(*) - COUNT(DISTINCT (snapshot_date, warehouse_id, product_id))
        AS duplicate_rows
FROM inventory;


-- Order date coverage
SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM orders;


-- Shipment status distribution
SELECT
    shipment_status,
    COUNT(*) AS shipments
FROM shipments
GROUP BY shipment_status
ORDER BY shipments DESC;