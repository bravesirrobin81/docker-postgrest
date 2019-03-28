FROM quay.io/ukhomeofficedigital/centos-base

ARG POSTGREST_VERSION v5.2.0

RUN groupadd -r postgrest -g 1000 && \
    useradd -u 1000 -r -g postgrest -m -d /home/postgrest -s /sbin/nologin -c "Postgrest" postgrest && \
    chmod 755 /home/postgrest

RUN yum clean all && \
    yum install -y yum-plugin-ovl epel-release curl ca-certificates && \
    yum install -y xz libpq-dev jq && \
    yum update -y && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rpm --rebuilddb

RUN cd /tmp && \
    curl -SLO https://github.com/PostgREST/postgrest/releases/download/${POSTGREST_VERSION}/postgrest-${POSTGREST_VERSION}-centos7.tar.xz && \
    unxz postgrest-${POSTGREST_VERSION}-centos7.tar.xz && \
    tar -xf postgrest-${POSTGREST_VERSION}-centos7.tar && \
    mv postgrest /usr/local/bin/postgrest

ENV PGRST_DB_URI="" \
    PGRST_DB_SCHEMA=public \
    PGRST_DB_ANON_ROLE="" \
    PGRST_DB_POOL=100 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_SERVER_HOST=*4 \
    PGRST_SERVER_PORT=3000 \
    PGRST_SERVER_PROXY_URI="" \
    PGRST_JWT_SECRET="" \
    PGRST_SECRET_IS_BASE64=false \
    PGRST_JWT_AUD="" \
    PGRST_MAX_ROWS="" \
    PGRST_PRE_REQUEST="" \
    PGRST_ROLE_CLAIM_KEY=".role"

ADD postgrest.conf /etc/postgrest.conf
ADD getKeycloakKey.sh /usr/local/bin/getKeycloakKey.sh

RUN chmod +x /usr/local/bin/getKeycloakKey.sh /usr/local/bin/postgrest

USER 1000

CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
