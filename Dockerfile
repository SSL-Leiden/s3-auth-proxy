ARG NODE_VERSION="16"

# Builder
FROM node:$NODE_VERSION-alpine AS builder

WORKDIR /build

COPY .yarn ./.yarn
COPY .yarnrc.yml ./
COPY package.json ./
COPY yarn.lock ./

RUN yarn install --immutable

# Server
FROM node:$NODE_VERSION-alpine AS app

RUN \
    mkdir /home/node/app \
    && chown node /home/node/app
USER node
WORKDIR /home/node/app

COPY *.js ./
COPY package.json ./
COPY --from=builder /build/node_modules ./node_modules

ENTRYPOINT ["npm", "start"]
EXPOSE 8000/tcp
