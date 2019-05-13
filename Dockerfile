FROM centos:latest
MAINTAINER The OJT Project <teaic.kim@navercorp.com>

USER root

RUN yum -y update && \
 yum -y install wget bzip2 make net-tools expat-devel gcc gcc-c++ perl && \
 mkdir -p /home1 && \
 adduser -d /home1/irteam  irteam && \
 chown -R irteam:irteam /home1 && \
 echo 'irteam ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers 

USER irteam

RUN mkdir -p /home1/irteam/download &&  \
 mkdir -p /home1/irteam/apps

WORKDIR /home1/irteam/download

# apr
RUN wget http://apache.tt.co.kr/apr/apr-1.6.5.tar.gz  tar zxvf apr-1.6.5.tar.gz &&  \
 cd /home1/irteam/download/apr-1.6.5 && \
 ./configure --prefix=/home1/irteam/apps/apr && \
 cp -arp libtool libtoolT && \
 ./configure --prefix=/home1/irteam/apps/apr && \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

#apr-util
RUN wget http://apache.tt.co.kr//apr/apr-util-1.6.1.tar.gz  tar zxvf apr-util-1.6.1.tar.gz && \
 cd /home1/irteam/download/apr-util-1.6.1 && \
 ./configure --with-apr=/home1/irteam/apps/apr --prefix=/home1/irteam/apps/apr-util && \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

#pcre
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz  tar zxvf pcre-8.43.tar.gz && \
 cd /home1/irteam/download/pcre-8.43 && \
 ./configure --prefix=/home1/irteam/apps/pcre && \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

#openssl
RUN wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz  tar zxvf openssl-1.1.1b.tar.gz &&  \
 cd /home1/irteam/download/openssl-1.1.1b && \
 ./config --prefix=/home1/irteam/apps/ssl --openssldir=/home1/irteam/apps/openssl &&  \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

USER root
RUN ln -s /home1/irteam/apps/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1 && \
 ln -s /home1/irteam/apps/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1

USER irteam
ENV LD_LIBRARY_PATH /home1/irteam/apps/ssl/lib
ENV PATH $HOME/bin:$LD_LIBRARY_PATH/bin 

# apache 설치
RUN wget http://apache.tt.co.kr/httpd/httpd-2.4.39.tar.gz  tar zxvf httpd-2.4.39.tar.gz &&  \
 cd /home1/irteam/download/httpd-2.4.39 && \
 ./configure --enable-ssl  --with-ssl=/home1/irteam/apps/ssl --with-apr=/home1/irteam/apps/apr --with-apr-util=/home1/irteam/apps/apr-util  --with-pcre=/home1/irteam/apps/pcre --prefix=/home1/irteam/apps/apache && \
 make &&  make install && \
 sed -i 's/User daemon/User irteam/g' /home1/irteam/apps/apache/conf/httpd.conf && \
 sed -i 's/Group daemon/Group irteam/g' /home1/irteam/apps/apache/conf/httpd.conf && \
 sed -i 's/\#ServerName www.example.com:80/ServerName localhost:80/g' /home1/irteam/apps/apache/conf/httpd.conf

#특수권한
USER root
RUN chown root:irteam /home1/irteam/apps/apache/bin/httpd && \
chmod 4755 /home1/irteam/apps/apache/bin/httpd && \
yum -y cmake ncurses-devel java-1.8.0-openjdk

USER irteam

#tomcat
RUN wget http://apache.mirror.cdnetworks.com/tomcat/tomcat-8/v8.5.40/bin/apache-tomcat-8.5.40.tar.gz && \
tar zxvf apache-tomcat-8.5.40.tar.gz && \
cp -arp ./apache-tomcat-8.5.40 /home1/irteam/apps/worker1 && \
cp -arp ./apache-tomcat-8.5.40 /home1/irteam/apps/worker2 && \
rm -rf * &&\
sed -i "s/Server port=\"8005\"/Server port=\"8105\"/g" /home1/irteam/apps/worker1/conf/server.xml &&\
sed -i "s/Connector port=\"8080\"/Connector port=\"8080\"/g" /home1/irteam/apps/worker1/conf/server.xml &&\
sed -i "s/Connector port=\"8009\"/Connector port=\"8109\"/g" /home1/irteam/apps/worker1/conf/server.xml &&\
sed -i "s/Server port=\"8005\"/Server port=\"8205\"/g" /home1/irteam/apps/worker2/conf/server.xml &&\
sed -i "s/Connector port=\"8080\"/Connector port=\"8081\"/g" /home1/irteam/apps/worker2/conf/server.xml &&\
sed -i "s/Connector port=\"8009\"/Connector port=\"8209\"/g" /home1/irteam/apps/worker2/conf/server.xml

#java
wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie"  https://download.oracle.com/otn-pub/java/jdk/12.0.1+12/69cfe15208a647278a19ef0990eea691/jdk-12.0.1_linux-x64_bin.tar.gz && \
tar zxvf jdk-12.0.1_linux-x64_bin.tar.gz && \
cp -arp ./jdk-12.0.1 /home1/irteam/apps/jdk && \
rm -rf *

USER root
echo -e "export JAVA_HOME=/home1/irteam/apps/jdk" >> /etc/profile && \
echo -e "export JRE_HOME=/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64" >> /etc/profile && \
echo -e "export PATH=$PATH:/home1/irteam/apps/jdk/bin:/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/bin" >> /etc/profile && \
. /etc/profile


ENV LANG=ko_KR.utf8 TZ=Asia/Seoul

CMD ["/bin/bash"]

EXPOSE 80 8080 8081 443
