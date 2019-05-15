FROM centos:latest
MAINTAINER The OJT Project <teaic.kim@navercorp.com>

USER root

RUN yum -y update && \
 yum -y install wget bzip2 make net-tools expat-devel gcc gcc-c++ perl && \
 mkdir -p /home1 && \
 adduser -d /home1/irteam  irteam && \
 chown -R irteam:irteam /home1  && \
# echo 'irteam ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers 
 rm -rf /etc/localtime  && \
 ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

USER irteam

RUN mkdir -p /home1/irteam/download &&  \
mkdir -p /home1/irteam/apps

WORKDIR /home1/irteam/download

# apr
RUN wget http://apache.tt.co.kr/apr/apr-1.6.5.tar.gz &&  tar zxvf apr-1.6.5.tar.gz &&  \
 cd /home1/irteam/download/apr-1.6.5 && \
 ./configure --prefix=/home1/irteam/apps/apr && \
 cp -arp libtool libtoolT && \
 ./configure --prefix=/home1/irteam/apps/apr && \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

#apr-util
RUN wget http://apache.tt.co.kr//apr/apr-util-1.6.1.tar.gz  && tar zxvf apr-util-1.6.1.tar.gz && \
 cd /home1/irteam/download/apr-util-1.6.1 && \
 ./configure --with-apr=/home1/irteam/apps/apr --prefix=/home1/irteam/apps/apr-util && \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

#pcre
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz &&  tar zxvf pcre-8.43.tar.gz && \
 cd /home1/irteam/download/pcre-8.43 && \
 ./configure --prefix=/home1/irteam/apps/pcre && \
 make &&  make install && \
 cd /home1/irteam/download && \
 rm -rf *

#openssl
RUN wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz &&  tar zxvf openssl-1.1.1b.tar.gz &&  \
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
RUN wget http://apache.tt.co.kr/httpd/httpd-2.4.39.tar.gz  && tar zxvf httpd-2.4.39.tar.gz &&  \
 cd /home1/irteam/download/httpd-2.4.39 && \
 ./configure --enable-ssl  --with-ssl=/home1/irteam/apps/ssl --with-apr=/home1/irteam/apps/apr --with-apr-util=/home1/irteam/apps/apr-util  --with-pcre=/home1/irteam/apps/pcre --prefix=/home1/irteam/apps/apache && make &&  make install && \
 sed -i 's/User daemon/User irteam/g' /home1/irteam/apps/apache/conf/httpd.conf && \
 sed -i 's/Group daemon/Group irteam/g' /home1/irteam/apps/apache/conf/httpd.conf && \
 sed -i 's/\#ServerName www.example.com:80/ServerName localhost:80/g' /home1/irteam/apps/apache/conf/httpd.conf

#특수권한
USER root
RUN chown root:irteam /home1/irteam/apps/apache/bin/httpd && \
chmod 4755 /home1/irteam/apps/apache/bin/httpd && \
yum -y install cmake ncurses-devel java-1.8.0-openjdk

USER irteam
#tomcat
RUN wget http://apache.mirror.cdnetworks.com/tomcat/tomcat-8/v8.5.40/bin/apache-tomcat-8.5.40.tar.gz && \
tar zxvf apache-tomcat-8.5.40.tar.gz && \
cp -arp ./apache-tomcat-8.5.40 /home1/irteam/apps/worker1 && \
cp -arp ./apache-tomcat-8.5.40 /home1/irteam/apps/worker2 && \
rm -rf * && \
sed -i "s/Server port=\"8005\"/Server port=\"8105\"/g" /home1/irteam/apps/worker1/conf/server.xml &&\
sed -i "s/Connector port=\"8009\"/Connector port=\"8109\"/g" /home1/irteam/apps/worker1/conf/server.xml &&\
sed -i "s/Server port=\"8005\"/Server port=\"8205\"/g" /home1/irteam/apps/worker2/conf/server.xml &&\
sed -i "s/Connector port=\"8080\"/Connector port=\"8081\"/g" /home1/irteam/apps/worker2/conf/server.xml &&\
sed -i "s/Connector port=\"8009\"/Connector port=\"8209\"/g" /home1/irteam/apps/worker2/conf/server.xml

#java
RUN wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie"  https://download.oracle.com/otn-pub/java/jdk/12.0.1+12/69cfe15208a647278a19ef0990eea691/jdk-12.0.1_linux-x64_bin.tar.gz && \
tar zxvf jdk-12.0.1_linux-x64_bin.tar.gz && \
cp -arp ./jdk-12.0.1 /home1/irteam/apps/jdk && \
rm -rf *

