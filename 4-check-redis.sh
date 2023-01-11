#!/bin/bash

# 检查 redis 的配置文件是否存在
if [ ! -f /etc/redis/redis.conf ]; then
  echo "Error: redis configuration file not found!"
  exit 1
fi

# 检查 redis 是否开启了密码认证
grep -q "^requirepass" /etc/redis/redis.conf
#用于if逻辑判断 安静模式,不打印任何标准输出。如果有匹配的内容则立即返回状态值0，以requirepass为段落开头
if [ $? -ne 0 ]; then
  echo "Warning: password authentication is not enabled for redis server!"
fi

# 检查 redis 是否限制了客户端连接的 IP 地址
grep -q "^bind" /etc/redis/redis.conf
if [ $? -ne 0 ]; then
  echo "Warning: redis server is not bound to any specific IP address!"
fi

# 检查 redis 是否限制了客户端的访问权限
grep -q "^rename-command" /etc/redis/redis.conf
if [ $? -ne 0 ]; then
  echo "Warning: redis server allows access to all client commands!"
fi

echo "Redis configuration file security check completed successfully!"


