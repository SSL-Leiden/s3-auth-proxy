# syntax=docker/dockerfile:1

# Use latest Alpine version by default
ARG ALPINE_VERSION=""
ARG ALPINE_TAG="${ALPINE_VERSION:-latest}"

ARG NODE_VERSION="20"

# Base image
# --------------------------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS base-node

# Builder image
# --------------------------------------------------------------------------------
FROM base-node AS builder

WORKDIR /build

COPY --link .yarn/ ./.yarn/
COPY --link .yarnrc.yml package.json yarn.lock ./

RUN yarn install --immutable

# Server image
# --------------------------------------------------------------------------------
FROM base-node AS app

RUN \
    mkdir -p /home/node/app && \
    chown node /home/node/app

WORKDIR /home/node/app

COPY --link package.json *.js ./
COPY --link --from=builder /build/node_modules/ ./node_modules/

USER node
ENTRYPOINT ["npm", "start"]
EXPOSE 8000/tcp
