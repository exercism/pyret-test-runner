FROM alpine:3.17

# install packages required to run the tests
RUN apk add --no-cache jq coreutils nodejs npm && \
    npm install -g pyret-npm

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
