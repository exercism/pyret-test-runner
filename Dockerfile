# node:24.18.0-alpine3.24 == lts-alpine
FROM node:24.18.0-alpine3.24@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd
ARG PYRET_NPM_VERSION=0.0.90

# install packages required to run the tests
RUN apk add --no-cache \
    jq && \
    npm install -g pyret-npm@$PYRET_NPM_VERSION --ignore-scripts && \
    # purposefully not including these two expected dependencies
    sed -i "s/vegaMin = nodeRequire(.*);/vegaMin = {};/" /usr/local/lib/node_modules/pyret-npm/pyret-lang/build/phaseA/bundled-node-deps.js && \
    sed -i "s/canvas = require(\"canvas\");/canvas = {};/" /usr/local/lib/node_modules/pyret-npm/pyret-lang/build/phaseA/bundled-node-deps.js && \
    echo "module.exports = {};" > /usr/local/lib/node_modules/pyret-npm/node_modules/canvas/index.js

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
