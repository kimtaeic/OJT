FROM centos:latest
MAINTAINER The OJT Project <teaic.kim@navercorp.com>

USER root

RUN yum -y update 
 yum -y install wget bzip2 make net-tools expat-devel gcc gcc-c++ perl cmake ncurses-devel java-1.8.0-openjdk
 mkdir /home1
 adduser -d /home1/irteam  irteam  
 echo 'irteamsu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER irteam
 
RUN mkdir /home/irteam/download
 mkdir /home/irteam/apps
 cd /home/irteam/download

# apr
RUN wget http://apache.tt.co.kr/apr/apr-1.6.5.tar.gz  tar zxvf apr-1.6.5.tar.gz 
 tar zxvf apr-1.7.0.tar.gz 
 cd /home/irteam/download/apr-1.6.5
 ./configure --prefix=/home1/irteam/apps/apr
 cp -arp libtool libtoolT
 ./configure --prefix=/home1/irteam/apps/apr
 make  make install
 cd /home/irteam/download
 rm -rf *

#apr-util
RUN wget http://apache.tt.co.kr//apr/apr-util-1.6.1.tar.gz 
 tar zxvf apr-util-1.6.1.tar.gz
 cd /home/irteam/download/apr-util-1.6.1
 ./configure --with-apr=/home1/irteam/apps/apr --prefix=/home1/irteam/apps/apr-util
 make  make install
 cd /home/irteam/download
 rm -rf *

#pcre
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz 
 tar zxvf pcre-8.43.tar.gz
 cd /home/irteam/download/pcre-8.43
 ./configure --prefix=/home1/irteam/apps/pcre
 make  make install
 cd /home/irteam/download
 rm -rf *

#openssl
RUN wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz 
 tar zxvf openssl-1.1.1b.tar.gz 
 cd /home/irteam/download/openssl-1.1.1b
 ./config --prefix=/home1/irteam/apps/ssl --openssldir=/home1/irteam/apps/openssl 
 make  make install
 cd /home/irteam/download
 rm -rf *

USER root
RUH ln -s /home1/irteam/apps/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
RUNS ln -s /home1/irteam/apps/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1

USER irteam
ENV PATH=$PATH:$HOME/bin:/home1/irteam/apps/ssl/bin 
ENV export LD_LIBRARY_PATH=/home1/irteam/apps/ssl/lib:$LD_LIBRART_PATH

# apache 설치
RUN cd /home/irteam/download
RUN wget http://apache.tt.co.kr/httpd/httpd-2.4.39.tar.gz 
 tar zxvf httpd-2.4.39.tar.gz
 cd /home/irteam/download/httpd-2.4.39


RUN cd /home/irteam/download/httpd-2.4.39/
RUN ./configure --prefix=/opt/apache  make  make install


EXPOSE 80
EXPOSE 8080
EXPOSE 8081
EXPOSE 443

