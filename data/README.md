## Sprint 1.5 — Data Volatility & Database Recovery

Taka Taka uses PostgreSQL/PostGIS as its application database. During the MVP phase, database snapshots are persisted locally under `data/snapshots/db/`.

Sprint 1.5 establishes a repeatable database backup and recovery protocol designed to protect application state during development and future deployment operations.

### Recovery Architecture

```text
PostgreSQL/PostGIS
       │
       │ pg_dump
       ▼
/backups
       │
       │ Docker bind mount
       ▼
data/snapshots/db/
       │
       └── takataka_YYYYMMDD_HHMMSS.sql
```

Database snapshots are intentionally kept outside the PostgreSQL Docker volume. This allows the database volume to be destroyed and recreated without destroying the recovery artifact.

### Current MVP Storage Model

The MVP currently uses local filesystem storage:

* `data/raw/` — raw data inputs
* `data/processed/` — processed data
* `data/uploads/` — application uploads
* `data/snapshots/db/` — PostgreSQL database snapshots

These directories provide a simple development and MVP storage model. Production object storage such as S3-compatible storage can be introduced later when the application begins handling larger volumes of images, documents, and other binary assets.

### Database Backup

Windows development environments use:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\db\backup.ps1
```

The script:

1. Verifies PostgreSQL is available.
2. Executes `pg_dump` inside the PostgreSQL container.
3. Writes the SQL dump to the mounted `/backups` directory.
4. Persists the resulting snapshot under `data/snapshots/db/`.
5. Verifies that the snapshot exists and is non-empty.

Linux environments use the portable Bash implementation:

```bash
./scripts/db/backup.sh
```

### Database Restore

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\db\restore.ps1 -BackupFile .\data\snapshots\db\<backup-file>.sql
```

Linux:

```bash
./scripts/db/restore.sh data/snapshots/db/<backup-file>.sql
```

The restore process requires explicit confirmation before importing the selected snapshot.

### Recovery Protocol

The recovery procedure is:

```text
1. Start the Docker Compose stack
2. Run Django migrations
3. Create application state / superuser
4. Create a database snapshot
5. Destroy the PostgreSQL Docker volume
6. Start a fresh PostgreSQL container
7. Restore the database snapshot
8. Start the Django backend
9. Verify Django tables and application state
10. Authenticate through Django Admin
```

### Sprint 1.5 Recovery Proof

The recovery protocol was successfully tested against the Taka Taka Docker Compose environment.

The test demonstrated that:

* PostgreSQL/PostGIS can be backed up using `pg_dump`.
* The SQL snapshot persists independently of the PostgreSQL Docker volume.
* The PostgreSQL volume can be destroyed with `docker compose down -v`.
* A fresh PostgreSQL volume can be created.
* The SQL snapshot can be restored successfully.
* Django application tables are recovered.
* The original Django superuser is recovered.
* The recovered superuser can authenticate through Django Admin.

This provides the MVP with a verified database recovery mechanism.

### Important Boundary

The current system protects **database state**.

It does not yet provide production-grade off-site backup or object-storage durability for uploaded binaries.

Future production hardening may introduce:

* S3-compatible object storage
* automated scheduled backups
* backup retention policies
* off-site database snapshots
* backup encryption
* restore automation
* backup integrity checks
* monitoring and alerting

These are deliberately deferred until the MVP requires them.
