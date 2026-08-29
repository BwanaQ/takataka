# Taka Taka — Data Source Registry

**Status:** Sprint 2 — Kitui baseline
**Last updated:** *(set on commit)*
**Owner:** *(your name)*

---

## 1. Purpose

This document is the authoritative record of every external dataset Taka Taka
ingests, where it came from, under what licence, and what we know about its
limitations.

It exists because of two commitments in the PRD:

> **Data before AI** — AI interprets trustworthy data; it does not replace
> the system of record.
>
> **Evidence before claims** — every important number has provenance.

Operationally this becomes a single rule:

> If we cannot identify where a datum came from, we do not ingest it as
> authoritative data.

---

## 2. How to use this document

**Before acquiring any dataset:**

1. Add an entry in §5 first, even if fields are `TBD`.
2. Confirm the licence permits our use. `unknown` is acceptable; silence is not.
3. Record the direct download URL, not the landing page.
4. Get the entry to `status: locked` before writing an ingestion script.

**After ingestion:**

5. Fill in `acquired_at`, `record_count` and `checksum`.
6. Link the inspection note in `docs/data/evidence/inspection-notes/`.
7. Move `status` to `ingested`.

**Never:**

- Ingest a dataset that has no entry here.
- Change a source URL in code without changing it here first.
- Mark something `authoritative` because it looks official. Check the publisher.

---

## 3. Field schema

| Field | Meaning |
|---|---|
| `id` | Stable slug used as `DataSource.slug` in the database. Never reused or renamed. |
| `name` | Human-readable title, as the publisher names it. |
| `publisher` | The institution that produced the data. |
| `publisher_type` | `government` \| `ngo` \| `community` \| `commercial` \| `academic` |
| `source_url` | Canonical landing page. |
| `download_url` | Direct link to the file(s). `TBD` until locked. |
| `licence` | Explicit licence name, or `unknown`. |
| `licence_verified` | `true` only if a human has read the terms. |
| `access_method` | `download` \| `api` \| `scrape` \| `manual_extract` |
| `original_format` | `shp` \| `geojson` \| `csv` \| `xlsx` \| `pdf` \| `osm.pbf` \| `html` |
| `spatial` | `yes` \| `administrative` \| `no` |
| `srid` | EPSG code of the source CRS, or `n/a`. |
| `coverage` | Geographic extent e.g. `national`, `county:kitui`. |
| `temporal_reference` | The period the data describes. Not the download date. |
| `acquired_at` | ISO date of download. Filled at ingestion time. |
| `record_count` | Row / feature count after ingestion. Filled at ingestion time. |
| `checksum` | SHA256 of the raw file. Filled at ingestion time. |
| `data_class` | `authoritative` \| `estimated` \| `user_reported` \| `verified_event` |
| `priority` | `critical` \| `high` \| `medium` \| `later` |
| `sprint` | Sprint in which this source is ingested. |
| `status` | `candidate` \| `locked` \| `ingested` \| `rejected` \| `superseded` |

### Status meanings

| Status | Meaning |
|---|---|
| `candidate` | Identified, not yet verified. Do not write code against it. |
| `locked` | URL, licence and format confirmed. Safe to build an ingestion script. |
| `ingested` | In PostGIS with an `IngestionRun` record. |
| `rejected` | Investigated and deliberately not used. Keep the entry — the reason matters. |
| `superseded` | Replaced by a newer source. Keep for historical provenance. |

### A note on `data_class`

`authoritative` means this is what the publisher published — not that it is
true.

OSM is `authoritative` as OpenStreetMap. It is not a government record. A
county development plan is `authoritative` as a statement of intent; the
facilities it describes may not yet exist. Where a document mixes fact and
aspiration, tag per extracted record, not per source.

Anything Taka Taka calculates — waste generation from population, opportunity
scores, impact figures — is `estimated` and must carry its methodology. We
never promote a derived figure to `authoritative`.

---

## 4. Registry index

| ID | Name | Class | Priority | Spatial | Status |
|---|---|---|---|---|---|
| `kenya-admin-boundaries` | Kenya admin boundaries (county / sub-county / ward) | authoritative | 🔴 critical | yes | `candidate` |
| `knbs-census-2019` | 2019 Kenya Population and Housing Census | authoritative | 🔴 critical | administrative | `candidate` |
| `osm-kenya-geofabrik` | OpenStreetMap Kenya extract (Geofabrik) | authoritative (as OSM) | 🟠 high | yes | `candidate` |
| `kitui-waste-evidence` | Kitui waste infrastructure evidence inventory | mixed | 🔴 critical | sometimes | `candidate` |

