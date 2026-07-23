#!/usr/bin/env bash
set -euo pipefail

# Creates/updates the application databases and app-level users on RDS.
# Run after Terraform creates the RDS PostgreSQL instance.
# No passwords are stored in this script.
#
# Required environment variables:
#   RDS_PGHOST                 RDS PostgreSQL endpoint hostname
#   RDS_PGUSER                 RDS master/admin user, for example cms_admin
#   PGPASSWORD                 RDS master/admin password
#   AUTH_DB_PASSWORD           Password for auth_db_user
#   CHURCH_CORE_DB_PASSWORD    Password for church_core_db_user
#   DOCUMENT_DB_PASSWORD       Password for document_core_db_user
#
# Optional environment variables:
#   RDS_PGPORT                 Defaults to 5432
#   RDS_PGSSLMODE              Defaults to require

required_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

required_var RDS_PGHOST
required_var RDS_PGUSER
required_var PGPASSWORD
required_var AUTH_DB_PASSWORD
required_var CHURCH_CORE_DB_PASSWORD
required_var DOCUMENT_DB_PASSWORD

RDS_PGPORT="${RDS_PGPORT:-5432}"
RDS_PGSSLMODE="${RDS_PGSSLMODE:-require}"

export PGHOST="${RDS_PGHOST}"
export PGPORT="${RDS_PGPORT}"
export PGUSER="${RDS_PGUSER}"
export PGSSLMODE="${RDS_PGSSLMODE}"

create_database_if_missing() {
  local db="$1"
  if psql --dbname=postgres --tuples-only --no-align --command="SELECT 1 FROM pg_database WHERE datname='${db}';" | grep -q '^1$'; then
    echo "Database already exists: ${db}"
  else
    echo "Creating database: ${db}"
    psql --dbname=postgres --command="CREATE DATABASE ${db};"
  fi
}

upsert_user() {
  local user="$1"
  local password="$2"
  psql --dbname=postgres --set=app_user="${user}" --set=app_password="${password}" <<'SQL'
DO $$
DECLARE
  v_user text := :'app_user';
  v_password text := :'app_password';
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_user) THEN
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', v_user, v_password);
  ELSE
    EXECUTE format('ALTER ROLE %I WITH LOGIN PASSWORD %L', v_user, v_password);
  END IF;
END
$$;
SQL
}

grant_database_privileges() {
  local db="$1"
  local user="$2"

  psql --dbname=postgres --command="GRANT CONNECT ON DATABASE ${db} TO ${user};"

  psql --dbname="${db}" --set=app_user="${user}" <<'SQL'
DO $$
DECLARE
  v_user text := :'app_user';
BEGIN
  EXECUTE format('GRANT USAGE, CREATE ON SCHEMA public TO %I', v_user);
  EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO %I', v_user);
  EXECUTE format('GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO %I', v_user);
  EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I', v_user);
  EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO %I', v_user);
END
$$;
SQL
}

create_database_if_missing auth_db
create_database_if_missing church_core_db
create_database_if_missing document_core_db

upsert_user auth_db_user "${AUTH_DB_PASSWORD}"
upsert_user church_core_db_user "${CHURCH_CORE_DB_PASSWORD}"
upsert_user document_core_db_user "${DOCUMENT_DB_PASSWORD}"

grant_database_privileges auth_db auth_db_user
grant_database_privileges church_core_db church_core_db_user
grant_database_privileges document_core_db document_core_db_user

echo "RDS application databases and users are ready."
