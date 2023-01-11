#! /bin/bash
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

# 第一项：SSH安全检测
check_sshd_config(){
    blue "=====第一项：开始sshd_config配置安全性检测====="
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    green "已备份sshd_config.bak"

    #======================================================================================================
    blue "1.检测是否允许root直接登录"

    check_root_login=$(cat /etc/ssh/sshd_config | grep -e '^PermitRootLogin' | awk '{ print $2 }' ) #| sed 's/[;]//g')
    status_zhushi_root=$(cat /etc/ssh/sshd_config | grep -e '#PermitRootLogin\s' | wc -l)
    sleep 2
    if [[ $check_root_login == "yes" && $status_zhushi_root -eq 0 ]]; 
    #no
    then
      red "检测到该服务器可使用root直接登录ssh！！！为了安全起见请关闭root身份直接登录ssh" #,将在60s后自动关闭root登录ssh权限"
        # for time in `seq 9 -1 0`;do
      # echo -n -e "\b$time"
      # sleep 1
        # done
    #elif [[ $check_root_login == "no" ]];
    #then 
    else
        green "该服务器未允许root身份直接登录ssh"
    #else
       # yellow "检测到未知配置情况，请手动到/etc/ssh/sshd_config中查看"
    fi
    #=========================================================================================================
    
    blue "2.检测是否开启密码登录"
    check_passwd_login=$(cat /etc/ssh/sshd_config | grep -e '^\s*PasswordAuthentication\s' | awk '{ print $2 }') #| sed 's/[;]//g')
    #shell中的$(command)等效于`command`反引号，执行完command后把结果替换到command的位置接着外层执行
    #status_zhushi_pwd=$(cat /etc/ssh/sshd_config | grep -e '#\s*PasswordAuthentication\s' | wc -l)
    #status_zhushi_pwd=$(cat /etc/ssh/sshd_config | grep -e '^\s*PasswordAuthentication\s' | wc -l)
    #以\s匹配开头为0或多个空格，后接着PasswordAu的那行
    sleep 2
    if [[ $check_passwd_login == "yes" ]] #&& $status_zhushi_pwd -eq 0 ]]; 
    #no 密码登录为yes且未被注释，则表示可以用密码登录
    then
      red "检测到该服务器使用密码登录ssh!  为了安全起见,请使用密钥登录ssh"
    elif [[ $check_passwd_login == "no" ]];
    then 
        green "该服务器未开启密码登录"
    #else
        #yellow "检测到未知配置情况，请手动到/etc/ssh/sshd_config中查看"
    fi
    sleep 2
    #=============================================================================================================
    blue "3.检测是否开启密钥登录"
    check_pubkey_login=$(cat /etc/ssh/sshd_config | grep -e '^\s*PubkeyAuthentication' | awk '{ print $2 }') #| sed 's/[;]//g') 
    #tips：注释符要与前面)间隔开, login=$(必须不留空格，if判断]必须空格，推荐用双[[ ]]
    #status_zhushi_pk=$(cat /etc/ssh/sshd_config | grep -e '#\s*PubkeyAuthentication' | wc -l)
    sleep 2
    if [[ $check_pubkey_login == "yes" ]] #|| $status_zhushi_pk -eq 1 ]]; 
    #no 如果密钥登录开关为no或者该条配置被注释，则判断为未开启密钥登录ssh
    then
      green "密钥登录功能已开启"
    #   blue "正在开启……"
    #   sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config 
    #   sleep 2
    #   sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config  #这里测试，支持空格，否则用\s匹配空格
      #  systemctl restart sshd #ubuntu20
      #  green "执行结束"
    else #[[ $check_pubkey_login == "yes" ]] #&& $status_zhushi_pk -eq 0 ]];
      red "该服务器未开启密钥登录ssh"
       # green "密钥登录功能已开启"
    #else
     #   yellow "遇到未知配置情况，请手动到/etc/ssh/sshd_config中查看"
    fi
    blue "SSH configuration file security check completed successfully!"
    #这段代码主要是用来检查和修改 SSH 服务器的安全配置的。它检查了是否允许用 root 账号登录，是否开启密码登录和密钥登录，如果检测到安全风险，会提示用户并自动修改配置。代码中还包含几个颜色输出函数，用来在终端上输出不同颜色的文字。
}
#=================================================================================================================
check_nginx_config(){
    blue "=====第二项：Nginx配置检测====="
    blue "1.检测Nginx执行身份"
    WhoisNginx=$(cat /etc/nginx/nginx.conf | grep -E '^user' | awk '{ print $2 }' | sed 's/[;]//g') #只匹配以^user开头的，此处用[^#]来排除#user情况不可取，正则表达式没问题，但是这里就是匹配不到，why?
    status_zhushi_root=$(cat /etc/nginx/nginx.conf | grep -E '#\s*user\s*root' | wc -l)
    sleep 1
    if [[ $WhoisNginx == "root" && $status_zhushi_pwd -eq 0 ]];
    #nginx用户为root且未匹配到被注释
    then
        red "检测到以root身份运行nginx服务……"
    else
    #user www-data;
        green "Nginx运行身份为$WhoisNginx"
    fi

    #检测nginx日志是否开启
    blue "2.检测Nginx日志开启情况"
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
    blue "Nginx configuration file security check completed successfully!"
    #access_log /var/log/nginx/access.log;
    #error_log /var/log/nginx/error.log
}
#===========================================================================
check_redis_config(){
    blue "=====第三项：Redis配置检测====="
    # 检查 redis 的配置文件是否存在
    if [ ! -f /etc/redis/redis.conf ]; then
      yellow "未检测到Redis"
    else
      # 检查 redis 是否开启了密码认证
      grep -q "^requirepass" /etc/redis/redis.conf
      #用于if逻辑判断 安静模式,不打印任何标准输出。如果有匹配的内容则立即返回状态值0，以requirepass为段落开头
      if [ $? -ne 0 ]; then
        red "Warning: password authentication is not enabled for redis server!"
      fi

      # 检查 redis 是否限制了客户端连接的 IP 地址
      grep -q "^bind" /etc/redis/redis.conf
      if [ $? -ne 0 ]; then
        red "Warning: redis server is not bound to any specific IP address!"
      fi

      # 检查 redis 是否限制了客户端的访问权限
      grep -q "^rename-command" /etc/redis/redis.conf
      if [ $? -ne 0 ]; then
        red "Warning: redis server allows access to all client commands!"
      fi
      blue "Redis configuration file security check completed successfully!"
    fi
}


