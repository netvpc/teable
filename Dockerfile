FROM node:lts-bookworm AS deps
RUN apt-get update \
  && apt-get -y --no-install-recommends install tini

FROM ghcr.io/teableio/teable:latest AS runner
COPY --link --from=deps /usr/bin/tini /usr/bin/tini
ENTRYPOINT ["tini", "--", "node", "apps/nestjs-backend/dist/index.js"]
