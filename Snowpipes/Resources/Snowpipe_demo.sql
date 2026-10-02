create database snowpipe

create or replace storage integration Snowflake_Obj
type = external_stage
storage_provider = s3
enabled = true
storage_aws_role_arn = '*****/snowflake'
storage_allowed_locations = ('s3://snowpipe-demo2/');


create or replace file format Emp_file_format
type = csv field_delimiter = ',' skip_header = 1 null_if = ('NULL', 'null') empty_field_as_null = true;

create or replace stage snow_stage
storage_integration = Snowflake_Obj
url = 's3://snowpipe-demo2/'
file_format = Emp_file_format;

-- Create target table for JSON data

create or replace table emp_snowpipe (
         first_name string ,
         last_name string ,
         email string ,
         streetaddress string ,
         city string ,
         start_date date
);

desc table emp_snowpipe

-- Create a pipe to ingest JSON data
create or replace pipe snowpipe.public.snowpipe auto_ingest=true as
    copy into snowpipe.public.emp_snowpipe
    from @snowpipe.public.snow_stage
    -- file_format = (type = 'csv');
show pipes;

truncate table snowpipe.public.emp_snowpipe

alter pipe snowpipe refresh;

select * from snowpipe.public.emp_snowpipe