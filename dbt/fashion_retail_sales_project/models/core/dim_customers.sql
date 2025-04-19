{{ config(materialized='table') }}

select *
from {{ ref('stg_customers') }}
where customer_id is not null