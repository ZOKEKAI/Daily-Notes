#!/bin/sh  
#自动安装脚本（包括包下载和环境配置）  
mkdir -p /data/tomcat  
path_top=/data/tomcat  
#不要修改a的行号  
a=0  
#注意a是累加  
let a+=1;  
b=$a  
sed -i -e "6c "a=$b"" tomcat_install.sh  
  
  
##########################  
cd $path_top  
dir=tomcat$a  
mkdir $dir  
cd $dir  
#内网下载  
wget -c  http://192.168.0.220:8207/tomcat.tar.gz >/dev/null 2>&1  
  
echo "tomcat download finish"  
tar -zxf tomcat.tar.gz  
rm -f tomcat.tar.gz  
  
  
#安装jdk以及环境变量  
a=`grep jar /etc/profile |awk -F. '{print $(4)}'`  
if [[ $a = "jar" ]];then  
echo "java install finish"  
else  
#内网下载  
wget -c http://192.168.0.220:8207/jdk1.7.tar.gz >/dev/null 2>&1  
tar -zxf jdk1.7.tar.gz  
rm -f jdk1.7.tar.gz  
cd ./jdk1.7.0_79/  
echo "export JAVA_HOME=`pwd`" >> /etc/profile  
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile  
echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile  
`source /etc/profile`  
source /etc/profile  
echo "java environment is finished"  
echo "java_pack=$path_top/$dir/jdk1.7.0_79"  
echo "vironment can't immediate effect"  
echo "Need to restart the client, or the input source/etc/profile"  
fi  
  
  
#修改server.xml文件的端口号  
#shutdown端口  
number01=810$b  
sed -i -e "s|8005|"$number01"|" /$path_top/$dir/apache-tomcat-7.0.68/conf/server.xml  
#访问端口  
number02=820$b  
sed -i -e "s|8080|"$number02"|" /$path_top/$dir/apache-tomcat-7.0.68/conf/server.xml  
#AJP端口  
number03=830$b  
sed -i -e "s|8009|"$number03"|" /$path_top/$dir/apache-tomcat-7.0.68/conf/server.xml  
echo "Tomcat has been installed"  
  
  
echo "#############################"  
echo "tomcat_path=$path_top/$dir"  
echo "tomcat_prot=$number02"  
echo "Please manually put the firewall release "$number02" port"  




#!/bin/sh  
  
echo "============*******************================="  
echo "============ java 自动部署脚本 ================="  
echo "============*******************================="  
  
read -p "请输入将要部署的代码根路径: " rootDir  
read -p "请输入模块名: " prjName  
read -p "请输入程序名: " applicationName  
read -p "目标路径(tomcat路径): " targetPath  
read -p "请输入部署的分支名称(例如:master): " branch  
read -p "请输入部署的环境(例如:product|test|dev): " env  
# read -p "请输入程序操作(例如:restart|status): " handle  
read -p "是否需要从远程仓库pull代码(例如:y|n): " pull  