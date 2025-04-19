{{ config(materialized='table') }}

select *
from {{ ref('stg_products') }}
where product_id is not null