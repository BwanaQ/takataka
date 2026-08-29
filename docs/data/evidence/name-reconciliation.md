# Administrative Name Reconciliation — Kitui

**Status:** Sprint 2
**Purpose:** the single authoritative mapping between administrative-unit
name variants across our sources.

---

## Why this file exists

Every dataset spells administrative names differently:

```text
boundary file:   KITUI CENTRAL
KNBS census:     Kitui Central
county PDF:      Kitui central Sub County
```

Joins on raw names fail silently — a ward that doesn't match simply drops
out, and totals quietly shrink. All reconciliation therefore happens **here,
once**, and every pipeline uses this mapping. No pipeline may contain its own
ad-hoc name fixes.

## Rules

1. The **canonical name** for every unit comes from the locked boundary
   source (`kenya-admin-boundaries`). Whatever it says, we say.
2. Every other source's spelling is recorded as a **variant** mapped to the
   canonical name.
3. Join keys are `name_key`: canonical name → UPPERCASE, trimmed, internal
   whitespace collapsed, punctuation removed.
4. An unmatched name is **never silently dropped**. It is recorded in §4
   and resolved by a human.

---

## 1. Sub-counties (expected: 8)

Canonical list pending boundary ingestion. Populate from the shapefile, not
from memory or websites.

| canonical_name | name_key | KNBS variant | County-doc variant | Notes |
|---|---|---|---|---|
| *(pending)* | | | | |

Expected members (verify against boundary file before locking):
Kitui Central, Kitui East, Kitui Rural, Kitui South, Kitui West,
Mwingi Central, Mwingi North, Mwingi West.

> ⚠ **Sub-county vs constituency.** These often share names in Kenya but are
> different unit types. Confirm which the boundary file actually contains
> and record the answer here: ______

## 2. Wards (expected: 40 — verify)

| canonical_name | name_key | sub_county | KNBS variant | Notes |
|---|---|---|---|---|
| *(pending boundary ingestion)* | | | | |

## 3. Normalisation function

Reference implementation — every pipeline must use this exact logic
(it will live in shared code; recorded here as specification):

```python
import re

def name_key(raw: str) -> str:
    s = raw.strip().upper()
    s = re.sub(r"[^\w\s]", "", s)      # drop punctuation
    s = re.sub(r"\s+", " ", s)         # collapse whitespace
    s = re.sub(r"\s+(SUB\s*COUNTY|WARD)$", "", s)  # strip unit suffixes
    return s
```

## 4. Unresolved names

Names encountered in any source that did not match. Every row here blocks
sign-off of the dataset that produced it.

| Raw name | Source | Where seen | Candidate match | Resolution | Date |
|---|---|---|---|---|---|
| | | | | | |

---

*Change log*

| Date | Change |
|---|---|
| (pending) | File created; awaiting boundary ingestion for canonical lists |