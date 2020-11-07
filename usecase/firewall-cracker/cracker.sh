#!/bin/bash 


#/usr/bin/test -f /.first_boot || exit

if [ -f /.first_boot ]; then

/usr/bin/echo "Cracker init..."

if [ "$DEFGW" != "" ]; then
    ip route del default
    echo "ip route add default via $DEFGW"
    ip route add default via $DEFGW
fi

gw=$(ip r | grep default | cut -d' ' -f 3)
gwd=$(ip r | grep default | cut -d' ' -f 5)

#ip r
echo "Default gw: $gw ($gwd)"

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

#rm -f /var/lib/nethserver/db/networks
for d in $(find /sys/class/net | grep eth | cut -d/ -f 5)
do
 ip=$(ifconfig $d | grep inet | cut -c9- | cut -d' ' -f 2)
 mask=$(ifconfig $d | grep inet | cut -c9- | cut -d' '  -f 5)

 gateway=""
 if [ "$d" == "$gwd" ]; then
    gateway=$gw
 fi

 if [ "$ROLES" != "" ]; then
    role=""
    for r in $ROLES
    do
     ri=$(echo $r | cut -d, -f 1)
     rn=$(echo $r | cut -d, -f 2)
    if [ $ip == $ri ]; then
        role=$rn
    fi
    done
 fi

 #echo "$d=ethernet|bootproto|none|gateway|$gateway|ipaddr|$ip|netmask|$mask|nslabel||role|$role" >> /var/lib/nethserver/db/networks

 
 echo "{\"action\":\"change-properties\",\"role\":\"$role\",\"bootproto\":\"none\",\"interface\":\"$d\",\"ipaddr\":\"$ip\",\"netmask\":\"$mask\",\"gateway\":\"$gateway\",\"nslabel\":\"\"}"
 echo "{\"action\":\"change-properties\",\"role\":\"$role\",\"bootproto\":\"none\",\"interface\":\"$d\",\"ipaddr\":\"$ip\",\"netmask\":\"$mask\",\"gateway\":\"$gateway\",\"nslabel\":\"\"}" | /usr/libexec/nethserver/api/system-network/update
done

echo "ppp0=xdsl-disabled|AuthType|auto|FwInBandwidth||FwOutBandwidth||Password||name|PPPoE|provider|xDSL provider|role|red|user|" >> /var/lib/nethserver/db/networks

# create permissive firewall rules..
echo '{"name":"any","Address":"0.0.0.0/0","Description":"","action":"create-cidr-sub"}' | /usr/libexec/nethserver/api/nethserver-firewall-base/objects/create 
echo '{"name":"dmz","Address":"198.51.100.0/24","Description":"","action":"create-cidr-sub"}' | /usr/libexec/nethserver/api/nethserver-firewall-base/objects/create
echo '{"name":"intranet","Address":"192.168.100.0/24","Description":"","action":"create-cidr-sub"}' | /usr/libexec/nethserver/api/nethserver-firewall-base/objects/create
echo '{"name":"iot","Address":"192.168.200.0/24","Description":"","action":"create-cidr-sub"}' | /usr/libexec/nethserver/api/nethserver-firewall-base/objects/create

echo '{"action":"create-rule","Log":"none","Time":null,"Position":1,"status":"enabled","Service":{"name":"any","type":"fwservice"},"order":"bottom","Action":"accept","Dst":{"Address":"198.51.100.0/24","name":"dmz","Description":"","type":"cidr"},"id":null,"Src":{"Address":"0.0.0.0/0","name":"any","Description":"","type":"cidr"},"type":"rule","State":"new","Description":""}' | /usr/libexec/nethserver/api/nethserver-firewall-base/rules/create
echo '{"action":"create-rule","Log":"none","Time":null,"Position":1,"status":"enabled","Service":{"name":"any","type":"fwservice"},"order":"bottom","Action":"accept","Dst":{"Address":"192.168.100.0/24","name":"intranet","Description":"","type":"cidr"},"id":null,"Src":{"Address":"198.51.100.0/0","name":"dmz","Description":"","type":"cidr"},"type":"rule","State":"new","Description":""}' | /usr/libexec/nethserver/api/nethserver-firewall-base/rules/create

echo '{"action":"apply"}' | /usr/libexec/nethserver/api/nethserver-firewall-base/settings/update

# use a public key!!!
if [ "$ROOTPW" != "" ]; then
    /usr/bin/echo "root:$ROOTPW" | chpasswd
    #echo $ROOTPW | /usr/libexec/nethserver/api/system-password/change-root-passwd
fi

/usr/bin/echo '{"action":"add-shortcut","name":"nethserver-firewall-base"}' | /usr/bin/sudo /usr/libexec/nethserver/api/system-apps/update

/usr/sbin/e-smith/signal-event firewall-adjust

/bin/rm -f /.first_boot

fi

exec /usr/sbin/init
