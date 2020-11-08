#!/bin/bash
#set -x

if [ "$PUBKEY" != "" ]; then
    mkdir /root/.ssh
    echo $PUBKEY > /root/.ssh/authorized_keys
    chmod go-rwx /root/.ssh/authorized_keys
fi

if [ "$DEFGW" != "" ]; then
    ip route del default
    echo "ip route add default via $DEFGW"
    ip route add default via $DEFGW
fi

if [ "$ROUTES" != "" ]; then
    echo $ROUTES | sed 's/;/\n/g' |
    while read r
    do
      echo "ip route add $r"
      ip route add $r
    done
fi

# use a public key!!!
if [ "$ROOTPW" != "" ]; then
    echo "root:$ROOTPW" | chpasswd
fi

if [ "$DNS" != "" ]; then
    echo "# added by cracker" > /etc/resolv.conf
    for d in $DNS
    do
     echo "nameserver $d" >> /etc/resolv.conf
    done
fi

if [ "$MASQUERADE" != "" ]; then
    #i=`ip a | grep $MASQUERADE | cut -d' ' -f 11`
    i=`ip r | grep $MASQUERADE | cut -d' ' -f 3`
    echo "iptables -t nat -A POSTROUTING -o $i -j MASQUERADE"
    iptables -t nat -A POSTROUTING -o $i -j MASQUERADE
fi

newbridge () {
  # ip
  # id

  echo "Using ip: $1 and id: $2"

  openvpn --mktun --dev tap$2
  brctl addbr br$2

  d_int=$(ip -o addr show scope global | tr -s ' ' | tr '/' ' ' | cut -f 2,4 -d ' ' | grep $1 | cut -d ' ' -f 1)
  ip addr del $1 dev $d_int

  brctl addif br$2 $d_int
  brctl addif br$2 tap$2

  ifconfig $d_int 0.0.0.0 promisc up
  ifconfig tap$2 0.0.0.0 promisc up
  ifconfig br$2 $1 netmask 255.255.255.0
}

# create bridge for intranet
newbridge "192.168.100.100" 0

# create bridge for iot
newbridge "192.168.200.100" 1

# create bridge for dmz
newbridge "198.51.100.100" 2

# create bridge for simint
newbridge "27.8.0.100" 3

# iptables

iptables -A INPUT -i tap+ -j ACCEPT
iptables -A INPUT -i br0 -j ACCEPT
iptables -A FORWARD -i br0 -j ACCEPT

/usr/sbin/openvpn --config /etc/openvpn/server/sparta_server.ovpn --daemon
/usr/sbin/openvpn --config /etc/openvpn/server/sparta_iot.ovpn --daemon
/usr/sbin/openvpn --config /etc/openvpn/server/sparta_dmz.ovpn --daemon
/usr/sbin/openvpn --config /etc/openvpn/server/sparta_simint.ovpn --daemon
/usr/sbin/sshd -D
