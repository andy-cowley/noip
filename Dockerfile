# This is a multi stage Dockefile.
# This stage will be discarded after the build
FROM alpine:latest as intermediate

WORKDIR /usr/src/app

RUN apk add --no-cache make g++ ca-certificates wget shadow &&  \
    useradd -s /bin/sh noipuser
RUN echo "Downloading from https://www.noip.com/client/linux/noip-duc-linux.tar.gz" && \
    wget https://www.noip.com/client/linux/noip-duc-linux.tar.gz && \
    tar -xvzf noip-duc-linux.tar.gz
RUN echo "Building on arch: $(uname -m)" && \
    cd $(find . -maxdepth 1 -mindepth 1 -type d) && \
    make && \
    cp noip2 /usr/bin

FROM alpine:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="NoIP" \
    org.label-schema.description="Dynamic DNS client to update NoIP services." \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/andy-cowley/noip" \
    org.label-schema.license="MIT" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

COPY --from=intermediate /usr/bin/noip2 /usr/bin/
COPY --from=intermediate /etc/group /etc/
COPY --from=intermediate /etc/shadow /etc/
COPY --from=intermediate /etc/passwd /etc/

USER noipuser

ENTRYPOINT [ "/usr/bin/noip2 -d" ]
