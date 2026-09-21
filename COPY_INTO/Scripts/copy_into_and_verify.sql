-- ============================================================
-- Load the staged train.csv(.gz) into TAXI_DRIVE_SMALL_FILES.
-- Same logic as STEP 3 of Load-file.sql.
-- Skips files that were already loaded (e.g. the 100-row sample).
-- ============================================================
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE COMPUTE_WH;

COPY INTO DEMO_DB.PUBLIC.TAXI_DRIVE_SMALL_FILES
FROM (
  SELECT t.$1,
         t.$2,
         IFF(t.$3 = '', NULL, t.$3),   -- empty ORIGIN_CALL -> NULL
         IFF(t.$4 = '', NULL, t.$4),   -- empty ORIGIN_STAND -> NULL
         t.$5, t.$6, t.$7, t.$8, t.$9
  FROM '@DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES' t
)
FILE_FORMAT = (
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('')
)
ON_ERROR = 'CONTINUE';

-- Verify
SELECT count(*) AS TOTAL_ROWS,
       count(DISTINCT TRIP_ID) AS DISTINCT_TRIPS
FROM DEMO_DB.PUBLIC.TAXI_DRIVE_SMALL_FILES;

-- Show staged files and sizes
LIST @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES;