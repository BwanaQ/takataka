# Inspection Note — osm-kenya-geofabrik

**Source registry entry:** `../../sources.md` §5.3
**Raw file(s):** `data/raw/osm-kenya-geofabrik/<date>/kenya-latest.osm.pbf` (gitignored)
**Inspected by / date:** *(pending)*

---

## 1. Acquisition record

| Field | Value |
|---|---|
| Download URL | https://download.geofabrik.de/africa/kenya-latest.osm.pbf |
| Date acquired | |
| File size | |
| SHA256 | |
| **PBF internal timestamp** (`osmium fileinfo`) | ← required; OSM is live data |

## 2. Clip to Kitui

| Question | Answer |
|---|---|
| Clip boundary used (must be the ingested `kenya-admin-boundaries` county polygon) | |
| Tool + version (osmium / osmconvert) | |
| Exact command used | |
| Output file + size | |

## 3. Feature counts after extraction

### Roads (`highway=` in agreed filter set)

| highway value | Count | Notes |
|---|---|---|
| trunk | | |
| primary | | |
| secondary | | |
| tertiary | | |
| unclassified | | |
| residential | | |
| track | | |

### Settlements (`place=`)

| place value | Count | Notes |
|---|---|---|
| town | | |
| village | | |
| hamlet | | |
| suburb | | |

### Waste-relevant tags (→ copy findings to `../kitui-waste.md` §3)

| Tag | Count | Notes |
|---|---|---|
| amenity=waste_disposal | | |
| landuse=landfill | | |
| amenity=recycling | | |

## 4. Coverage sanity (QGIS pass over ward layer)

| Check | Result |
|---|---|
| Roads present in every sub-county? | list any with zero: |
| Kitui town street grid visibly denser than rural wards? (expected) | |
| Settlement points where towns actually are? | |
| Obvious geometry errors? | |

> Remember: thin coverage in a rural ward is an OSM completeness artifact,
> not evidence of absence. Note anything that later needs a coverage caveat
> in the Waste Atlas.

## 5. Surprises / decisions for the transform

- 

## 6. Verdict

- [ ] Fit for ingestion
- [ ] Fit with caveats
- [ ] Not fit