-- ============================================================
-- TOBACCO LOAD - 2026-09-23
-- Source : Tobacco_Legislation__Smokefree_Indoor_Air.csv (~148 MB)
-- Stage  : DEMO_DB.PUBLIC.MY_STAGE_INT1 (INTERNAL named stage)
-- Table  : DEMO_DB.PUBLIC.TOBACCO (TRANSIENT)
-- Log    : COPY_INTO/Logs/Tobacco_internal_stage_log.txt
-- ============================================================

USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

-- STEP 1: Upload local CSV to named internal stage
-- NOTE: local path is a FOLDER; real file is inside it.
-- Fixed: use @DB.SCHEMA.STAGE (named stage), NOT @DB.SCHEMA.%STAGE.
PUT 'file://C:/Users/Gawaskar/OneDrive/Desktop/Snowflake-project-001/Tobacco_Legislation__Smokefree_Indoor_Air.csv/Tobacco_Legislation__Smokefree_Indoor_Air.csv'
@DEMO_DB.PUBLIC.MY_STAGE_INT1;
-- Result 2026-09-22: UPLOADED 148532300 -> 16442336 bytes (.gz)

-- STEP 2: Verify staged file
LIST @DEMO_DB.PUBLIC.MY_STAGE_INT1;
-- Result: my_stage_int1/Tobacco_Legislation__Smokefree_Indoor_Air.csv.gz

-- STEP 3: Create table (23 cols, matches CSV header)
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.TOBACCO (
  Year NUMBER,
  Quarter NUMBER(1,0),
  LocationAbbr VARCHAR(2),
  LocationDesc VARCHAR(50),
  TopicDesc VARCHAR,
  MeasureDesc VARCHAR(50),
  DataSource VARCHAR(3),
  ProvisionGroupDesc VARCHAR(50),
  ProvisionDesc VARCHAR(50),
  ProvisionValue VARCHAR,
  Citation VARCHAR,
  ProvisionAltValue NUMBER,
  DataType VARCHAR,
  Comments VARCHAR,
  Enacted_Date DATE,
  Effective_Date DATE,
  GeoLocation VARCHAR,  -- CSV holds "(lat,lon)" string; parse later if needed
  DisplayOrder NUMBER,
  TopicTypeId VARCHAR(3),
  TopicId VARCHAR(100),
  MeasureId VARCHAR(20),
  ProvisionGroupID VARCHAR(10),
  ProvisionID NUMBER
);

-- STEP 4: Load (run next)
-- COPY INTO DEMO_DB.PUBLIC.TOBACCO
-- FROM @DEMO_DB.PUBLIC.MY_STAGE_INT1
-- FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
-- ON_ERROR = 'CONTINUE';

-- STEP 5: Verify
-- SELECT COUNT(*) FROM DEMO_DB.PUBLIC.TOBACCO;
