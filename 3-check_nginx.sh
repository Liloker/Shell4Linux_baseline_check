#！\bin\bash
#初始版本只检测nginx运行时的执行权限是否为root，两个日志是否开启
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}


#检测nginx执行身份
blue "检测nginx执行身份……"
WhoisNginx=$(cat /etc/nginx/nginx.conf | grep -E '^user' | awk '{ print $2 }' | sed 's/[;]//g') #只匹配以^user开头的，此处用[^#]来排除#user情况不可取，正则表达式没问题，但是这里就是匹配不到，why?
status_zhushi_root=$(cat /etc/nginx/nginx.conf | grep -E '#\s*user\s*root' | wc -l)
sleep 1
if [[ $WhoisNginx == "root" && $status_zhushi_pwd -eq 0 ]];
#nginx用户为root且未匹配到被注释
then
    red "检测到以root身份运行nginx服务……"
else
#user www-data;
    green "nginx运行身份为$WhoisNginx"
fi

#检测nginx日志是否开启
blue "检测nginx日志开启情况……"
sleep 2
status_zhushi_log=$(cat /etc/nginx/nginx.conf | grep -E '#\s*(access|error)_log' | wc -l)
#status2_log=$(cat /etc/nginx/nginx.conf | grep -E '^(access|error)_log' | wc -l)
status_zhushi2_log=($status_zhushi_log+2) 
status_nozhushi_log=$(cat /etc/nginx/nginx.conf | grep -E '(access|error)_log' | wc -l)
sleep 1
if [[ status_zhushi2_log -le $status_nozhushi_log ]];
#nginx默认两个日志开启,防止因为注释保留导致错误故+2后比较,正向排除#难搞就逆向求有#注释的，然后相减
then
    green "nginx两个日志均已开启"
else
    red "需要将nginx.conf中的access_log和error_log全部开启"
fi
#access_log /var/log/nginx/access.log;
#error_log /var/log/nginx/error.log


