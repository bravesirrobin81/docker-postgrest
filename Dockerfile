FROM postgrest/postgrest:latest

USER root

RUN apt-get install -y curl ca-certificates

ADD getKeycloakKey.sh /usr/local/bin/getKeycloakKey.sh

RUN chmod +x /usr/local/bin/getKeycloakKey.sh /usr/local/bin/postgrest

USER 1000

CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
