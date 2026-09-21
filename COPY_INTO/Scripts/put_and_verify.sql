-- ============================================================
-- Executed by the VS Code task "Snowflake: PUT taxi CSV to stage"
-- (run_put.ps1 via .vscode/tasks.json). All statements run
-- inside VS Code's integrated terminal.
--
-- Targets the FULL dataset train.csv (1.94 GB, ~1.71M rows).
-- ============================================================

-- PUT the local CSV into the table stage (Windows URI form:
-- file://C:/... two slashes, forward slashes, single-quoted).
-- PARALLEL = 16 speeds up the large upload.
PUT 'file://C:/Users/Gawaskar/OneDrive/Desktop/train.csv'
    @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES
    PARALLEL = 16;

-- Show what is now staged
LIST @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES;

-- Row count in the table
SELECT count(*) AS ROWS_LOADED FROM DEMO_DB.PUBLIC.TAXI_DRIVE_SMALL_FILES;