#!/bin/bash

# 서비스 관련 변수
SERVICE_DB="teable"
SERVICE_ROLE="teable"
SERVICE_ROLE_CONN_ID="teable"
SERVICE_ROLE_PW=""

# Supabase 호스트 및 관리자 정보
HOST=""
MASTER_DATABASE="postgres"
SUPERUSER_ID="postgres"
SUPERUSER_CONNECTION_ID="postgres"
SUPERUSER_PASSWORD=""

# 연결 문자열 구성
SUPERUSER_CONN="host=${HOST} dbname=${MASTER_DATABASE} user=${SUPERUSER_CONNECTION_ID} sslmode=require"
SERVICE_CONN="host=${HOST} dbname=${SERVICE_DB} user=${SERVICE_ROLE_CONN_ID} sslmode=require"

# 관리자 권한으로 접속
export PGPASSWORD="${SUPERUSER_PASSWORD}"

# 기존 리소스 제거 (선택)
# psql "${SUPERUSER_CONN}" -c "DROP DATABASE IF EXISTS ${SERVICE_DB};"
# psql "${SUPERUSER_CONN}" -c "DROP ROLE IF EXISTS ${SERVICE_ROLE};"

# 서비스 롤 생성
psql "${SUPERUSER_CONN}" -c "CREATE ROLE ${SERVICE_ROLE} WITH LOGIN PASSWORD '${SERVICE_ROLE_PW}' CREATEDB;"

# 롤을 superuser 그룹에 추가 (권한 공유 목적, 선택)
psql "${SUPERUSER_CONN}" -c "GRANT ${SERVICE_ROLE} TO ${SUPERUSER_ID};"

# 서비스 DB 생성
psql "${SUPERUSER_CONN}" -c "CREATE DATABASE ${SERVICE_DB} WITH OWNER = ${SERVICE_ROLE};"

# public 스키마 보안 강화
export PGPASSWORD="${SERVICE_ROLE_PW}"
psql "${SERVICE_CONN}" -c "REVOKE ALL ON SCHEMA public FROM PUBLIC;"
psql "${SERVICE_CONN}" -c "GRANT ALL ON SCHEMA public TO ${SERVICE_ROLE};"

# 관리자 권한 회복
export PGPASSWORD="${SUPERUSER_PASSWORD}"

# 불필요한 마스터 DB 권한 제거
psql "${SUPERUSER_CONN}" -c "REVOKE CONNECT ON DATABASE ${MASTER_DATABASE} FROM ${SERVICE_ROLE};"
psql "${SUPERUSER_CONN}" -c "REVOKE ALL PRIVILEGES ON DATABASE ${MASTER_DATABASE} FROM ${SERVICE_ROLE};"
psql "${SUPERUSER_CONN}" -c "ALTER ROLE ${SERVICE_ROLE} NOCREATEDB;"

# 최종 확인
export PGPASSWORD="${SERVICE_ROLE_PW}"
psql "${SERVICE_CONN}" -c "\dn"   # 스키마 목록 확인
psql "${SERVICE_CONN}" -c "\dt"   # 테이블 목록 (비어 있어야 정상)

# 환경 변수 제거
unset PGPASSWORD
