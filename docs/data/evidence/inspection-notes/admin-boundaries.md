# Inspection Note — kenya-admin-boundaries

**Source registry entry:** `../../sources.md` §5.1
**Raw file(s):** `data/raw/kenya-admin-boundaries/<date>/…`
**Inspected by / date:** *(pending)*

> Complete this note BEFORE writing the transformation script. The answers
> below are the specification for `transform_kenya_admin_boundaries.py`.

---

## 1. Acquisition record

| Field | Value |
|---|---|
| Download URL used | |
| Date acquired | |
| File name / size | |
| SHA256 | |
| Archive contents | |

## 2. Structure

| Question | Answer |
|---|---|
| Format (shp / geojson / gpkg)? | |
| One file per admin level, or one file with a level column? | |
| CRS as declared in `.prj` / metadata? | |
| Geometry type (Polygon / MultiPolygon)? | |
| Attribute columns and types? | |
| Which column holds county / sub-county / ward names? | |
| Any numeric admin codes? (much better join keys than names) | |
| Encoding (UTF-8? Latin-1?) | |

## 3. Counts (national, before filtering)

| Level | Count found | Expected | Match? |
|---|---|---|---|
| Counties (adm1) | | 47 | |
| Sub-counties (adm2) | | ~290 national | |
| Wards (adm3) | | 1,450 national | |

## 4. Kitui filter check

| Question | Answer |
|---|---|
| Exact spelling of "Kitui" in the county column? | |
| Sub-counties within Kitui — count and names? | expected 8 |
| Wards within Kitui — count? | expected 40 — **verify against IEBC** |
| Any wards with null/blank names? | |
| Any duplicate ward names within a sub-county? | |

## 5. Geometry quality (QGIS pass)

| Check | Result |
|---|---|
| All geometries valid? (`Check Validity` tool) | |
| County outline visually correct vs. reference map? | |
| Ward polygons tile the county (no gaps/overlaps at glance)? | |
| Suspicious slivers or artifacts? | |

## 6. Surprises / decisions for the transform

*(anything unexpected, and what the transform must do about it)*

- 

## 7. Verdict

- [ ] Fit for ingestion as specified in sources.md
- [ ] Fit with caveats (listed above)
- [ ] Not fit — return to source selection