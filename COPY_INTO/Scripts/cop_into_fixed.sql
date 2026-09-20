-- ============================================================
-- FIXED: Load CSV from S3 (3rd-party bucket) into emp
-- Run the Snowflake_external_tab.sql setup FIRST (creates demo_db,
-- control_db, s3_int, and the external stage).
-- ============================================================

-- Set context so unqualified names resolve predictably
USE DATABASE demo_db;
USE SCHEMA public;

-- 1) Target table, fully qualified
create or replace table demo_db.public.emp (
    first_name string,
    last_name string,
    email string,
    streetaddress string,
    city string,
    start_date date
);

-- 2) The file format the stage references (create if missing)
create or replace file format control_db.file_formats.my_csv_format
    type = csv
    field_optionally_enclosed_by = '"'
    skip_header = 0;

-- 3) Storage integration for the 3rd-party account (330420072484)
create or replace storage integration s3_int1
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::330420072484:role/CUSTOM-3RD-PARTY-SNOWACCESS'
  storage_allowed_locations = ('s3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/');

-- 4) IMPORTANT: get the identity to hand to the bucket owner
DESCRIBE INTEGRATION s3_int1;
--   >> copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID
--   >> send BOTH to the owner of AWS account 330420072484
--   >> they must add them to the trust policy of CUSTOM-3RD-PARTY-SNOWACCESS
--   >> and create a bucket policy granting s3:GetObject / s3:ListBucket
--      (and s3:GetBucketLocation) to that Snowflake IAM user.

-- 5) Stage -> MUST point at the integration whose trust policy was configured
--    for THIS bucket. Here we switch from s3_int to s3_int1.
create or replace stage demo_db.external_stages.my_s3_stage
  storage_integration = s3_int1
  url = 's3://snow-test-aws-s3-load/Test1-snow/SNOW-CLIENT-CSV/'
  file_format = control_db.file_formats.my_csv_format;

-- Sanity checks
LIST @demo_db.external_stages.my_s3_stage;
DESCRIBE STAGE demo_db.external_stages.my_s3_stage;

-- 6) Validate first (does NOT load, just reports errors)
copy into demo_db.public.emp
from @demo_db.external_stages.my_s3_stage
file_format = (type = csv field_optionally_enclosed_by = '"')
pattern = '.*employees0[1-5].csv'
validation_mode = 'RETURN_ERRORS';

-- 7) Then run the REAL load (remove validation_mode)
--    For the rows with bad date values you mentioned:
--      ON_ERROR = SKIP_FILE          -> skip any file containing a bad row
--      ON_ERROR = CONTINUE           -> load good rows, report bad ones
--      ON_ERROR = 'SKIP_FILE_2'      -> skip a file only after 2+ errors
copy into demo_db.public.emp
from @demo_db.external_stages.my_s3_stage
file_format = (type = csv field_optionally_enclosed_by = '"')
pattern = '.*employees0[1-5].csv'
on_error = 'SKIP_FILE';