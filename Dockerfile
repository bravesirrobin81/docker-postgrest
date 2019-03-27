FROM quay.io/digitalpatterns/postgrest:v5.2.0

RUN groupadd --gid 1000 postgrest \
  && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home --home /home/postgrest postgrest

# Install libpq5
RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends jq curl ca-certificates && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD getKeycloakKey.sh /bin/getKeycloakKey.sh

USER 1000

CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
