# Changelog

## 2.0.0

- Add native Korean/English document analysis (Rust, Lindera, ko-dic) and a versioned, position-aware vector for standard PostgreSQL GIN.
- Add scoped, bidirectional alias expansion at query time, optional example dictionaries, and backup support for user-managed aliases.
- Default to 2.0.0 with a tested 1.0.0 → 1.1.0 → 2.0.0 update path. Require UTF-8 for the new analyzer. PostgreSQL 16–18 CI verifies fresh installs, upgrades, index usage, and dump/restore.
- Retain the four row-wise legacy functions for existing callers; new applications should use the indexed API. Managed services without permission to install native modules are not supported by 2.0.

## 1.1.0 (upgrade step)

- Bind C dictionary lookups rather than interpolating SQL, remove fixed buffers, construct typed phrase queries, and resolve legacy dictionary tables in the extension schema.
- Remove the unused legacy trigram index and record added legacy dictionary rows for dump/restore. Direct 1.1 and 2.0 installs do not require pg_trgm.
