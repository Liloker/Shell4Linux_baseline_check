#!/bin/bash

# Get the log file path from the command line argument
log_file=$1

# Check if the log file exists
if [ -f "$log_file" ]; then
  # Search for attack strings in the log file
  if grep -E -q "(wget|curl|nc) \-O" "$log_file"; then
    echo "Possible attack detected in the log file."
  else
    echo "No attack detected in the log file."
  fi
else
  echo "Error: log file not found."
fi
#请注意，此脚本是示例代码，您可能需要根据自己的需求来更改它。您可以通过添加更多的攻击特征字符串来增强日志审计的能力。

# nginx日志中常见的攻击特征字符串包括但不限于：

# wget -O: 这种字符串通常表示攻击者使用wget命令来下载并覆盖服务器上的文件。
# curl -O: 这种字符串通常表示攻击者使用curl命令来下载并覆盖服务器上的文件。
# nc -e: 这种字符串通常表示攻击者使用nc命令来执行本地命令。
# ; rm -rf: 这种字符串通常表示攻击者尝试删除服务器上的所有文件。
# eval(base64_decode(: 这种字符串通常表示攻击者尝试通过Base64解码来执行PHP代码。
# 当然，这只是一个简单的例子，攻击者可以使用更多复杂的字符串来攻击服务器。因此，您需要根据实际情况来定制自己的日志审计脚本。