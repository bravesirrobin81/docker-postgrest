FROM quay.io/ukhomeofficedigital/centos-base

RUN groupadd -r postgrest -g 1000 && \
    useradd -u 1000 -r -g postgrest -m -d /home/postgrest -s /sbin/nologin -c "Postgrest" postgrest && \
    chmod 755 /home/postgrest

RUN yum clean all && \
    yum install yum-plugin-ovl curl ca-certificates xz-utils libpq5 jq -y && \
    yum update -y && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rpm --rebuilddb

RUN cd /tmp && \
    curl -SLO https://github.com/PostgREST/postgrest/releases/download/${POSTGREST_VERSION}/postgrest-${POSTGREST_VERSION}-ubuntu.tar.xz && \
    tar -xJvf postgrest-${POSTGREST_VERSION}-ubuntu.tar.xz && \
    mv postgrest /usr/local/bin/postgrest

ARG POSTGREST_VERSION

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
