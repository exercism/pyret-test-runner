FROM node:lts-alpine3.22
ARG PYRET_NPM_VERSION=0.0.50

# install packages required to run the tests
RUN apk add --no-cache \
    cairo-dev \
    coreutils \
    g++ \
    jq \
    pango \
    pkgconfig \
    pixman-dev \
    python3 \
    make \
    g++ && \
    npm install -g pyret-npm@$PYRET_NPM_VERSION

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
