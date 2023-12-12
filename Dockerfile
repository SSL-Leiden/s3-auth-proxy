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
    chown -R node:node /home/node/

WORKDIR /home/node/app

# 1000 is the standard uid/gid for "node" in the NodeJS images
# https://github.com/nodejs/docker-node/blob/89afeedf0542d995e7be5e99e30719fc7b2f512d/Dockerfile-alpine.template#L5
COPY --link --chown=1000:1000 package.json *.js ./
COPY --link --chown=1000:1000 --from=builder /build/node_modules/ ./node_modules/

USER node
ENTRYPOINT ["npm", "start"]
EXPOSE 8000/tcp
