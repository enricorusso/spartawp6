FROM spartawp6/ubuntu:latest

RUN apt-get update && apt-get install -y bind9
COPY cracker-dns-entrypoint.sh /usr/local/bin/

COPY named.conf.options /etc/bind
COPY named.conf.local /etc/bind
COPY db.sparta.ii /etc/bind

EXPOSE 22
EXPOSE 53
ENTRYPOINT /usr/local/bin/cracker-dns-entrypoint.sh
