# COPY INTO — Table Stage (`@%TABLE_NAME`) Fix

## Error seen

```
SQL compilation error:
Stage 'DEMO_DB.PUBLIC."%TAXI_DRIVE_SMALL_FILES"' does not exist or not authorized.
```

## Root cause

In Snowflake, `@%TABLE_NAME` is the **table stage** of `TABLE_NAME` (a hidden stage
that belongs to the table). It is **created automatically only when the table is
created**.

The error means the `COPY INTO` referenced `@%TAXI_DRIVE_SMALL_FILES` **before** the
table `TAXI_DRIVE_SMALL_FILES` existed in `DEMO_DB.PUBLIC` (or the table was never
created in that DB/schema).

## Fix (order matters)

1. `CREATE TABLE` first → auto-creates the table stage `@%TAXI_DRIVE_SMALL_FILES`.
2. `PUT file://... @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES` — upload local files
   (use a **Windows** path, e.g. `file:///C:/Users/Gawaskar/OneDrive/Desktop/...`).
3. `COPY INTO` from the table stage.

## Key takeaways

- `@%X` = table stage of table `X` — table must exist first.
- `@X`  = named stage — must be created with `CREATE STAGE` first.
- `~` / `@~` = user stage, `@%T` = table stage, `@#N` = stage objects.
- Course scripts often hard-code instructor paths (e.g. Mac
  `/Users/phchannappa/Downloads/...`) — always fix `PUT` paths for your machine.
- If the CSV has a header row, use `SKIP_HEADER = 1` in the file format.
- Inline `FILE_FORMAT = (TYPE='CSV' ...)` avoids depending on a named file format
  (like the course's `taxi_csv_format`) that may not exist in your account.

## Working script

See `../Scripts/copy_working_with_smaller_files_fixed.sql` — creates
`TAXI_DRIVE_SMALL_FILES`, PUTs `train_100_records.csv` from Desktop, and COPY INTOs
with `ON_ERROR = 'CONTINUE'`.

```sql
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

CREATE OR REPLACE TRANSIENT TABLE TAXI_DRIVE_SMALL_FILES
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

PUT file:///C:/Users/Gawaskar/OneDrive/Desktop/train_100_records.csv
    @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES;

COPY INTO TAXI_DRIVE_SMALL_FILES
FROM (
  SELECT t.$1, t.$2,
         IFF(t.$3 = '', NULL, t.$3),
         IFF(t.$4 = '', NULL, t.$4),
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
```