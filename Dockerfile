FROM docker.io/centos
MAINTAINER  teazj

#安装npm依赖包
RUN yum -y install https://kojipkgs.fedoraproject.org//packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm   && \

#安装数据库
	yum -y install http://repo.mysql.com/yum/mysql-5.5-community/docker/x86_64/mysql-community-server-minimal-5.5.55-2.el7.x86_64.rpm   && \

#安装软件
	yum -y install npm nginx node git wget openssh-server	&& \

#配置key
	ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key     && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key     && \

#下载程序
	cd /root && git clone https://github.com/shen100/wemall.git    && \

#初始化数据库
	mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm    && \
#RUN mysqld &
#RUN mysql -uroot -p -e "SET PASSWORD FOR 'root'@'127.0.0.1'=PASSWORD('12wsxCDE#');"
#RUN mysql -uroot -p -e "SET PASSWORD FOR 'root'@'localhost'=PASSWORD('12wsxCDE#');"
#RUN mysql -uroot -p -e "CREATE DATABASE wemall DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"


#导入数据
#RUN mysql -uroot -p'12wsxCDE#' --default-character-set=utf8 wemall </root/wemall/sql/wemall.sql


#安装go
	wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz	&& \
	tar xf go1.8.3.linux-amd64.tar.gz -C /usr/local/   && \
	rm go1.8.3.linux-amd64.tar.gz -rf

#gopath
ADD conf/.bash_profile   /rot/.bash_profile
ADD conf/.bash_profile   /etc/profile.d/go

RUN source /root/.bash_profile     && \

#下载go库
	git clone https://github.com/jinzhu/gorm /root/wemall/src/github.com/jinzhu/gorm	   && \
	git clone https://github.com/jinzhu/inflection  /root/wemall/src/github.com/jinzhu/inflection	   && \
	git clone https://github.com/satori/go.uuid /root/wemall/src/github.com/satori/go.uuid	   && \
	git clone https://github.com/go-sql-driver/mysql /root/wemall/src/github.com/go-sql-driver/mysqld   && \
	git clone https://go.googlesource.com/crypto  /root/wemall/src/golang.org/x/crypto	   && \
	git clone https://gopkg.in/kataras/iris.v6  /root/wemall/src/gopkg.in/kataras/iris.v6	   && \
	mkdir /root/wemall/src/wemall	   && \
	cd /root/wemall && cp config controller model route utils /root/wemall/src/wemall/ -rpaf

#脚本
ADD conf/sshd.conf        /etc/supervisord.d/sshd.conf      && \
	conf/nginx.conf        /etc/supervisord.d/nginx.conf       && \
	conf/npm_start.conf        /etc/supervisord.d/npm_start.conf     && \
	conf/staticServ.conf        /etc/supervisord.d/staticServ.conf     && \
	conf/mysqld.conf        /etc/supervisord.d/mysqld.conf     && \
	conf/main.conf        /etc/supervisord.d/main.conf     && \
	conf/dev.wemall.com.conf /etc/nginx/conf.d/dev.wemall.com.conf     && \
	conf/nginx.conf /etc/nginx/nginx.conf     && \
	conf/configuration.json  /root/wemall/configuration.json     && \
	conf/supervisord.conf    /etc/supervisord.conf     && \

#supervisor 安装
	conf/get-pip.py /root/get-pip.py
RUN python /root/get-pip.py     && \
	pip install supervisor

#情况缓存
	yum clean all     && \

EXPOSE 80
EXPOSE 443
CMD ["supervisord","-n","-c","/etc/supervisord.conf"]