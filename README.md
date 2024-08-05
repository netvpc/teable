# teable

[Traefik 설정](https://github.com/navystack/traefik)이 선행되어야 합니다.

## 1. PostgreSQL 준비하기 / Prepare PostgreSQL (You can keep)

Modifiy `prepare.sh` and run

```bash
bash ./prepare.sh
```

## 2. `.env` 수정하기 / Modify `.env`

```bash
cp ./example.env ./.env
```

## 3. 도커 네트워크 생성하기 Create docker network

```bash
docker network create teable-network
```
