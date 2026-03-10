FROM node:lts-alpine3.23
ARG PYRET_NPM_VERSION=0.0.90

# install packages required to run the tests
RUN apk add --no-cache \
    jq && \
    npm install -g pyret-npm@$PYRET_NPM_VERSION --ignore-scripts && \
    # purposefully not including these two expected dependencies
    sed -i "s/vegaMin = nodeRequire(.*);/vegaMin = {};/g" /usr/local/lib/node_modules/pyret-npm/pyret-lang/build/phaseA/bundled-node-deps.js && \
    sed -i "s/canvas = require(\"canvas\");/canvas = {};/g" /usr/local/lib/node_modules/pyret-npm/pyret-lang/build/phaseA/bundled-node-deps.js && \
    echo "module.exports = {};" > /usr/local/lib/node_modules/pyret-npm/node_modules/canvas/index.js

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
