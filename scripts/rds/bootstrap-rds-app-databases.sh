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
#   CHURCH_CORE_DB_PASSWORD    Password for church_db_user
#   DOCUMENT_DB_PASSWORD       Password for document_db_user
#
# Optional environment variables:
#   RDS_PGPORT                 Defaults to 5432
#   RDS_PGSSLMODE              Defaults to require

: "${RDS_PGHOST:?Missing required environment variable: RDS_PGHOST}"
: "${RDS_PGUSER:?Missing required environment variable: RDS_PGUSER}"
: "${PGPASSWORD:?Missing required environment variable: PGPASSWORD}"
: "${AUTH_DB_PASSWORD:?Missing required environment variable: AUTH_DB_PASSWORD}"
: "${CHURCH_CORE_DB_PASSWORD:?Missing required environment variable: CHURCH_CORE_DB_PASSWORD}"
: "${DOCUMENT_DB_PASSWORD:?Missing required environment variable: DOCUMENT_DB_PASSWORD}"

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
    psql --dbname=postgres --set=app_db="${db}" --command='CREATE DATABASE :"app_db";'
  fi
}

upsert_user() {
  local user="$1"
  local password="$2"

  if psql --dbname=postgres --tuples-only --no-align --command="SELECT 1 FROM pg_roles WHERE rolname='${user}';" | grep -q '^1$'; then
    echo "Updating role password: ${user}"
    psql --dbname=postgres \
      --set=app_user="${user}" \
      --set=app_password="${password}" \
      --command='ALTER ROLE :"app_user" WITH LOGIN PASSWORD :'\''app_password'\'';'
  else
    echo "Creating role: ${user}"
    psql --dbname=postgres \
      --set=app_user="${user}" \
      --set=app_password="${password}" \
      --command='CREATE ROLE :"app_user" LOGIN PASSWORD :'\''app_password'\'';'
  fi
}

grant_database_privileges() {
  local db="$1"
  local user="$2"

  echo "Granting privileges on ${db} to ${user}"

  psql --dbname=postgres \
    --set=app_db="${db}" \
    --set=app_user="${user}" \
    --command='GRANT CONNECT ON DATABASE :"app_db" TO :"app_user";'

  psql --dbname="${db}" --set=app_user="${user}" <<'SQL'
GRANT USAGE, CREATE ON SCHEMA public TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :"app_user";
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO :"app_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
SQL
}

create_database_if_missing auth_db
create_database_if_missing church_core_db
create_database_if_missing document_core_db

upsert_user auth_db_user "${AUTH_DB_PASSWORD}"
upsert_user church_db_user "${CHURCH_CORE_DB_PASSWORD}"
upsert_user document_db_user "${DOCUMENT_DB_PASSWORD}"

grant_database_privileges auth_db auth_db_user
grant_database_privileges church_core_db church_db_user
grant_database_privileges document_core_db document_db_user

echo "RDS application databases and users are ready."