#ssl 설정
RUN cd /home1/irteam && \
/home1/irteam/apps/ssl/bin/openssl req -nodes -new -x509 -keyout server.key -out server.crt -subj '/CN=localhost/L=Seongnam-si/ST=Gyeonggi-do/O=platform/C=KR' && \
cp -arp /home1/irteam/server.key /home1/irteam/apps/apache/conf/ && \
cp -arp /home1/irteam/server.crt /home1/irteam/apps/apache/conf/ && \
sed -i 's/\#LoadModule ssl_module modules\/mod_ssl.so/LoadModule ssl_module modules\/mod_ssl.so/g' /home1/irteam/apps/apache/conf/httpd.conf && \
sed -i 's/\#LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/g' /home1/irteam/apps/apache/conf/httpd.conf && \
echo -e "Include conf/extra/httpd-ssl.conf" >> /home1/irteam/apps/apache/conf/httpd.conf && \
sed -i 's/DocumentRoot/\#DocumentRoot/g' /home1/irteam/apps/apache/conf/extra/httpd-ssl.conf && \
sed -i 's/ServerName/\#ServerName/g' /home1/irteam/apps/apache/conf/extra/httpd-ssl.conf && \
sed -i 's/SSLEngine on/JkMount \/\* balancer \n SSLEngine on/g' /home1/irteam/apps/apache/conf/extra/httpd-ssl.conf

