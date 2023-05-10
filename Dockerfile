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

COPY .yarn ./.yarn
COPY .yarnrc.yml package.json yarn.lock ./

RUN yarn install --immutable

# Server image
# --------------------------------------------------------------------------------
FROM base-node AS app

RUN \
    mkdir /home/node/app && \
    chown node /home/node/app

USER node
WORKDIR /home/node/app

COPY package.json *.js ./
COPY --from=builder /build/node_modules ./node_modules

ENTRYPOINT ["npm", "start"]
EXPOSE 8000/tcp
