FROM centos:latest
MAINTAINER The OJT Project <teaic.kim@navercorp.com>

USER root

#RUN yum -y update \
RUN yum -y install wget bzip2 make net-tools expat-devel gcc gcc-c++ perl cmake ncurses-devel java-1.8.0-openjdk \
&& mkdir -p /home1 \
&& adduser -d /home1/irteam  irteam \
&& chown -R irteam:irteam /home1 \
&& echo 'irteam ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers 

USER irteam

RUN mkdir -p /home1/irteam/download  \
&& mkdir -p /home1/irteam/apps

WORKDIR /home1/irteam/download

# apr
RUN wget http://apache.tt.co.kr/apr/apr-1.6.5.tar.gz && tar zxvf apr-1.6.5.tar.gz  \
&& cd /home1/irteam/download/apr-1.6.5 \
&& ./configure --prefix=/home1/irteam/apps/apr \
&& cp -arp libtool libtoolT \
&& ./configure --prefix=/home1/irteam/apps/apr \
&& make && make install \
&& cd /home1/irteam/download \
&& rm -rf *

#apr-util
RUN wget http://apache.tt.co.kr//apr/apr-util-1.6.1.tar.gz && tar zxvf apr-util-1.6.1.tar.gz \
&& cd /home1/irteam/download/apr-util-1.6.1 \
&& ./configure --with-apr=/home1/irteam/apps/apr --prefix=/home1/irteam/apps/apr-util \
&& make && make install \
&& cd /home1/irteam/download \
&& rm -rf *

#pcre
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz && tar zxvf pcre-8.43.tar.gz \
&& cd /home1/irteam/download/pcre-8.43 \
&& ./configure --prefix=/home1/irteam/apps/pcre \
&& make && make install \
&& cd /home1/irteam/download \
&& rm -rf *

#openssl
RUN wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar zxvf openssl-1.1.1b.tar.gz  \
&& cd /home1/irteam/download/openssl-1.1.1b \
&& ./config --prefix=/home1/irteam/apps/ssl --openssldir=/home1/irteam/apps/openssl  \
&& make && make install \
&& cd /home1/irteam/download \
&& rm -rf *

USER root
RUN ln -s /home1/irteam/apps/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1 \
&& ln -s /home1/irteam/apps/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1

USER irteam
ENV LD_LIBRARY_PATH /home1/irteam/apps/ssl/lib
ENV PATH $HOME/bin:$LD_LIBRARY_PATH/bin 

# apache 설치
RUN wget http://apache.tt.co.kr/httpd/httpd-2.4.39.tar.gz && tar zxvf httpd-2.4.39.tar.gz  \
&& cd /home1/irteam/download/httpd-2.4.39 \
&& ./configure --enable-ssl  --with-ssl=/home1/irteam/apps/ssl --with-apr=/home1/irteam/apps/apr --with-apr-util=/home1/irteam/apps/apr-util  --with-pcre=/home1/irteam/apps/pcre --prefix=/home1/irteam/apps/apache 


ENV LANG=ko_KR.utf8 TZ=Asia/Seoul

CMD ["/bin/bash"]

EXPOSE 80 8080 8081 443
