 create or replace table DEMO_DB.public.emp (
         first_name string ,
         last_name string ,
         email string ,
         streetaddress string ,
         city string ,
         start_date date
);

select * from emp;

-- We will be copying the data where we have error values for date columns.


CREATE OR REPLACE SCHEMA DEMO_DB.external_stages;

create or replace stage DEMO_DB.external_stages.my_s3_stage
  storage_integration = s3_int
  url = 's3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/'
  file_format = control_db.file_formats.my_csv_format;

  LIST @DEMO_DB.external_stages.my_s3_stage;

  DESCRIBE STAGE DEMO_DB.external_stages.my_s3_stage;

  DESCRIBE INTEGRATION s3_int;

  create or replace storage integration s3_int1
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::330420072484:role/CUSTOM-3RD-PARTY-SNOWACCESS'
  storage_allowed_locations = ('s3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/');

copy into DEMO_DB.public.emp
from @DEMO_DB.external_stages.my_s3_stage
file_format = (type = csv field_optionally_enclosed_by='"')
pattern = '.*employees0[1-5].csv';
---validation_mode = 'RETURN_ROW_COUNT';


list @DEMO_DB.external_stages.my_s3_stage;
 create or replace table DEMO_DB.public.emp (
         first_name string ,
         last_name string ,
         email string ,
         streetaddress string ,
         city string ,
         start_date string
);

select * from emp;

truncate table emp; 

create or replace table DEMO_DB.public.emp (
         first_name string ,
         last_name string ,
         email string ,
         streetaddress string ,
         city string ,
         start_date date
);

copy into DEMO_DB.public.emp
from @DEMO_DB.external_stages.my_s3_stage
file_format = (type = csv field_optionally_enclosed_by='"')
pattern = '.*employees.*\.csv'
ON_ERROR='CONTINUE';
--FORCE = TRUE;