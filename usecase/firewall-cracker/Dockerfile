FROM centos:7

#ENV container docker
#MAINTAINER The CentOS Project <cloud-ops@centos.org>

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#VOLUME [ "/sys/fs/cgroup" ]

RUN yum localinstall http://mirror.nethserver.org/nethserver/nethserver-release-7.rpm -y
RUN nethserver-install

RUN yum -y install nethserver-base nethserver-firewall-base nethserver-lsm nethserver-firewall-base-ui-3.12.3-1.ns7.noarch nethserver-ndpi rsyslog

RUN yum -y update

RUN systemctl disable var-lib-nfs-rpc_pipefs.mount
RUN systemctl disable kdump
RUN systemctl disable systemd-hostnamed
RUN systemctl disable postfix
RUN systemctl disable rpcbind
RUN systemctl disable collectd
RUN systemctl disable nfs-client.target

RUN echo "root:admin" | chpasswd

COPY cracker.sh /usr/local/bin/
#COPY cracker.service /usr/lib/systemd/system
RUN chmod a+x /usr/local/bin/cracker.sh
#COPY networks /var/lib/nethserver/db/
RUN touch /.first_boot
#RUN systemctl enable cracker

EXPOSE 9090
#CMD ["/usr/sbin/init"]
CMD ["/usr/local/bin/cracker.sh"]
#ENTRYPOINT ["/bin/bash", /usr/local/bin/cracker.sh"]
