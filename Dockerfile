ARG NODE_ENV=production

FROM node:20-slim AS base

FROM base AS build
ENV NODE_ENV development
WORKDIR /build
COPY --chown=node:node package*.json ./
RUN npm ci --no-progress
COPY --chown=node:node . .
RUN NODE_ENV=production npm run build

FROM base AS production
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
RUN npm ci --no-progress --omit=dev && npm cache clean --force --loglevel=error
COPY --from=build --chown=node:node /build/dist ./dist

FROM base AS development
ENV NODE_ENV $NODE_ENV
USER node
WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
RUN npm ci

FROM $NODE_ENV
EXPOSE 3000
COPY --chown=node:node . .
USER node
CMD ["node", "./dist/index.js"]
