{{ config(materialized='table') }}

select
  date_day as date,
  extract(year from date_day) as year,
  extract(month from date_day) as month,
  extract(day from date_day) as day,
  format_date('%A', date_day) as weekday,
  format_date('%Y-%m', date_day) as year_month
from unnest(generate_date_array('2023-01-01', '2025-03-31', interval 1 day)) as date_day
