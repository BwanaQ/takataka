# Inspection Note — knbs-census-2019

**Source registry entry:** `../../sources.md` §5.2
**Raw file(s):** `data/raw/knbs-census-2019/<date>/…`
**Inspected by / date:** *(pending)*

> This source is extracted manually (sources.md Decision #4). This note is
> therefore both the inspection record AND the extraction provenance record.
> It must be complete enough that someone else could re-verify every number.

---

## 1. Acquisition record

| Field | Value |
|---|---|
| Volume(s) downloaded | *(confirm which volume carries ward-level tables)* |
| Download URL(s) | |
| Date acquired | |
| File name(s) / size | |
| SHA256 | |

## 2. Which tables carry what we need

| Needed field | Volume | Table | Page(s) | Notes |
|---|---|---|---|---|
| Ward population totals | | | | |
| Population male/female | | | | |
| Households | | | | |
| Average household size | | | | |
| Area / density (if published) | | | | |

## 3. Extraction log

One row per extraction session. The output CSV lives at
`data/raw/knbs-census-2019/<date>/kitui_ward_population_extracted.csv`.

| Date | Pages extracted | Rows produced | Extracted by | Double-checked against PDF? |
|---|---|---|---|---|
| | | | | ☐ |

**Extraction rules used:**

- Numbers copied exactly as published (no rounding, no reconciliation).
- Thousands separators removed in CSV; no other alteration.
- Ward names copied exactly as printed → variants go to
  `../name-reconciliation.md`.
- Anything illegible or ambiguous recorded below, not guessed.

## 4. Cross-checks

| Check | Published value | Sum of extracted rows | Delta | Acceptable? |
|---|---|---|---|---|
| Kitui County total population | | | | |
| Each sub-county total vs. its wards | | | | |
| male + female ≈ total (per ward) | | | | |

> Deltas are recorded, not silently fixed. If KNBS's own tables disagree
> internally, that fact is provenance too.

## 5. Ward-name matching

| Question | Answer |
|---|---|
| Ward rows extracted | expected 40 |
| Matched to boundary wards via name_key | /40 |
| Unmatched (listed in name-reconciliation.md §4) | |

## 6. Ambiguities / illegible cells

| Location (vol/table/page/row) | Issue | Resolution |
|---|---|---|
| | | |

## 7. Verdict

- [ ] Extracted CSV is a faithful transcription; fit for transform + load
- [ ] Fit with caveats (deltas recorded above)
- [ ] Not fit — re-extract