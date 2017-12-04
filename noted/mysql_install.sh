#!/bin/bash

#输入mysql压缩文件地址
fileName=$1;
if [ -f ${fileName} ]
then
    #解压mysql
    tar -zxvf ${fileName};
    echo 'mysql解压完成，正在删除/usr/local/mysql文件夹';
    rm -rf /usr/local/mysql;
    echo '删除文件夹完成，正在移动解压后的文件';
    mv ${fileName%%.tar.gz} /usr/local/mysql;
    cd /usr/local/mysql;
else
    echo '请输入正确的文件';
fi

#如果系统缺少Data:Dumper模块需要打开下面命令
#yum -y install autoconf;

echo '移动完成，正在初始化数据库';
#初始化数据库
#scripts/mysql_install_db --user=mysql;
scripts/mysql_install_db --user=mysql --explicit_defaults_for_timestamp;

#创建mysql用户和组
groupadd mysql;
useradd -g mysql mysql;

#修改文件夹的用户和组
chown -R root .;
chown -R mysql data;
chgrp -R mysql .;

echo '初始化数据库完成，正在修改mysql配置文件';
#修改mysql配置文件
sed -i '/mysqld/a\datadir = \/usr\/local\/mysql\/data' my.cnf;
sed -i '/mysqld/a\basedir = \/usr\/local\/mysql' my.cnf;
sed -i '/mysqld/a\character-set-server=utf8' my.cnf;
sed -i '/mysqld/a\port = 3306' my.cnf;
sed -i '/mysqld/i\[client]' my.cnf;
sed -i '/mysqld/i\port = 3306' my.cnf;
sed -i '/mysqld/i\default-character-set=utf8' my.cnf;
sed -i '/mysqld/i\ ' my.cnf;
sed -i '/mysqld/i\[mysql]' my.cnf;
sed -i '/mysqld/i\default-character-set=utf8' my.cnf;
sed -i '/mysqld/i\ ' my.cnf;

echo '修改mysql配置文件完成,正在将mysql加入服务中';
cp -rf support-files/mysql.server /etc/init.d/mysql

echo 'mysql加入服务完成，正在添加开机自启动';
chkconfig mysql on

echo '添加开机自启动成功';