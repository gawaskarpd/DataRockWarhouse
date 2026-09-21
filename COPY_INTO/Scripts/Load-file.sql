-- ============================================================
-- Load train_100_records.csv into TAXI_DRIVE_SMALL_FILES
-- (merged from copy_working_with_smaller_files_fixed.sql:
--  the table stage @%TAXI_DRIVE_SMALL_FILES only exists AFTER
--  the table is created, so the table is created first below.)
-- ============================================================

USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

-- STEP 1: Create the table FIRST.
--         This automatically creates its table stage  @%TAXI_DRIVE_SMALL_FILES
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.TAXI_DRIVE_SMALL_FILES
(
  TRIP_ID       NUMBER,
  CALL_TYPE     VARCHAR(2),
  ORIGIN_CALL   NUMBER,
  ORIGIN_STAND  NUMBER,
  TAXI_ID       NUMBER,
  TIMESTAMP     NUMBER,
  DAY_TYPE      VARCHAR(1),
  MISSING_DATA  BOOLEAN,
  POLYLINE      ARRAY
);

-- STEP 2: Upload your Desktop CSV into the table stage (Windows path)


PUT file:///C:/Users/Gawaskar/OneDrive/Desktop/train.csv
    @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES;

list@%TAXI_DRIVE_SMALL_FILES;

-- STEP 3: Load it. SKIP_HEADER=1 — your CSV has a header row.
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


truncate table DEMO_DB.PUBLIC.TAXI_DRIVE_SMALL_FILES;
-- Optional: verify the load
SELECT COUNT(*) AS LOADED_ROWS FROM DEMO_DB.PUBLIC.TAXI_DRIVE_SMALL_FILES;