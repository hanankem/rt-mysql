#!/bin/bash

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
LINE=#################################################################################
#Check if runing as root
if [ `whoami` != 'root' ];
then
echo "You must run this script as root"
exit
fi
lsb_release -a | grep Ubuntu > /dev/null
if [[ $? != 0 ]]; then
	echo "This script should be run on Ubuntu"
	exit
fi

docker > /dev/null 2>&1
if  [ $? = 0 ]; then
	echo $LINE
	echo "		Docker is installed"
	echo $LINE
	sleep 2
else
	echo $LINE
	echo "		Installing Docker. This may take a while"
	echo $LINE
	sudo apt-get update -y > /dev/null
	sudo apt-get install docker.io -y > /dev/null
fi
if [ -d "/dbstart" ]
then
    mv /dbstart /dbstart.back
    mkdir /dbstart
else
    mkdir /dbstart
fi
TYPE=mysql
							DRIVER=com.mysql.jdbc.Driver
							URL='jdbc:mysql://<MACHINE_IP>:3306/artdb?characterEncoding=UTF-8&elideSetAutoCommits=true&useSSL=false'
							DRIVERURL=https://dev.mysql.com/downloads/connector/j/
							PASSWORD=password
                                    rm -fr /"$TYPE"-data
                                    mkdir -p /"$TYPE"-data
									#This script is executed by the db when the container is created
									cat <<EOF > /dbstart/artdb.sql
CREATE DATABASE artdb CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'artifactory'@'%' IDENTIFIED BY 'password';
GRANT ALL on artdb.* TO 'artifactory'@'%';
FLUSH PRIVILEGES;
EOF


									read -p "Please choose MySQL version version [5.5/5.6/5.7]:" VERS
									docker run --name mysql-artifactory -e MYSQL_ROOT_PASSWORD=password -v /mysql-data:/var/lib/mysql -v /dbstart:/docker-entrypoint-initdb.d -p 3306:3306 -d mysql:"$VERS"
echo $LINE

									echo "Done"
									echo "All the data is located under /$TYPE-data"
									echo "The snippet can be found under the home directory"
									echo "You can download the db driver from: $DRIVERURL "
echo $LINE
cat <<EOF >$HOME/snippet

For Artifactory under 7.x use this and place it under /etc/db.properties

type=$TYPE
driver=$DRIVER
url=$URL
username=artifactory
password=$PASSWORD

For artifactory 7 use this and place it under system.yaml

shared:
  database:
    type: $TYPE
    driver: $DRIVER
    url: $URL
    username: artifactory
    password: $PASSWORD

EOF