Sources considered but not scheduled for Sprint 2 are listed in §6.

---

## 5. Source entries

---

### 5.1 `kenya-admin-boundaries`

```yaml
id: kenya-admin-boundaries
name: Kenya Subnational Administrative Boundaries (COD-AB)
publisher: OCHA / IEBC / KNBS (verify chain on HDX)
publisher_type: government
source_url: https://data.humdata.org/dataset/cod-ab-ken
download_url: TBD
licence: TBD (HDX CODs are typically CC-BY 3.0 IGO — verify)
licence_verified: false
access_method: download
original_format: shp
spatial: yes
srid: TBD (verify .prj — some Kenyan sources ship in Arc 1960 / UTM 37S)
coverage: national → filtered to county:kitui
temporal_reference: post-2013 devolved boundaries (confirm vintage)
acquired_at: null
record_count: null
checksum: null
data_class: authoritative
priority: critical
sprint: 2
status: candidate
```

**Why this source.**
Every other dataset in Taka Taka joins to administrative geography. This is
the spine of the system and is ingested first. Everything else conforms to it.

**Expected structure.**

```text
adm0  Kenya
adm1  County         (47 nationally)
adm2  Sub-county     (Kitui: 8)
adm3  Ward           (Kitui: expected ~40 — verify against IEBC before locking)
```

**Open decision.**

> Which publisher is our canonical boundary authority?
> **Recommendation:** the HDX COD-AB dataset, because it is the version most
> Kenyan data products align to and it is reliably accessible. Record IEBC as
> the upstream reference.
> *Decided: (pending — record date and rationale when resolved)*

**Known risks.**

- Competing boundary sources (IEBC, KNBS, county GIS) disagree at ward
  level. Pick one and record it. Do not mix sources across admin levels.
- Sub-county ≠ constituency in general. In Kitui they appear to align
  (8 of each) but verify; do not assume.
- Some Kenyan shapefiles are distributed in Arc 1960 UTM Zone 37S.
  Check the `.prj` file before assuming WGS84.
- Name encoding inconsistencies (case, whitespace, non-ASCII) become join
  key problems for every downstream dataset. Normalise here, once.

**Validation expectations.**

```text
counties after Kitui filter     == 1
sub-counties                    == 8
wards                           verify count before locking
all geometries valid            ST_IsValid = true
all geometries in EPSG:4326     after transform
no duplicate ward names within a sub-county
union of ward geometries ≈ county boundary (small tolerance)
```

**Inspection note:** `docs/data/evidence/inspection-notes/admin-boundaries.md`

---

### 5.2 `knbs-census-2019`

```yaml
id: knbs-census-2019
name: 2019 Kenya Population and Housing Census
publisher: Kenya National Bureau of Statistics
publisher_type: government
source_url: https://www.knbs.or.ke/reports/kenya-census-2019/
download_url: TBD (identify which volume carries ward-level tables)
licence: unknown — Kenyan government publication; verify reuse terms
licence_verified: false
access_method: download + manual_extract
original_format: pdf (xlsx companion if available)
spatial: administrative
srid: n/a
coverage: national → county:kitui, subcounty:*, ward:*
temporal_reference: 2019
acquired_at: null
record_count: null
checksum: null
data_class: authoritative
priority: critical
sprint: 2
status: candidate
```

**Why this source.**
The only authoritative population and household figures at ward level.
Population is context for the waste system — it is not a proxy for waste
generation.

**Fields we want.**

```text
county_name
subcounty_name
ward_name
population_total
population_male
population_female
households
average_household_size
area_km2          (if published)
density           (if published; otherwise derive and label estimated)
```

**⚠ The rule that matters most for this source.**

We do not compute waste generation here. It would be trivial to write:

```python
# DO NOT DO THIS in the ingestion pipeline
waste_kg_day = population * 0.5
```

That figure would be our model, not KNBS data, and once it sits in a column
next to authoritative figures the distinction is permanently lost. Population
is ingested as published. Any generation estimate is a separate, later,
explicitly `estimated` layer that records its coefficient, its source and its
assumptions.

**Extraction approach.**

Manual extraction to CSV, committed to `data/raw/knbs-census-2019/`, with a
`_meta.md` recording the exact volume, table and page numbers for every
figure. This is Decision #4 in §8 — a deliberate exception to the
"transformations are code" rule, bounded and documented.

