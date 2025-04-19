{{ config(materialized='table') }}

select
    cast(Customer_ID as int64) as customer_id,
    trim(Name) as customer_name,
    lower(trim(Email)) as email,
    Telephone as telephone,
    Country as country,
    case
        when Gender in ('M', 'Male') then 'Male'
        when Gender in ('F', 'Female') then 'Female'
        else 'Unknown'
    end as gender,
    cast(Date_Of_Birth as date) as date_of_birth,
    coalesce(trim(Job_Title), 'Unknown') as job_title
from {{ source('staging', 'customers_salesdata_external_table') }}
