--  STORAGE INTEGRATION OBJECT IF NOT EXISTS my_s3_integration
--    TYPE = EXTERNAL_STAGE
--    STORAGE_PROVIDER = S3
--    ENABLED = TRUE
--    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/my-s3-role'
---role used =Snow-s3-storage-integration
--    STORAGE_ALLOWED_LOCATIONS = ('s3://my-bucket/path/');

-- 2.Stage - external
-- 3. File format
-- 4. Pipe schema
-- 5. Table-- db- prod
-- 6. S3 Bucket-- event driven  config 
-- 7 File csv upload which will triger snowpipe


create or replace storage integration my_s3_integration
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::330420072484:role/NewStorageIntegrationS3Role'
  storage_allowed_locations = ('s3://snowpipe-integration-s3/Emp/csv/');

DESCRIBE INTEGRATION my_s3_integration;

Create or replace stage my_s3_stage
  url = 's3://snowpipe-integration-s3/Emp/csv/'
  storage_integration = my_s3_integration;

Create or replace file format my_csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;

list @my_s3_stage;

Create or replace pipe my_s3_pipe
  auto_ingest = true
  as
  copy into employees
  from @my_s3_stage
  file_format = my_csv_format
  PATTERN = '.*[.]csv';

  
  describe pipe my_s3_pipe;

  copy into employees
  from @my_s3_stage
  file_format = my_csv_format
  PATTERN = '.*[.]csv';


  // Create table first
CREATE OR REPLACE TABLE DATA_SAMPLE_DB.PUBLIC.employees (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
  );

  Select count(*) from DATA_SAMPLE_DB.PUBLIC.employees;


