USE ROLE ACCOUNTADMIN;

create or replace storage integration s3_int
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::330420072484:role/CUSTOM-3RD-PARTY-SNOWACCESS'
  storage_allowed_locations = ('s3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/');

DESC INTEGRATION s3_int;

CREATE OR REPLACE Database control_db;

CREATE OR REPLACE SCHEMA control_db.file_formats;

--SECTION QUERY AWS S3 FROM SNOWFLAKE
create or replace file format control_db.file_formats.my_csv_format
type = csv field_delimiter = ',' skip_header = 1 null_if = ('NULL', 'null') empty_field_as_null = true;

desc file format my_csv_format;


SHOW SCHEMAS IN DATABASE control_db;

Create or replace schema control_db.external_stages;

create or replace stage control_db.external_stages.my_s3_stage
  storage_integration = s3_int
  url = 's3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/'
  file_format = control_db.file_formats.my_csv_format;

-- Query data directly
select t.$1 as first_name,t.$2 last_name,t.$3 email
from @control_db.external_stages.my_s3_stage/ t;

-- filter data directly
select t.$1 as first_name,t.$2 last_name,t.$3 email
from @control_db.external_stages.my_s3_stage/ t
where t.$1 in ('Di','Carson','Dana');

-- you can write join condition.
select t.$1 as first_name,t.$2 last_name,t.$3 email
from @control_db.external_stages.my_s3_stage/ t,
     @control_db.external_stages.my_s3_stage/ d
where t.$1 =d.$1;


---Today's work---18/09/2026
copy into demo_db.public.emp_ext_stage
from (select t.$1 , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.external_stages.my_s3_stage/ t)
pattern = '.*employees0[1-5].csv'
on_error = 'CONTINUE';

list @control_db.external_stages.my_s3_stage;

use database demo_db;

use schema public;

create or replace table demo_db.public.emp_ext_stage (
         --file_name string,
         first_name string ,
         last_name string ,
         email string ,
         streetaddress string ,
         city string ,
         start_date date
);


create or replace stage control_db.external_stages.my_s3_stage
  storage_integration = s3_int
  url = 's3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/'
  file_format = control_db.file_formats.my_csv_format;

copy into demo_db.public.emp_ext_stage
from (select t.$1 , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.external_stages.my_s3_stage/ t)
pattern = '.*employees0[1-5].csv'
on_error = 'CONTINUE';


select * from demo_db.public.emp_ext_stage;

ALTER TABLE demo_db.public.emp_ext_stage
ADD COLUMN filename VARCHAR;

ALTER TABLE demo_db.public.emp_ext_stage
drop COLUMN filename;

truncate table demo_db.public.emp_ext_stage;

copy into demo_db.public.emp_ext_stage(
         filename,
         first_name ,
         last_name ,
         email ,
         streetaddress ,
         city ,
         start_date
)
from (select  metadata$filename,t.$1  , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.external_stages.my_s3_stage/ t )
--pattern = '.*employees0[1-5].csv'
on_error = 'CONTINUE';


copy into demo_db.public.emp_ext_stage(
         filename,
         first_name ,
         last_name ,
         email ,
         streetaddress ,
         city ,
         start_date
)
from (select case when t.$1='Ron' then 'Gone' else t.$1 end , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.external_stages.my_s3_stage/ t )
--pattern = '.*employees0[1-5].csv'
on_error = 'CONTINUE';


----------------------------------------
copy into demo_db.public.emp_ext_stage
from (select case when t.$1='Ron' then 'Gone' else t.$1 end , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.external_stages.my_s3_stage/ t )
--pattern = '.*employees0[1-5].csv'
on_error = 'CONTINUE';


--metadata$filename

TRUNCATE TABLE emp_ext_stage;

SELECT * FROM emp_ext_stage;

--01c723d5-000d-ffc5-0001-ec46001cfe3e

SELECT LAST_QUERY_ID();

select * from table(validate(emp_ext_stage, job_id=>'01c723e4-000d-ffd5-0001-ec46001d100e'));

----UNload data from snowflake to s3------

create or replace file format my_csv_unload_format
type = csv field_delimiter = ',' skip_header = 0 null_if = ('NULL', 'null') 
empty_field_as_null = true compression = gzip;

alter storage integration s3_int set  
storage_allowed_locations=('s3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/',
                           's3://snow-test-aws-s3-load/Test1-snow/Unload-Folder/');
                          
desc integration s3_int;

create or replace stage my_s3_unload_stage
  storage_integration = s3_int
  url = 's3://snow-test-aws-s3-load/Test1-snow/Unload-Folder/'
  file_format = my_csv_unload_format;

  Select * from emp_ext_stage;

copy into @my_s3_unload_stage
from
emp_ext_stage
overwrite = true;

desc stage my_s3_unload_stage;

select count(*) from @my_s3_unload_stage;
select count(*) from emp_ext_stage;

COPY INTO @my_s3_unload_stage/employee_data.csv
FROM emp_ext_stage
SINGLE = TRUE
OVERWRITE = TRUE;

COPY INTO @my_s3_unload_stage/EMPLOYEE_
FROM emp_ext_stage
OVERWRITE = TRUE;


COPY INTO @my_s3_unload_stage/employee_COMP2.gz
FROM
(
    SELECT
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        STREETADDRESS,
        CITY,
        START_DATE,

        NTILE(5) OVER (
            ORDER BY FIRST_NAME, LAST_NAME, EMAIL, START_DATE
        ) AS FILE_GROUP

    FROM DEMO_DB.PUBLIC.EMP_EXT_STAGE
)
PARTITION BY (FILE_GROUP)
FILE_FORMAT = (
    TYPE = CSV
    COMPRESSION = GZIP
);
--OVERWRITE = TRUE;


COPY INTO @my_s3_unload_stage/Employee_Comp4.gz/
FROM
(
    SELECT
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        STREETADDRESS,
        CITY,
        START_DATE,
        NTILE(5) OVER (
            ORDER BY FIRST_NAME, LAST_NAME, EMAIL, START_DATE
        ) AS FILE_GROUP
    FROM DEMO_DB.PUBLIC.EMP_EXT_STAGE
)
--PARTITION BY (FILE_GROUP)
FILE_FORMAT = (
    TYPE = CSV
    COMPRESSION = NONE
);
--OVERWRITE = TRUE;

---PARQUET FILE UNOAD FROM SNOWFLAKE TO S3--

COPY INTO @my_s3_unload_stage/Employee_Comp.GZ
FROM (
    SELECT
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        STREETADDRESS,
        CITY,
        START_DATE
    FROM DEMO_DB.PUBLIC.EMP_EXT_STAGE
)
FILE_FORMAT = (
    TYPE = PARQUET
)
OVERWRITE = TRUE;
