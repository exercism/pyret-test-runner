FROM alpine:3.17
ARG PYRET_NPM_VERSION=0.0.27

# install packages required to run the tests
RUN apk add --no-cache jq coreutils nodejs npm && \
    npm install -g pyret-npm@$PYRET_NPM_VERSION

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
