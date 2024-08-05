#!/bin/bash

# 기본 변수 설정
SERVICE_DB="teable"
SERVICE_ROLE="teable"
SERVICE_ROLE_CONN_ID="teable"
## Supabase를 사용하는 경우 아래와 같이 변경
# SERVICE_ROLE_CONN_ID="teable.프로젝트ID"
SERVICE_ROLE_PW="fjBoJK7bc5Ko9VfJb3GEzcDrtgfRGy"

HOST="aws-0-ap-northeast-2.pooler.supabase.com"
MASTER_DATABASE="postgres"
SUPERUSER_ID="postgres"
SUPERUSER_CONNECTION_ID="postgres"
## Supabase를 사용하는 경우 아래와 같이 변경
# SUPERUSER_CONNECTION_ID="postgres.프로젝트ID"
SUPERUSER_PASSWORD="3IrrXZ4e9VaPqf4uuNsMnWDJdPhck7"

# 데이터베이스 연결 문자열 변수 설정
SUPERUSER_CONN="host=${HOST} dbname=${MASTER_DATABASE} user=${SUPERUSER_CONNECTION_ID} sslmode=require"
SERVICE_CONN="host=${HOST} dbname=${SERVICE_DB} user=${SERVICE_ROLE_CONN_ID} sslmode=require"

# 데이터베이스 연결 비밀번호 설정
export PGPASSWORD="${SUPERUSER_PASSWORD}"

#psql "${SUPERUSER_CONN}" -c "drop DATABASE ${SERVICE_DB}"
#psql "${SUPERUSER_CONN}" -c "drop ROLE ${SERVICE_ROLE}"
#psql "${SUPERUSER_CONN}" -c "drop user ${SERVICE_ROLE}"

# 데이터베이스 및 역할 생성
psql "${SUPERUSER_CONN}" -c "CREATE ROLE ${SERVICE_ROLE} WITH LOGIN PASSWORD '${SERVICE_ROLE_PW}';"
psql "${SUPERUSER_CONN}" -c "ALTER ROLE ${SERVICE_ROLE} CREATEDB;"

# `SERVICE_ROLE`을 현재 역할의 멤버로 추가
psql "${SUPERUSER_CONN}" -c "GRANT ${SERVICE_ROLE} TO ${SUPERUSER_ID};"

# `SERVICE_DB` 데이터베이스 생성 및 소유자 설정
psql "${SUPERUSER_CONN}" -c "CREATE DATABASE ${SERVICE_DB} WITH OWNER = ${SERVICE_ROLE};"

# `SERVICE_ROLE`에게 `SERVICE_DB` 데이터베이스에 대한 권한 부여
export PGPASSWORD="${SERVICE_ROLE_PW}"
psql "${SERVICE_CONN}" -c "GRANT CONNECT ON DATABASE ${SERVICE_DB} TO ${SERVICE_ROLE};"
psql "${SERVICE_CONN}" -c "GRANT ALL PRIVILEGES ON DATABASE ${SERVICE_DB} TO ${SERVICE_ROLE};"

# 기본 데이터베이스에 대한 권한 제거
export PGPASSWORD="${SUPERUSER_PASSWORD}"
psql "${SUPERUSER_CONN}" -c "REVOKE CONNECT ON DATABASE ${MASTER_DATABASE} FROM ${SERVICE_ROLE};"
psql "${SUPERUSER_CONN}" -c "REVOKE ALL PRIVILEGES ON DATABASE ${MASTER_DATABASE} FROM ${SERVICE_ROLE};"
psql "${SUPERUSER_CONN}" -c "ALTER ROLE ${SERVICE_ROLE} NOCREATEDB;"
# psql "${SUPERUSER_CONN}" -c "REVOKE ALL ON DATABASE postgres FROM PUBLIC;"

# 확인: `SERVICE_ROLE`이 접근할 수 있는 데이터베이스 목록 확인
export PGPASSWORD="${SERVICE_ROLE_PW}"
psql "${SERVICE_CONN}" -c "\l"

# 비밀번호 환경 변수 삭제
unset PGPASSWORD
