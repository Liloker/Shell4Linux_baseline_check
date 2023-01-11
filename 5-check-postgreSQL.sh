#!/bin/bash
#下面是一个用 shell 写的简单的检查 PostgreSQL 配置文件安全性的脚本，它检查了是否开启了密码认证、是否限制了客户端连接的 IP 地址、是否限制了客户端的访问权限：
# 检查 PostgreSQL 的配置文件是否存在
if [ ! -f /etc/postgresql/9.6/main/postgresql.conf ]; then
  echo "Error: PostgreSQL configuration file not found!"
  exit 1
fi

# 检查是否开启了密码认证
grep -q "^md5" /etc/postgresql/9.6/main/pg_hba.conf
if [ $? -ne 0 ]; then
  echo "Warning: password authentication is not enabled for PostgreSQL server!"
fi

# 检查是否限制了客户端连接的 IP 地址
grep -q "^host" /etc/postgresql/9.6/main/pg_hba.conf
if [ $? -ne 0 ]; then
  echo "Warning: PostgreSQL server is not bound to any specific IP address!"
fi

# 检查是否限制了客户端的访问权限
grep -q "^revoke" /etc/postgresql/9.6/main/postgresql.conf
if [ $? -ne 0 ]; then
  echo "Warning: PostgreSQL server allows access to all client commands!"
fi

echo "PostgreSQL configuration file security check completed successfully!"
#这段代码需要您根据实际情况修改配置文件的路径。同时，也可以添加更多的检查选项