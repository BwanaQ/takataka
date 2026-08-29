# Taka Taka — Data Conventions

**Status:** Sprint 2
**Applies to:** everything under `data/` and every ingestion pipeline.

These conventions exist so that every dataset in Taka Taka behaves the same way.
They are deliberately few. Add to this file only when a rule has proven necessary.

---

## 1. Directory layout

```text
data/
├── raw/          # immutable downloads, exactly as acquired
│   └── <source_id>/<acquired_date>/<original_filename>
└── processed/    # outputs of transformation scripts
    └── kitui/<dataset_name>.<ext>
```

- `<source_id>` matches the `id` field in `docs/data/sources.md`.
- `<acquired_date>` is `YYYY-MM-DD`.
- Original filenames are preserved, even ugly ones.

Example:

```text
data/raw/kenya-admin-boundaries/2026-08-14/ken_adm_iebc_20191031_shp.zip
data/processed/kitui/boundaries_wards.geojson
```

## 2. Raw data is immutable

- Files under `data/raw/` are **never edited**, not even to fix an obvious typo.
- Fixes happen in transformation code, so they are reproducible and reviewable.
- Do not open raw CSVs in Excel and save them. Excel silently corrupts
  dates, leading zeros and UTF-8 encoding.

## 3. Git policy for data files

| Path | In git? | Rule |
|---|---|---|
| `data/raw/` (small files, < ~5 MB) | ✅ yes | Commit with their metadata file |
| `data/raw/` (large files, e.g. OSM PBF) | ❌ no | Gitignored; fetch is scripted |
| `data/processed/` | ✅ yes (Sprint 2) | Small enough for now; revisit when files grow |
| Metadata / README files | ✅ always | |

`.gitignore` entries:

```text
data/raw/osm-kenya-geofabrik/
*.osm.pbf
```

## 4. Every raw acquisition gets a metadata file

Next to every acquired file (or archive), create `_meta.md`:

```text
data/raw/<source_id>/<acquired_date>/_meta.md
```

Containing:

```markdown
source_id:      kenya-admin-boundaries
download_url:   <exact URL used>
acquired_at:    2026-08-14T09:30:00+03:00
acquired_by:    <name>
file:           ken_adm_iebc_20191031_shp.zip
sha256:         <checksum>
notes:          <anything unusual about the download>
```

Checksum on Windows PowerShell:

```powershell
Get-FileHash .\file.zip -Algorithm SHA256
```

## 5. Coordinate reference system

- **Storage CRS is EPSG:4326 (WGS84), everywhere, no exceptions.**
- Reprojection happens in the transform step and is asserted in validation.
- Area and distance calculations use a projected CRS **at computation time**
  (UTM 37S / EPSG:32737 covers Kitui) but results are never stored in that CRS.

## 6. Naming

- Datasets, columns, files: `snake_case`, ASCII, lowercase.
- Administrative names keep official spelling in a `name` column;
  a normalised join key goes in `name_key` (uppercase, trimmed,
  collapsed whitespace, no punctuation).
- Never join on raw names. Always join on `name_key` or, better, on codes.

## 7. Transformation scripts

- Live in the repo (location decided with the `data_sources` Django app;
  interim: `backend/apps/data_sources/pipelines/`).
- One script per dataset, named `transform_<source_id>.py`.
- Must be a pure function of the raw inputs: same input → same output.
- End with validation assertions that **fail loudly**. A transform that
  produces a wrong-but-plausible file is worse than one that crashes.

## 8. The provenance rule

> If we cannot identify where a datum came from, we do not ingest it
> as authoritative data.

Every processed dataset must be traceable to:

1. an entry in `docs/data/sources.md`,
2. a raw file with a `_meta.md`,
3. a transformation script in git.

If any link in that chain is missing, the data does not go into PostGIS.

## 9. Derived values are labelled

Anything we calculate (densities we compute ourselves, waste-generation
estimates, scores) is `data_class: estimated` and records its methodology.
Derived values are never stored in the same column as published values.

---

*Change log*

| Date | Change |
|---|---|
| (pending) | Initial conventions for Sprint 2 |