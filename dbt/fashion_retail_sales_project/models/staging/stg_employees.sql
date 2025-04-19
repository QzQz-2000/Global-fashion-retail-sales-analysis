{{ config(materialized='table') }}

select 
    `Employee ID` as employee_id,
    `Store ID` as store_id,
    Name as employee_name,
    Position as position

from {{ ref('employees') }}