#!/bin/bash
#需求：用shell写一个检测防火墙开了哪些服务和端口的脚本，并把结果输出到TXT后缀文件中然后传给另一台linux服务器上的某个路径下
#请注意，此脚本是示例代码，您可能需要根据自己的需求来更改它。您可以通过添加更多的检查（例如检查防火墙是否启用）来增强脚本的功能。
# Get the IP address and path from the command line arguments
server_ip=$1
path=$2

# Check if the server is reachable
if ping -c 1 "$server_ip" > /dev/null; then
  # Check the firewall rules
  rules=$(iptables -L)

  # Save the rules to a file
  echo "$rules" > firewall_rules.txt

  # Transfer the file to the server
  scp firewall_rules.txt "$server_ip:$path"
else
  echo "Error: server is not reachable."
fi