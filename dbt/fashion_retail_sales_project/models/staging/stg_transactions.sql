{{ config(materialized='table') }}

with transactions_data as (
  select *,
    row_number() over(partition by Invoice_ID, Line) as rn
  from {{ source('staging','transactions_salesdata') }}
  where Invoice_ID is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['Invoice_ID', 'Line']) }} as transaction_id,

    -- Matching provided schema
    cast(Invoice_ID as string) as invoice_id,
    cast(Line as int64) as line,
    cast(Customer_ID as int64) as customer_id,
    cast(Product_ID as int64) as product_id,
    cast(Size as string) as size,
    coalesce(cast(Color as string), 'Unknown') as color,
    cast(Unit_Price as float64) as unit_price,
    cast(Quantity as int64) as quantity,
    cast(`Date` as timestamp) as transaction_date,
    cast(Discount as float64) as discount,
    cast(Line_Total as float64) as line_total,
    cast(Store_ID as int64) as store_id,
    cast(Employee_ID as int64) as employee_id,
    cast(Currency as string) as currency,
    cast(Currency_Symbol as string) as currency_symbol,
    cast(SKU as string) as sku,
    cast(Transaction_Type as string) as transaction_type,
    cast(Payment_Method as string) as payment_method,
    cast(Invoice_Total as float64) as invoice_total

from transactions_data
where rn = 1
