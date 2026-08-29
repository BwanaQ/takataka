# data/

Working data directory for Taka Taka. **Read
[`docs/data/conventions.md`](../docs/data/conventions.md) before touching
anything here.**

```text
data/
├── raw/          # immutable acquisitions — never edit these files
└── processed/    # transformation outputs — regenerable from raw + code
```

Quick rules:

1. Nothing goes in `raw/` without an entry in `docs/data/sources.md`.
2. Every acquisition gets a `_meta.md` beside it (see conventions §4).
3. Large files (OSM PBF) are gitignored — fetch scripts recreate them.
4. Never edit raw files. Fixes happen in transformation code.
5. Everything in `processed/` must be regenerable by running the pipelines.
   If you can't delete `processed/` without fear, something is wrong.