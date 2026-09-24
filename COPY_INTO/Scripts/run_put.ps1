# ============================================================
# Runs Snowflake PUT from inside VS Code (integrated terminal).
# Trigger: VS Code Command Palette > "Tasks: Run Task" >
#          "Snowflake: PUT taxi CSV to stage (Run from VS Code)"
#
# WHY: the Snowflake VS Code extension cannot execute raw PUT
# SQL typed in a .sql file. This task is the supported way to
# run PUT from VS Code - one click in the integrated terminal.
# ============================================================
$ErrorActionPreference = 'Stop'

$sqlFile   = 'C:\Users\Gawaskar\OneDrive\Desktop\Snowflake-project-001\COPY_INTO\Scripts\put_and_verify.sql'
$connFile  = "$env:USERPROFILE\.snowflake\connections.toml"
$snowsql   = 'C:\Program Files\Snowflake SnowSQL\snowsql.exe'

if (-not (Test-Path $sqlFile))   { Write-Error "SQL file not found: $sqlFile";   exit 1 }
if (-not (Test-Path $connFile))  { Write-Error "Config not found: $connFile";    exit 1 }
if (-not (Test-Path $snowsql))   { Write-Error "SnowSQL not found: $snowsql";   exit 1 }

# Read the stored connection user + password at runtime (never printed, never stored).
$userLine = Get-Content $connFile | Where-Object { $_ -match '^\s*username\s*=' } | Select-Object -First 1
if ($userLine -match '"([^"]*)"') { $env:SNOWSQL_USER = $matches[1] }
else { Write-Error 'No stored username found in connections.toml'; exit 1 }

$pwdLine = Get-Content $connFile | Where-Object { $_ -match '^\s*password\s*=' } | Select-Object -First 1
if ($pwdLine -match '"([^"]*)"') { $env:SNOWSQL_PWD = $matches[1] }
else { Write-Error 'No stored password found in connections.toml'; exit 1 }

Write-Host 'Uploading to Snowflake stage @DEMO_DB.PUBLIC.%TAXI_DRIVE_SMALL_FILES ...' -ForegroundColor Cyan

& $snowsql `
  --authenticator snowflake `
  -a GKMZJDJ-RB91367 `
  -d DEMO_DB `
  -s PUBLIC `
  -w COMPUTE_WH `
  -r ACCOUNTADMIN `
  -o log_level=ERROR `
  -f $sqlFile

$rc = $LASTEXITCODE
if ($rc -eq 0) { Write-Host 'DONE - file staged.' -ForegroundColor Green }
else          { Write-Host "SnowSQL failed with exit code $rc" -ForegroundColor Red }
exit $rc