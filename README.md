# Snowflake-project-001

Learning / practice workspace for Snowflake topics. Each topic gets its own subfolder.

## Structure

```
Snowflake-project-001/
├── README.md          <-- you are here
└── COPY_INTO/         Topic folder (Amazon S3 → Snowflake loading)
    ├── Scripts/       SQL scripts (setup, load, validation)
    └── Notes/         Study notes & Q&A material (may add later)
```

## Current contents — COPY INTO (Amazon S3)

| File | Description |
|---|---|
| `COPY_INTO/Scripts/cop_into.sql` | Working script: table `DEMO_DB.public.emp`, S3 external stage, `COPY INTO` with `ON_ERROR = CONTINUE` (bad-date handling) |
| `COPY_INTO/Scripts/cop_into_fixed.sql` | Corrected/recommended version with context, file format, and 3rd-party integration notes |

## Adding more topics (later)

Simply add a sibling folder per topic, following the same pattern:

```
├── STORAGE_INTEGRATION/
│   └── Scripts/
├── SNOWPIPE/
│   └── Scripts/
├── EXTERNAL_TABLES/
│   └── Scripts/
```

---

### Quick setup reminder for the current script

1. Run the storage-integration setup first (creates `s3_int`, `demo_db`, `control_db`).
2. Ensure `control_db.file_formats.my_csv_format` exists (SEE `cop_into_fixed.sql`).
3. For the 3rd-party bucket: configure the trust policy + bucket policy with Snowflake's IAM user ARN / external ID before `LIST`/`COPY`.
4. Run `cop_into.sql` — validate with `VALIDATION_MODE`, then load.