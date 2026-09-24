

CREATE or Replace TABLE demo_db.PUBLIC.HR_EMP_DATA
(
Emp_ID	VARCHAR,
Name_Prefix	VARCHAR,
First_Name	VARCHAR,
Middle_Initial	VARCHAR,
Last_Name	VARCHAR,
Gender	VARCHAR,
E_Mail	VARCHAR,
Father_Name	VARCHAR,
Mother_Name	VARCHAR,
Mother_Maiden_Name	VARCHAR,
Date_of_Birth	VARCHAR,
Time_of_Birth	VARCHAR,
Age_in_Yrs	VARCHAR,
Weight_in_Kgs	VARCHAR,
Date_of_Joining	VARCHAR,
Quarter_of_Joining	VARCHAR,
Half_of_Joining	VARCHAR,
Year_of_Joining	VARCHAR,
Month_of_Joining	VARCHAR,
Month_Name_of_Joining	VARCHAR,
Short_Month	VARCHAR,
Day_of_Joining	VARCHAR,
DOW_of_Joining	VARCHAR,
Short_DOW	VARCHAR,
Age_in_Company	VARCHAR,
Salary	VARCHAR,
Last_Hike	VARCHAR,
SSN	VARCHAR,
Phone 	VARCHAR,
Place_Name	VARCHAR,
County	VARCHAR,
City	VARCHAR,
State	VARCHAR,
Zip	VARCHAR,
Region	VARCHAR,
User_Name	VARCHAR,
Password	VARCHAR
);


CREATE or Replace TABLE demo_db.PUBLIC.CREDIT_CARD
(
Date	VARCHAR,
Description	VARCHAR,
Deposits	VARCHAR,
Withdrawls	VARCHAR,
Balance	VARCHAR
);


describe stage demo_db.public.my_stage_int1;

Create or replace Stage demo_db.public.my_stage_int2
file_format = (type = 'CSV' field_optionally_enclosed_by = '"' skip_header = 1);

list@demo_db.public.my_stage_int2;

describe stage demo_db.public.my_stage_int2;

-- NOTE: snow CLI login moved to ~/.snowflake/connections.toml (see run_put.ps1).
-- Cleaned: username/password removed from repo on 2026-09-24.



list @demo_db.public.my_stage_int2;


PUT file:///C:/Users/Gawaskar/OneDrive/Desktop/Snowflake-project-001/COPY_INTO/ResourceFilesUpload/HR_CREDIT.csv @demo_db.public.my_stage_int2;





Describe stage demo_db.public.my_stage_int2;

select * from demo_db.PUBLIC.HR_EMP_DATA;

TRUNCATE TABLE demo_db.PUBLIC.HR_EMP_DATA;

Select * from table(validate(demo_db.PUBLIC.HR_EMP_DATA, JOB_ID => '01c745c0-000e-03ed-0001-ec46002680f2'));


COPY INTO DEMO_DB.PUBLIC.CREDIT_CARD
FROM @demo_db.public.my_stage_int2
FILE_FORMAT = (type = 'CSV' field_optionally_enclosed_by = '"' skip_header = 1
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE)
ON_ERROR = 'CONTINUE';

DESCRIBE STAGE demo_db.public.my_stage_int2;

Select * from table(validate(demo_db.PUBLIC.CREDIT_CARD, JOB_ID => '01c745b8-000e-03eb-0001-ec460026a02a'));