{{ config(materialized='table') }}

select *
from {{ ref('stg_stores') }}
where store_id is not null