#================================================================================================================================
check_postgreSQL96_config(){
    #下面是一个用 shell 写的简单的检查 PostgreSQL 配置文件安全性的脚本，它检查了是否开启了密码认证、是否限制了客户端连接的 IP 地址、是否限制了客户端的访问权限：
    blue "=====第四项：PostgreSQL 9.6配置检测====="
    # 检查 PostgreSQL 的配置文件是否存在
    if [ ! -f /etc/postgresql/9.6/main/postgresql.conf ]; then
      yellow "未检测到安装PostgreSQL 9.6"
    else
      # 检查是否开启了密码认证
      grep -q "^md5" /etc/postgresql/9.6/main/pg_hba.conf
      if [ $? -ne 0 ]; then
        red "Warning: password authentication is not enabled for PostgreSQL server!"
      fi

      # 检查是否限制了客户端连接的 IP 地址
      grep -q "^host" /etc/postgresql/9.6/main/pg_hba.conf
      if [ $? -ne 0 ]; then
        red "Warning: PostgreSQL server is not bound to any specific IP address!"
      fi

      # 检查是否限制了客户端的访问权限
      grep -q "^revoke" /etc/postgresql/9.6/main/postgresql.conf
      if [ $? -ne 0 ]; then
        red "Warning: PostgreSQL server allows access to all client commands!"
      fi
    green "PostgreSQL configuration file security check completed successfully!"
      #exit 1
    fi
    #这段代码需要您根据实际情况修改配置文件的路径。同时，也可以添加更多的检查选项
}
#===================================================================================================================
check_whichLog_enabled(){
    # Check if Linux host logging is enabled
    blue "=====第五项：主机日志开启情况====="
    blue "1.检测主机system日志开启情况"
    if [ -f /var/log/syslog ]; then
      green "主机system日志已开启"
    else
      red "主机system日志未开启"
    fi

    # Check if user command logging is enabled
    blue "2.检测用户日志开启情况"
    #wtmp日志文件记录了所有的登录过系统的用户信息，只记录了正确登录的用户。密码错误等所有尝试记录在btmp文件（lastb）和secure文件（可vim，记录整个登录过程的所有数据）中。是二进制文件，需要用last命令阅读 last -F，last --time-format iso
    if [ -f /var/log/wtmp ]; then
      green "已开启用户登录日志"
    else
      red "未开启用户登录日志"
    fi
}

#=======================================================================================================
echo ""
echo ""
echo ""
check_sshd_config;
echo ""
check_nginx_config;
echo ""
check_redis_config;
echo ""
check_postgreSQL96_config;
echo ""
check_whichLog_enabled;
echo ""



