{{ config(materialized='table') }}

select
    `Store ID` as store_id,
    
    case
        when Country in ('中国', 'China') then 'China'
        when Country = 'Deutschland' then 'Germany'
        when Country = 'España' then 'Spain'
        when Country = 'Portugal' then 'Portugal'
        when Country = 'France' then 'France'
        when Country = 'United Kingdom' then 'United Kingdom'
        when Country = 'United States' then 'United States'
        else Country
    end as country,

    case
        when City in ('北京') then 'Beijing'
        when City in ('上海') then 'Shanghai'
        when City in ('广州') then 'Guangzhou'
        when City in ('深圳') then 'Shenzhen'
        when City in ('重庆') then 'Chongqing'
        when City = 'München' then 'Munich'
        when City = 'Köln' then 'Cologne'
        else City
    end as city,

    concat('Store ', 
        case
            when City in ('北京') then 'Beijing'
            when City in ('上海') then 'Shanghai'
            when City in ('广州') then 'Guangzhou'
            when City in ('深圳') then 'Shenzhen'
            when City in ('重庆') then 'Chongqing'
            when City = 'München' then 'Munich'
            when City = 'Köln' then 'Cologne'
            else City
        end
    ) as store_name,

    `Number of Employees` as number_of_employees,
    `ZIP Code` as zip_code,
    Latitude as latitude,
    Longitude as longitude

from {{ ref('stores') }}
