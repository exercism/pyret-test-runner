# node:24.18.0-alpine3.24 == lts-alpine
FROM node:26.13.0-alpine3.24@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94

ENV PYRET_COMPILER=ts
ENV NODE_OPTIONS="--localstorage-file=/tmp/node-localstorage"
ENV PATH="/opt/pyret/node_modules/.bin:${PATH}"

WORKDIR /opt/pyret

COPY package.json package-lock.json .npmrc ./

# install packages required to run the tests
RUN apk add --no-cache \
    jq && \
    npm ci --ignore-scripts --no-audit --no-fund && \
    npm cache clean --force && \
    # purposefully not including these two expected dependencies
    sed -i "s/vegaMin = nodeRequire(.*);/vegaMin = {};/" node_modules/pyret-npm/pyret-lang/build/ts-compiler/bundled-node-deps.js && \
    sed -i "s/canvas = require(\"canvas\");/canvas = {};/" node_modules/pyret-npm/pyret-lang/build/ts-compiler/bundled-node-deps.js && \
    echo "module.exports = {};" > node_modules/pyret-npm/node_modules/canvas/index.js && \
    # Remove the legacy compiler
    rm -rf node_modules/pyret-npm/pyret-lang/build/phaseA

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
