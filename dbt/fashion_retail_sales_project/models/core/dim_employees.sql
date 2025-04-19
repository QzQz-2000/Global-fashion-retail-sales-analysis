{{ config(materialized='table') }}

select *
from {{ ref('stg_employees') }}
where employee_id is not null