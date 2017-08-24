## 数据库配置

	容器启动先配置数据库

		mysql -uroot -p -e "SET PASSWORD FOR 'root'@'127.0.0.1'=PASSWORD('12wsxCDE#');"
		mysql -uroot -p -e "SET PASSWORD FOR 'root'@'localhost'=PASSWORD('12wsxCDE#');"
		mysql -uroot -p -e "CREATE DATABASE wemall DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
