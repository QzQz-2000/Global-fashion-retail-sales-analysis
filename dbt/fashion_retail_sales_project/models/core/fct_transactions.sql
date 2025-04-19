{{ config(materialized='table') }}

with exchange_rate as (
  select 'EUR' as currency, 1.00 as rate
  union all select 'USD', 0.91
  union all select 'CNY', 0.13
  union all select 'GBP', 1.17
),

transactions as (
  select
    t.transaction_id,
    t.invoice_id,
    t.line,
    t.customer_id,
    t.product_id,
    t.size,
    coalesce(t.color, 'Unknown') as color,
    cast(t.unit_price as float64) as unit_price,
    cast(t.quantity as int64) as quantity,
    cast(t.discount as float64) as discount,
    cast(t.line_total as float64) as line_total,
    cast(t.invoice_total as float64) as invoice_total,
    cast(t.transaction_date as timestamp) as transaction_date,
    t.store_id,
    t.employee_id,
    t.currency,
    t.currency_symbol,
    t.sku,
    t.transaction_type,
    t.payment_method,
    er.rate as currency_to_eur,

    round(cast(t.unit_price as float64) * er.rate, 2) as unit_price_eur,
    round(cast(t.line_total as float64) * er.rate, 2) as line_total_eur,
    round(cast(t.invoice_total as float64) * er.rate, 2) as invoice_total_eur,

    case when lower(t.transaction_type) = 'return' then true else false end as is_return

  from {{ ref('stg_transactions') }} t
  left join exchange_rate er on t.currency = er.currency
)

select
  ft.transaction_id,
  ft.invoice_id,
  ft.customer_id,
  c.customer_name,
  ft.product_id,
  p.category as product_category,
  p.sub_category as product_sub_category,
  ft.size,
  ft.color,
  ft.unit_price,
  ft.quantity,
  ft.discount,
  ft.line_total,
  ft.invoice_total,
  ft.transaction_date,
  ft.store_id,
  s.store_name,
  s.city as store_city,
  s.country as store_country,
  s.latitude as store_latitude,
  s.longitude as store_longitude,
  ft.employee_id,
  e.employee_name,
  ft.currency,
  ft.currency_symbol,
  ft.transaction_type,
  ft.payment_method,
  ft.currency_to_eur,
  ft.unit_price_eur,
  ft.line_total_eur,
  ft.invoice_total_eur,
  ft.is_return,
 
  d.year,
  d.month,
  d.day,
  d.weekday,
  d.year_month

from transactions ft

left join {{ ref('dim_customers') }} c on ft.customer_id = c.customer_id
left join {{ ref('dim_products') }} p on ft.product_id = p.product_id
left join {{ ref('dim_stores') }} s on ft.store_id = s.store_id
left join {{ ref('dim_employees') }} e on ft.employee_id = e.employee_id
left join {{ ref('dim_dates') }} d on date(ft.transaction_date) = d.date
