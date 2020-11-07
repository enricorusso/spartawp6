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

/usr/sbin/sshd -D
