/******* Let's start evaluating snowpipe feature ************/

/*** Make preparation ********/

create or replace storage integration s3_int
type = external_stage
storage_provider = s3
enabled = true
storage_aws_role_arn = 'arn:aws:iam::579834220952:role/snowflake_role'
storage_allowed_locations = ('s3://hartfordstar/');

alter storage integration s3_int 
set STORAGE_ALLOWED_LOCATIONS = ('s3://hartfordstar/','s3://hartfordstar/snowpipe/','s3://hartfordstar/snowpipe2/');


create or replace file format my_csv_s3_format
type = csv field_delimiter = ',' skip_header = 0 null_if = ('NULL', 'null') 
empty_field_as_null = true  FIELD_OPTIONALLY_ENCLOSED_BY='"';

create or replace stage snow_stage
storage_integration = s3_int
url = 's3://hartfordstar/snowpipe'
file_format = my_csv_s3_format;


/***** Preparation ends ********/

-- SCENARIO 1 : ERROR SCENARIO


-- Create target table 

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
create or replace pipe demo_db.public.snowpipe auto_ingest=true as
    copy into demo_db.public.emp_snowpipe
    from @demo_db.public.snow_stage
    -- file_format = (type = 'csv', FIELD_OPTIONALLY_ENCLOSED_BY='"');
    

show pipes;

truncate table demo_db.public.emp_snowpipe

alter pipe snowpipe refresh;

select * from demo_db.public.emp_snowpipe


-- Validate

select SYSTEM$PIPE_STATUS('snowpipe')

select * from table(validate_pipe_load(
  pipe_name=>'DEMO_DB.PUBLIC.snowpipe',
  start_time=>dateadd(hour, -4, current_timestamp())));
  
select *
from table(information_schema.copy_history(table_name=>'emp_snowpipe', start_time=> dateadd(hours, -1, current_timestamp())));



select *
from table(information_schema.query_history())
order by start_time desc;
  

--- If there is an error snowpipe will not give you any notification. It will remain silent. 
--- It's your responsibility to check for errors

/**********************************************************/

-- SCENARIO 2 : You can't update copy command. You can only re create pipe

create or replace pipe demo_db.public.snowpipe auto_ingest=true as
    copy into demo_db.public.emp_snowpipe
    from @demo_db.public.snow_stage
    file_format = (type = 'csv', FIELD_OPTIONALLY_ENCLOSED_BY='"')
    --ON_ERROR='CONTINUE'
 
-- We go and rectify the copy command. Once copy command is rectified we expect data to be loaded to table.
select * from demo_db.public.emp_snowpipe;

show pipes;

-- re creating your pipe will not change your notification channel.

--arn:aws:sqs:us-east-1:628993367716:sf-snowpipe-AIDAZE4XND2SCZEJXXYBR-gmNjf-iFPpApjNiM7VwsSQ
--arn:aws:sqs:us-east-1:628993367716:sf-snowpipe-AIDAZE4XND2SCZEJXXYBR-gmNjf-iFPpApjNiM7VwsSQ

create or replace stage snow_stage2
storage_integration = s3_int
url = 's3://hartfordstar/snowpipe2'
file_format = my_csv_s3_format;

create or replace pipe demo_db.public.snowpipe2 auto_ingest=true as
    copy into demo_db.public.emp_snowpipe
    from @demo_db.public.snow_stage
    file_format = (type = 'csv', FIELD_OPTIONALLY_ENCLOSED_BY='"');

show pipes;

-- Even new pipe object you create will carry same notification channel.
-- Which means if a event happens in aws s3 for new file .. all snowpipes will get triggered.
-- How warehouse cost is managed in case ? not sure.
  
alter pipe snowpipe refresh;

alter pipe snowpipe2 refresh;  -- It's pointing to different folder hence no files in Q.

-- Recreating pipe object is not dropping pipe metadata.

select * from demo_db.public.emp_snowpipe;

truncate table demo_db.public.emp_snowpipe;


/**********************************************************/

-- SCENARIO 3 : What if you accidently truncated the table and want to load the data again.
-- In this scenraio will snowpipe copies emp1 and emp2 files again? let's check.


truncate table demo_db.public.emp_snowpipe;

select * from demo_db.public.emp_snowpipe;  -- Only 3rd file data got loaded.
                                            -- If you want to load all files you need to re create pipe object and trigger sqs Q.
                                            
                                            -- If you have executed copy command manually it will copy the data.
                                            
                                            
       

/**********************************************************/

-- SCENARIO 4 : What if your data vendor rectifies source file and sends it with the same name ?

-- In this case lets add one more record to emp1 file and upload it again.


select * from demo_db.public.emp_snowpipe;

alter pipe snowpipe refresh;

    copy into demo_db.public.emp_snowpipe
    from @demo_db.public.snow_stage
    file_format = (type = 'csv', FIELD_OPTIONALLY_ENCLOSED_BY='"');

