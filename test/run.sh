#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")" && pwd)
fresh="kor_search_fresh_$$"
upgrade="kor_search_upgrade_$$"
restored="kor_search_restored_$$"
trap 'dropdb --if-exists "$fresh"; dropdb --if-exists "$upgrade"; dropdb --if-exists "$restored"' EXIT

createdb "$fresh"
psql -X -v ON_ERROR_STOP=1 -d "$fresh" -f "$root/native.sql" -f "$root/test_cases.sql"
createdb "$upgrade"
psql -X -v ON_ERROR_STOP=1 -d "$upgrade" -f "$root/upgrade.sql" -f "$root/restored.sql"
createdb "$restored"
pg_dump -d "$upgrade" | psql -X -v ON_ERROR_STOP=1 -d "$restored" -q
psql -X -v ON_ERROR_STOP=1 -d "$restored" -f "$root/restored.sql"
