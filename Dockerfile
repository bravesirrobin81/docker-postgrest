# Build postgrest
FROM ubuntu:16.04

RUN BUILD_DEPS="curl ca-certificates build-essential git" && \
    apt-get -qq update && \
    apt-get -qqy --no-install-recommends install \
    $BUILD_DEPS \
    libpq-dev && \
    curl -sSL https://get.haskellstack.org/ | sh && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH $PATH:/root/.local/bin

RUN git clone -b v5.2.0 https://github.com/PostgREST/postgrest.git
RUN cd postgrest && stack setup
RUN cd postgrest && stack build --profile


# Build deployable image
FROM amazonlinux:latest

USER root

RUN yum -y update --exclude=filesystem && \
    yum -y install shadow-utils postgresql-libs jq && \
    groupadd -g 1000 postgrest && \
    adduser -g 1000 -u 1000 -s /bin/bash -d /home/postgrest postgrest && \
    yum -y clean all

ADD postgrest.conf /etc
COPY --from=0 /postgrest/.stack-work/install/x86_64-linux/lts-9.6/8.0.2/bin/postgrest /usr/local/bin/postgrest
ADD getKeycloakKey.sh /usr/local/bin/getKeycloakKey.sh

RUN chmod +x /usr/local/bin/getKeycloakKey.sh /usr/local/bin/postgrest

USER 1000

ENV PGRST_DB_URI= \
    PGRST_DB_SCHEMA=public \
    PGRST_DB_ANON_ROLE= \
    PGRST_DB_POOL=100 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_SERVER_HOST=*4 \
    PGRST_SERVER_PORT=3000 \
    PGRST_SERVER_PROXY_URI= \
    PGRST_JWT_SECRET= \
    PGRST_SECRET_IS_BASE64=false \
    PGRST_JWT_AUD= \
    PGRST_MAX_ROWS= \
    PGRST_PRE_REQUEST= \
    PGRST_ROLE_CLAIM_KEY=".role"

CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
