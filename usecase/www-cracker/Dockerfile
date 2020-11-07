FROM spartawp6/ubuntu:latest

RUN apt-get update && apt-get install -y apache2
COPY cracker-www-entrypoint.sh /usr/local/bin/

COPY index.html /var/www/html
COPY vpn.html /var/www/html
COPY logo.png /var/www/html
COPY config/client.ovpn /var/www/html/
COPY config/key.txt /var/www/html

EXPOSE 22
ENTRYPOINT /usr/local/bin/cracker-www-entrypoint.sh
