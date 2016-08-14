#centos 7
#this is a fork off codingtony and updated to impala 2.0.1
#see: https://github.com/codingtony/docker-impala
#see: http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html
#see: http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/impala_noncm_installation.html
#To test: docker run --rm -ti rooneyp1976/impala /start-bash.sh

FROM centos:6.7
MAINTAINER genden.om@gmail.com

RUN yum check-update; if [ $? -eq 100 ]; then exit 0; else exit $?; fi
RUN yum clean all
RUN yum update -y

RUN yum install wget vim -y
RUN wget http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm
RUN yum --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm -y
RUN wget http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-manager-repository-5.0-1.noarch.rpm
RUN yum --nogpgcheck localinstall cloudera-manager-repository-5.0-1.noarch.rpm -y
RUN yum update -y

#install oracle java 7
RUN yum -y install oracle-j2sdk1.7

# ntpd
RUN yum -y install ntp
RUN chkconfig ntpd on
RUN service ntpd start
#RUN hwclock --systohc

# mysql
RUN yum install mysql-server mysql -y
ADD files/my.cnf /etc/my.cnf
RUN chkconfig mysqld on
RUN service mysqld start
ADD files/mysqlsec.sh /
RUN chmod a+x mysqlsec.sh
RUN ./mysqlsec.sh
#RUN mysql -u root -e "create database scm" mysql
#RUN mysql -u root -e "grant all on *.* to 'scm'@'%' identified by 'scm' with grant option;" mysql
#RUN yum -y install mysql-connector-java

RUN yum clean all

# hadoop

RUN yum install hadoop-hdfs-namenode hadoop-hdfs-datanode -y
RUN yum install hive hive-metastore hive-server2 -y
RUN yum install impala impala-server impala-shell impala-catalog impala-state-store -y

RUN mkdir /var/run/hdfs-sockets/ ||:
RUN chown hdfs.hadoop /var/run/hdfs-sockets/

RUN mkdir -p /data/dn/
RUN chown hdfs.hadoop /data/dn

# Hadoop Configuration files
# /etc/hadoop/conf/ --> /etc/alternatives/hadoop-conf/ --> /etc/hadoop/conf/ --> /etc/hadoop/conf.empty/
# /etc/impala/conf/ --> /etc/impala/conf.dist
ADD files/core-site.xml /etc/hadoop/conf/
ADD files/hdfs-site.xml /etc/hadoop/conf/
ADD files/core-site.xml /etc/impala/conf/
ADD files/hdfs-site.xml /etc/impala/conf/
ADD files/hive-site.xml /etc/hive/conf/

# Various helper scripts
ADD files/start.sh /
ADD files/start-hdfs.sh /
ADD files/start-impala.sh /
ADD files/start-bash.sh /
ADD files/start-daemon.sh /
ADD files/hdp /usr/bin/hdp

# HDFS PORTS :
# 9000  Name Node IPC
# 50010 Data Node Transfer
# 50020 Data Node IPC
# 50070 Name Node HTTP
# 50075 Data Node HTTP


# IMPALA PORTS :
# 21000 Impala Shell
# 21050 Impala ODBC/JDBC
# 25000 Impala Daemon HTTP
# 25010 Impala State Store HTTP
# 25020 Impala Catalog HTTP

EXPOSE 9000 50010 50020 50070 50075 21000 21050 25000 25010 25020

CMD ["/start-daemon.sh"]