**Known risks.**

- PDF extraction: multi-page tables with merged cells produce plausible but
  wrong numbers if automated. Every extracted table requires a spot check.
- Ward name mismatch with boundary file: expected. All variants go to
  `docs/data/evidence/name-reconciliation.md`.
- Sub-county totals vs. ward sums may disagree due to rounding in the
  published document. Record the delta; do not silently reconcile.

**Validation expectations.**

```text
ward rows                             == ward count from kenya-admin-boundaries
every ward_name resolves via name_key to a boundary ward
population_total                      > 0 for every ward
sum(ward populations)                 ≈ published county total (record delta)
households                            > 0
average_household_size                between 1 and 15
population_male + population_female   ≈ population_total
```

**Inspection note:** `docs/data/evidence/inspection-notes/knbs-population.md`

---

### 5.3 `osm-kenya-geofabrik`

```yaml
id: osm-kenya-geofabrik
name: OpenStreetMap Kenya extract (Geofabrik)
publisher: OpenStreetMap contributors, distributed by Geofabrik
publisher_type: community
source_url: https://download.geofabrik.de/africa/kenya.html
download_url: https://download.geofabrik.de/africa/kenya-latest.osm.pbf
licence: Open Database Licence (ODbL) 1.0
licence_verified: true
access_method: download
original_format: osm.pbf
spatial: yes
srid: 4326
coverage: national → clipped to county:kitui
temporal_reference: live (rolling — record PBF internal timestamp at download)
acquired_at: null
record_count: null
checksum: null
data_class: authoritative (as OpenStreetMap — see §3 note)
priority: high
sprint: 2
status: candidate
```

**Why this source.**
Roads and settlements are the operational substrate of the Waste Atlas
(Sprint 5) and any proximity or accessibility analysis. OSM is the only
realistically available source at this granularity for Kitui.

**Layers extracted in Sprint 2.**

```text
roads        highway = motorway | trunk | primary | secondary |
                       tertiary | unclassified | residential | track
settlements  place = city | town | village | hamlet | suburb
```

Waste-relevant tags (`amenity=waste_disposal`, `landuse=landfill`,
`amenity=recycling`) are queried and recorded in
`docs/data/evidence/kitui-waste.md §3` but are not treated as a facility
dataset — OSM coverage of waste infrastructure in rural Kenya is too sparse
to be representative.

**⚠ Licence obligation — this is a product requirement.**

ODbL 1.0 requires:

- **Attribution:** "© OpenStreetMap contributors" must be visible wherever
  OSM-derived data is displayed. This is a Sprint 5 frontend acceptance
  criterion. Add it to the Sprint 5 backlog now.
- **Share-alike:** any derivative database we publish must be under ODbL.
  This constrains future open-data exports and must be flagged before we
  publish anything.

**Known risks.**

- Rural ward coverage is thin. Absence of a feature in OSM is not evidence
  of absence on the ground. This caveat must survive into the Atlas.
- The dataset changes daily. Record the PBF's internal timestamp
  (`osmium fileinfo`), not just the download date.
- The Kenya PBF is large and is gitignored. The fetch must be scripted and
  documented so any developer can reproduce it.

**Validation expectations.**

```text
clipped extent within Kitui bounding box (small buffer allowed)
road features        > 0 in every sub-county (flag any with zero)
settlement features  > 0
all geometries valid
all geometries in EPSG:4326
PBF internal timestamp recorded in IngestionRun
```

**Inspection note:** `docs/data/evidence/inspection-notes/osm-kitui.md`

---

### 5.4 `kitui-waste-evidence`

```yaml
id: kitui-waste-evidence
name: Kitui waste infrastructure and services — evidence inventory
publisher: mixed (County Government of Kitui, NEMA, KCIPD, procurement notices)
publisher_type: government
source_url:
  - https://kitui.go.ke/
  - https://kcipd.kitui.go.ke/
  - https://nema.go.ke/
download_url: none — evidence is documentary
licence: varies per document; treat conservatively
licence_verified: false
access_method: manual_extract
original_format: pdf | html
spatial: sometimes
srid: n/a
coverage: county:kitui
temporal_reference: mixed (2022–2026)
acquired_at: null
record_count: null
checksum: null
data_class: mixed — tag per extracted record
priority: critical
sprint: 2
status: candidate
```

**Why this source.**
This is the dataset the product most depends on, and the one that does not
exist in clean form. Handling it honestly is the most important thing Sprint 2
does.

