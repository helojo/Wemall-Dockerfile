FROM docker.io/centos
MAINTAINER  teazj

#安装npm依赖包
RUN yum -y install https://kojipkgs.fedoraproject.org//packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm

#安装数据库
RUN yum -y install http://repo.mysql.com/yum/mysql-5.5-community/docker/x86_64/mysql-community-server-minimal-5.5.55-2.el7.x86_64.rpm

#安装软件
RUN yum -y install npm nginx node git wget openssh-server supervisor

#配置key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key     && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

#下载程序
RUN cd /root && git clone https://github.com/shen100/wemall.git

#修改配置
RUN cd /root/wemall/ && mv configuration.dev.json configuration.json
RUN sed -i 's/"Password"     : ""/"Password"     : "12wsxCDE#"/g' configuration.json
RUN sed -i 's/"User"         : ""/"User"         : "root"/g' configuration.json
RUN sed -i 's/"UploadImgDir"        : ""/"UploadImgDir"        : "/upload/img"/g' configuration.json

#初始化数据库
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm
RUN mysqld
RUN mysql -uroot -p -e "SET PASSWORD FOR 'root'@'127.0.0.1'=PASSWORD('12wsxCDE#');"
RUN mysql -uroot -p -e "SET PASSWORD FOR 'root'@'localhost'=PASSWORD('12wsxCDE#');"
RUN mysql -uroot -p -e "CREATE DATABASE wemall DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"


#导入数据
RUN mysql -uroot -p'12wsxCDE#' --default-character-set=utf8 wemall </root/wemall/sql/wemall.sql


#安装go
RUN wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz
RUN tar xf go1.8.3.linux-amd64.tar.gz -C /usr/local/
RUN rm go1.8.3.linux-amd64.tar.gz -rf

配置环境变量
ENV GOBIN=/usr/local/go/bin
ENV GOPATH=/root/wemall
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:$HOME/bin:$GOROOT/bin
RUN export PATH
RUN export GOPATH

#下载go库
git clone https://github.com/jinzhu/gorm /root/wemall/src/github.com/jinzhu/gorm/
git clone https://github.com/jinzhu/inflection  /root/wemall/src/github.com/jinzhu/inflection/
git clone https://github.com/satori/go.uuid /root/wemall/src/github.com/satori/go.uuid/
git clonehttps://github.com/go-sql-driver/mysql /root/wemall/src/github.com/go-sql-driver/mysql/
git clone https://gopkg.in/kataras/iris.v6  /root/wemall/src/gopkg.in/kataras/iris.v6/
git clone https://go.googlesource.com/crypto  /root/wemall/src/golang.org/x/crypto/
mkdir /root/wemall/src/wemall
cd /root/wemall && cp config controller model route utils /root/wemall/src/wemall/ -rpaf

#脚本
ADD conf/sshd.conf        /etc/supervisord.d/sshd.conf
ADD conf/nginx.conf        /etc/supervisord.d/nginx.conf
ADD conf/npm_start.conf        /etc/supervisord.d/npm_start.conf
ADD conf/staticServ.conf        /etc/supervisord.d/staticServ.conf
ADD conf/mysqld.conf        /etc/supervisord.d/mysqld.conf
ADD conf/main.conf        /etc/supervisord.d/main.conf
ADD conf/dev.wemall.com.conf /etc/nginx/conf.d/dev.wemall.com.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

#情况缓存
yum clean all

EXPOSE 80,443
CMD ["supervisord","-n","-c","/etc/supervisord.conf"]