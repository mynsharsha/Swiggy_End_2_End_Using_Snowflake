use role sysadmin;

-- create a warehouse if not exist 
create warehouse if not exists adhoc_wh
     comment = 'This is the adhoc-wh'
     warehouse_size = 'x-small' 
     auto_resume = true 
     auto_suspend = 60 
     enable_query_acceleration = false 
     warehouse_type = 'standard' 
     min_cluster_count = 1 
     max_cluster_count = 1 
     scaling_policy = 'standard'
     initially_suspended = true;
     
create database if not exists sandbox;
use database sandbox;

create schema if not exists stage_sch;
create schema if not exists clean_sch;
create schema if not exists consumption;
create schema if not exists common;

use schema stage_sch;

create file format if not exists csv_file_format
    type = 'csv'
    compression = 'auto'
    field_delimiter = ','
    record_delimiter = '\n'
    skip_header= 1
    field_optionally_enclosed_by = '\042'
    skip_header = 1
    null_if = ('\\N');


create stage csv_stg
    directory =(enable = true)
    comment = 'this is the snowflake internal stage';

create or replace tag common.pii_policy_tag
    allowed_values 'PII','PRICE','SENSITIVE','EMAIL'
    comment = 'This is pii policy tag object';

create or replace masking policy
common.pii_masking_policy as (pii_text string)
returns string -> to_varchar('** pii **');

create or replace masking policy
common.email_masking_policy as (email_text string)
returns string -> to_varchar(' ** email ** ');

create or replace masking policy
common.phone_masking_policy as (phone string)
returns string -> to_varchar(' **phone** ');

list @SANDBOX.STAGE_SCH.CSV_STG/initial;
list @SANDBOX.STAGE_SCH.CSV_STG/delta;

// Data in the stage can be accessed through $ sign without loading into the table;

select 
    t1.$1::text as location_id,
    t1.$2::text as city,
    t1.$3::text as state,
    t1.$4::text as zipcode,
    t1.$5::text as activeflag,
    t1.$6::text as createddate,
    t1.$7::text as modifieddate
from @SANDBOX.STAGE_SCH.CSV_STG/initial/location/
(file_format=> 'stage_sch.csv_file_format')t1;




    

    