**⚠ Sprint 2 does not produce a Kitui waste-facility dataset.**

There is no authoritative downloadable inventory of waste infrastructure in
Kitui County. The temptation is to assemble one from fragments and present
the result as data. That would fabricate exactly the kind of unprovenanced
claim the PRD exists to prevent.

**Sprint 2 produces instead:**

1. An evidence inventory (`docs/data/evidence/kitui-waste.md`).
2. Extracted facility records only where a specific document names a specific
   site, with per-record citation (document, page, quoted text), `confidence`
   and `existence_status`.
3. A gaps list — what we searched for and could not find.

**Per-record fields for any extracted facility.**

```text
name
facility_type          dumpsite | transfer | mrf | landfill | collection_point | unknown
location_description   as written in the source
geometry               only if the source provides coordinates or unambiguous location
location_confidence    exact | approximate | ward_only | unknown
existence_status       operational | planned | proposed | historical | unknown
source_document
source_page
source_quote
data_class             authoritative | estimated
notes
```

**Documents to review.**

| # | Document | Publisher | Reviewed |
|---|---|---|---|
| D1 | Kitui County Integrated Development Plan | County Govt of Kitui | ☐ |
| D2 | Kitui County Annual Development Plan 2026/27 | County Govt of Kitui | ☐ |
| D3 | Kitui Municipality Solid Waste Management Plan | Kitui Municipality | ☐ |
| D4 | KCIPD infrastructure projects dashboard | County Govt of Kitui | ☐ |
| D5 | NEMA EIA/ESIA reports referencing Kitui waste | NEMA | ☐ |
| D6 | Kitui tender archive — waste-related tenders | County Govt of Kitui | ☐ |
| D7 | Published research on SWM in Kitui Municipality | Academic | ☐ |

**Known risks.**

- Hallucination risk is highest here. Every claim needs a source quote.
  If no quote can be produced, the record does not exist.
- Aspirational vs. actual: a development plan describing a proposed MRF is
  evidence of intent, not evidence of infrastructure. Use `existence_status`.
- Staleness: a facility named in a 2022 plan may not operate today.
- Licence ambiguity: we extract facts (not copyrightable) and cite the source
  in every case.

**Validation expectations.**

```text
every extracted record has source_document and source_quote
every record has existence_status (no nulls)
every record with geometry has location_confidence
gaps list is non-empty and dated
```

**Evidence file:** `docs/data/evidence/kitui-waste.md`

---

## 6. Considered but not scheduled for Sprint 2

Kept deliberately — knowing why something was excluded is as useful as
knowing why it was included.

| Source | Why not in Sprint 2 | Revisit |
|---|---|---|
| WorldPop gridded population | Modelled, not measured. Useful for intra-ward distribution later but would compete with KNBS as population authority. | Sprint 5 |
| Kenya Open Data Portal | Availability and currency uncertain. | Sprint 2 discovery pass |
| Copernicus / Sentinel imagery | No Sprint 2 use case; significant processing overhead. | Post-MVP |
| ILRI / DEPHA GIS layers | Likely superseded by COD-AB boundaries. | If boundaries prove inadequate |
| NEMA licensed-handler register | Very valuable if it exists in structured form. Investigate. | Sprint 2 discovery pass |
| Commercial waste operator data | Requires partnership, not acquisition. | Post-MVP |

---

## 7. Change log

| Date | Change | By |
|---|---|---|
| *(pending)* | Registry created; four Sprint 2 sources entered as `candidate` | |

---

## 8. Decision log

Structural decisions recorded so they are not revisited silently.

| # | Decision | Rationale | Date |
|---|---|---|---|
| 1 | Registry is markdown-only for Sprint 2 | Four sources; narrative context matters more than machine-readability at this scale. Promote YAML blocks to `data/sources/registry.yml` when `register_source.py` is written. | *(pending)* |
| 2 | All spatial data stored in EPSG:4326 | Single CRS across the platform; Leaflet/MapLibre native. Projected CRS used only for area/distance computation, never for storage. | *(pending)* |
| 3 | Canonical boundary publisher | *(pending — see §5.1 open decision)* | |
| 4 | KNBS extracted manually to committed CSV | Automated census PDF parsing is unreliable and out of Sprint 2 scope. A documented manual extraction has better provenance than an unchecked automated parse. | *(pending)* |
| 5 | No waste-generation estimates in Sprint 2 | Derived figures must be separately modelled and labelled `estimated`. Population ≠ waste generation. | *(pending)* |

