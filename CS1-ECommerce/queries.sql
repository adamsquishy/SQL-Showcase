select 
    e.CUST_ID,
    d.CUST_FIRST_NAME,
    d.CUST_LAST_NAME,
    e.Amount_sold,
    p.Supplier_ID,
    p.PROD_ID,
    (c.unit_price - c.unit_cost) as Margins
From SH.SALES e
JOIN SH.Customers d on e.CUST_ID = d.CUST_ID
JOIN SH.PRODUCTS p on e.PROD_ID = p.PROD_ID
JOIN SH.COSTS c on e.PROD_ID = c.PROD_ID
