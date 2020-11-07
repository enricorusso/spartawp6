FROM spartawp6/ubuntu:latest

RUN apt-get update && apt-get install -y openvpn bridge-utils

COPY sparta_server.ovpn /etc/openvpn/server/
COPY sparta_iot.ovpn /etc/openvpn/server/
COPY sparta_dmz.ovpn /etc/openvpn/server/
COPY sparta_simint.ovpn /etc/openvpn/server/
COPY key.txt /etc/openvpn/server/

COPY cracker-vpn-entrypoint.sh /usr/local/bin/

EXPOSE 22
EXPOSE 8886
EXPOSE 8887
EXPOSE 8888
EXPOSE 8889
ENTRYPOINT /usr/local/bin/cracker-vpn-entrypoint.sh
