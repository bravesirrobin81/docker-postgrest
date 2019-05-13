FROM amazonlinux:latest

USER root

RUN yum -y update && \
    yum -y install shadow-utils postgresql-libs && \
    groupadd -g 1000 postgrest && \
    adduser -g 1000 -u 1000 -s /bin/bash -d /home/postgrest postgrest && \
    yum -y clean all

ADD postgrest.conf /etc
ADD postgrest /usr/local/bin/postgrest
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
