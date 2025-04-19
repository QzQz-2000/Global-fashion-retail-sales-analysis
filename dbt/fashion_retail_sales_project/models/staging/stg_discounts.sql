{{ config(materialized='table') }}

select 
    `Start` as start_date,
    `End` as end_date,
    Discont as discount,
    `Description` as description,
    Category as category,
    `Sub Category` as sub_category
from {{ ref('discounts') }}