#Load balance
RUN wget http://apache.mirror.cdnetworks.com/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz && tar zxvf tomcat-connectors-1.2.46-src.tar.gz && \
cd /home1/irteam/download/tomcat-connectors-1.2.46-src/native &&  ./configure --with-apxs=/home1/irteam/apps/apache/bin/apxs &&  make && make install && \
echo -e "Include conf/httpd-jk.conf" >> /home1/irteam/apps/apache/conf/httpd.conf && \
echo -e "LoadModule jk_module modules/mod_jk.so" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkWorkersFile conf/workers.properties" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkLogFile \"logs/mod_jk.log\"" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkLogLevel info" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkLogStampFormat \"[%a %b %d %H:%M:%S %Y]\""  >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkRequestLogFormat \"%w %V %T\"" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkShmFile \"logs/mod_jk.shm\"" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkMount /*.jsp balancer" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkMount /*.png balancer" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "JkMount /*.css balancer" >> /home1/irteam/apps/apache/conf/httpd-jk.conf && \
echo -e "worker.list=balancer" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker1.type=ajp13" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker1.host=localhost" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker1.port=8109" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker1.lbfactor=1" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker2.type=ajp13" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker2.host=localhost" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker2.port=8209" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.worker2.lbfactor=1" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.balancer.type=lb" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.balancer.sticky_session=1" >> /home1/irteam/apps/apache/conf/workers.properties && \
echo -e "worker.balancer.balanced_workers=worker1, worker2" >> /home1/irteam/apps/apache/conf/workers.properties && \
sed -i 's/jvmRoute=\"jvm1\"/jvmRoute=\"worker1\"/g' /home1/irteam/apps/worker1/conf/server.xml && \
sed -i 's/jvmRoute=\"jvm1\"/jvmRoute=\"worker2\"/g' /home1/irteam/apps/worker2/conf/server.xml  && \
sed -i '4720i\<distributable />' /home1/irteam/apps/worker1/conf/web.xml && \
sed -i '4720i\<distributable />' /home1/irteam/apps/worker2/conf/web.xml && \
sed -i 's/${pageContext.servletContext.serverInfo}/worker1/g' /home1/irteam/apps/worker1/webapps/ROOT/index.jsp && \
sed -i 's/${pageContext.servletContext.serverInfo}/worker2/g' /home1/irteam/apps/worker2/webapps/ROOT/index.jsp

#Session prelication DeltaManager
RUN sed -i '136i\<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" channelSendOptions="8"> <Manager className="org.apache.catalina.ha.session.DeltaManager" expireSessionsOnShutdown="false" notifyListenersOnReplication="true"/> <Channel className="org.apache.catalina.tribes.group.GroupChannel"> <Membership className="org.apache.catalina.tribes.membership.McastService" address="228.0.0.4" port="45564" frequency="500" dropTime="3000"/>  <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver" address="auto" port="4000" autoBind="100" selectorTimeout="5000" maxThreads="6"/> <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter"> <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/> </Sender> <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/> <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor"/>  </Channel> <Valve className="org.apache.catalina.ha.tcp.ReplicationValve" filter=""/>  <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/> <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/> </Cluster>' /home1/irteam/apps/worker1/conf/server.xml && \
sed -i '136i\<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" channelSendOptions="8"> <Manager className="org.apache.catalina.ha.session.DeltaManager" expireSessionsOnShutdown="false" notifyListenersOnReplication="true"/> <Channel className="org.apache.catalina.tribes.group.GroupChannel"> <Membership className="org.apache.catalina.tribes.membership.McastService" address="228.0.0.4" port="45564" frequency="500" dropTime="3000"/>  <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver" address="auto" port="4001" autoBind="100" selectorTimeout="5000" maxThreads="6"/> <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter"> <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/> </Sender> <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/> <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor"/>  </Channel> <Valve className="org.apache.catalina.ha.tcp.ReplicationValve" filter=""/>  <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/> <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/> </Cluster>' /home1/irteam/apps/worker2/conf/server.xml

RUN mkdir -p /home1/irteam/apps/mysql/{data,tmp,logs} 
#mysql
RUN wget https://downloads.mysql.com/archives/get/file/mysql-5.7.25.tar.gz && tar zxvf mysql-5.7.25.tar.gz && cd mysql-5.7.25 &&  \
cmake \
-DCMAKE_INSTALL_PREFIX=/home1/irteam/apps/mysql \
-DMYSQL_DATADIR=/home1/irteam/apps/mysql/data \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DMYSQL_UNIX_ADDR=/home1/irteam/apps/mysql/mysql.sock \
-DSYSCONFDIR=/home1/irteam/apps/mysql/etc \
-DMYSQL_TCP_PORT=13306 \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=/home1/irteam/apps/ \
-DSYSCONFDIR=/home1/irteam/apps/mysql && \
make && make install && make clean && \
rm -rf /home1/irteam/apps/boost_1_59_0.tar.gz

ENV MYSQL_HOME /home1/irteam/apps/mysql
ENV PATH $HOME/bin:$LD_LIBRARY_PATH/bin:$MYSQL_HOME/bin

RUN echo -e "[mysqld]" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "datadir=/home1/irteam/apps/mysql/data" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "socket=/home1/irteam/apps/mysql/mysql.sock" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "user=irteam" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "innodb_buffer_pool-size=2G" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "port=13306" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "character-set-server=utf8" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "collation-server=utf8_general_ci" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "init_connect=SET collation_connection=utf8_general_ci" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "init_connect=SET NAMES utf8" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "skip-grant-tables" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "[mysqld-safe]" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "log-error=/home1/irteam/apps/mysql/logs/mysqld.log" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "pid-file=/home1/irteam/apps/mysql/data/mysqld.pid" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "default-character-set=utf8" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "[client]" >> /home1/irteam/apps/mysql/my.cnf && \ 
echo -e "default-character-set=utf8" >> /home1/irteam/apps/mysql/my.cnf && \
/home1/irteam/apps/mysql/bin/mysql_install_db --user=irteam --basedir=/home1/irteam/apps/mysql --datadir=/home1/irteam/apps/mysql/data && \
/home1/irteam/apps/mysql/support-files/mysql.server start && \
# mysql -uroot mysql -e "SET PASSWORD = PASSWORD('root1234')"  && \
# mysql -uroot mysql -e "grant all privileges on testdb.* to 'root'@'%' IDENTIFIED BY 'root1234'" && \
# mysql -uroot mysql -e "flush privileges" && \
mysql -uroot mysql -e "CREATE DATABASE testdb" && \
mysql -uroot mysql -Dtestdb -e "CREATE TABLE testdb.course (sno INT NOT NULL, prof CHAR(2), dept CHAR(10), cno CHAR(4) NOT NULL, grade CHAR(1), PRIMARY KEY(sno, cno) )" && \
mysql -uroot mysql -Dtestdb -e "INSERT INTO testdb.course VALUES (100, 'P1', 'Computer', 'C413', 'A'), (100, 'P1', 'Computer', 'E412', 'A'), (200, 'P2', 'Electric', 'C123', 'B'), (300, 'P3', 'Computer', 'C312', 'A'), (300, 'P3', 'Computer', 'C324', 'C'), (300, 'P3', 'Computer', 'C413', 'A'), (400, 'P1', 'Computer', 'C312', 'A'), (400, 'P1', 'Computer', 'C324', 'A'), (400, 'P1', 'Computer', 'C413', 'B'), (400, 'P1', 'Computer', 'E412', 'C')"  && \
mysql -uroot mysql -Dtestdb -e "UPDATE mysql.user SET AUTHENTICATION_STRING=PASSWORD('root1234') WHERE USER='root'" && \
sed -i 's/skip-grant-tables/\#skip-grant-tables/g' /home1/irteam/apps/mysql/my.cnf && \
/home1/irteam/apps/mysql/support-files/mysql.server restart

RUN wget https://downloads.mysql.com/archives/get/file/mysql-connector-java-5.1.46.tar.gz && tar zxvf mysql-connector-java-5.1.46.tar.gz && \
cp -arp /home1/irteam/download/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46* /home1/irteam/apps/worker1/lib && \
cp -arp /home1/irteam/download/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46* /home1/irteam/apps/worker2/lib && \
wget http://archive.apache.org/dist/jakarta/taglibs/standard/binaries/jakarta-taglibs-standard-1.1.2.tar.gz && tar zxvf jakarta-taglibs-standard-1.1.2.tar.gz && \
cp -arp /home1/irteam/download/jakarta-taglibs-standard-1.1.2/lib/* /home1/irteam/apps/worker1/lib && \
cp -arp /home1/irteam/download/jakarta-taglibs-standard-1.1.2/lib/* /home1/irteam/apps/worker2/lib && \
rm -rf /home1/irteam/download/* && \
sed -i '4721i\<description>MySQL Test App</description> <resource-ref> <description>DB Connection</description> <res-ref-name>jdbc/tikim</res-ref-name> <res-type>javax.sql.DataSource</res-type> <res-auth>Container</res-auth> </resource-ref>' /home1/irteam/apps/worker1/conf/web.xml && \
sed -i '4721i\<description>MySQL Test App</description> <resource-ref> <description>DB Connection</description> <res-ref-name>jdbc/tikim</res-ref-name> <res-type>javax.sql.DataSource</res-type> <res-auth>Container</res-auth> </resource-ref>' /home1/irteam/apps/worker2/conf/web.xml && \
sed -i '41i\<!--' /home1/irteam/apps/worker1/conf/server.xml && \
sed -i '47i\-->' /home1/irteam/apps/worker1/conf/server.xml && \
sed -i '41i\<!--' /home1/irteam/apps/worker2/conf/server.xml && \
sed -i '47i\-->' /home1/irteam/apps/worker2/conf/server.xml && \
sed -i '30i\<Resource name="jdbc/tikim" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="root" password="root1234" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://localhost:13306/testdb"/>' /home1/irteam/apps/worker1/conf/context.xml && \
sed -i '30i\<Resource name="jdbc/tikim" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="root" password="root1234" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://localhost:13306/testdb"/>' /home1/irteam/apps/worker2/conf/context.xml && \
echo -e "<%@ taglib prefix=\"c\" uri=\"http://java.sun.com/jsp/jstl/core\" %> <%@ taglib prefix=\"sql\" uri=\"http://java.sun.com/jsp/jstl/sql\" %> <html> <head> <meta charset=\"UTF-8\"> <title>OJT DB select</title> </head> <body> <p> JSTL DB Select </p> <sql:query var=\"rs\" dataSource=\"jdbc/tikim\"> select sno, prof, dept, cno, grade from course; </sql:query> <table border=\"1\"> <tr> <th>sno</th><th>prof</th><th>dept</th><th>cno</th><th>grade</th> <c:forEach var=\"s\" items=\"\${rs.rows}\"> <tr> <td>\${s.sno}</td> <td>\${s.prof}</td> <td>\${s.dept}</td> <td>\${s.cno}</td> <td>\${s.grade}</td> </tr> </c:forEach> </tr> </table> </body> </html>" >> /home1/irteam/apps/worker1/webapps/ROOT/test.jsp && \
echo -e "<%@ taglib prefix=\"c\" uri=\"http://java.sun.com/jsp/jstl/core\" %> <%@ taglib prefix=\"sql\" uri=\"http://java.sun.com/jsp/jstl/sql\" %> <html> <head> <meta charset=\"UTF-8\"> <title>OJT DB select</title> </head> <body> <p> JSTL DB Select </p> <sql:query var=\"rs\" dataSource=\"jdbc/tikim\"> select sno, prof, dept, cno, grade from course; </sql:query> <table border=\"1\"> <tr> <th>sno</th><th>prof</th><th>dept</th><th>cno</th><th>grade</th> <c:forEach var=\"s\" items=\"\${rs.rows}\"> <tr> <td>\${s.sno}</td> <td>\${s.prof}</td> <td>\${s.dept}</td> <td>\${s.cno}</td> <td>\${s.grade}</td> </tr> </c:forEach> </tr> </table> </body> </html>" >> /home1/irteam/apps/worker2/webapps/ROOT/test.jsp && \
echo -e "set encoding=utf-8" >> /home1/irteam/.vimrc && \
echo -e "set fileencodings=utf-8,cp949" >> /home1/irteam/.vimrc && \
source ~/.vimrc



#PHP



#zabbix





USER root
RUN echo -e "export JAVA_HOME=/home1/irteam/apps/jdk" >> /etc/profile && \
echo -e "export JRE_HOME=/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64" >> /etc/profile && \
echo -e "export APACHE_HOME=/home1/irteam/apps/apache" >> /etc/profile && \
echo -e "export PHP_HOME=/home1/irteam/apps/php" >> /etc/profile && \
echo -e "export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$APACHE_HOME/bin:$NAGIOS_HOME/bin:$PHP_HOME/bin" >> /etc/profile && \
. /etc/profile

ENV LANG=ko_KR.utf8 TZ=Asia/Seoul

CMD ["/bin/bash"]

EXPOSE 80 8080 8081 443

