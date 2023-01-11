
# Check if Linux host logging is enabled
if [ -f /var/log/syslog ]; then
  echo "Linux host logging is enabled."
else
  echo "Linux host logging is not enabled."
fi

# Check if user command logging is enabled
if [ -f /var/log/wtmp ]; then
  echo "User command logging is enabled."
else
  echo "User command logging is not enabled."
fi

#请注意，此脚本是示例代码，您可能需要根据自己的需求来更改它。您还可以查看/var/log目录下的其他文件，以查看其他日志是否开启。