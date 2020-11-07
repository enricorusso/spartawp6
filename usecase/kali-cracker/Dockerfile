FROM kalilinux/kali-rolling

RUN apt-get update && apt-get install -y openssh-server iproute2 iptables inetutils-ping metasploit-framework telnet netcat vim nano dnsmasq net-tools dnsutils
COPY cracker-entrypoint.sh /usr/local/bin/
RUN mkdir /var/run/sshd
# TODO: change with green team public key
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY pass /home

EXPOSE 22
ENTRYPOINT /usr/local/bin/cracker-entrypoint.sh
