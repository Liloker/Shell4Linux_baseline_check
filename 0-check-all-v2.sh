#! /bin/bash
blue(){ echo -e "\033[34m\033[01m$1\033[0m"
} #此处括号必须换行，echo前必须空格
green(){ echo -e "\033[32m\033[01m$1\033[0m"
}
red(){ echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m"
}
check_sshd_config(){
    blue "=====第一项：sshd_config配置安全性检测====="
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    green "已备份sshd_config.bak"
    #======================================================================================================
    blue "1.检测是否允许root直接登录"
    check_root_login=$(cat /etc/ssh/sshd_config | grep -e '^\s*PermitRootLogin' | awk '{ print $2 }' ) #| sed 's/[;]//g')
    sleep 1
    grep -e '^\s*PermitRootLogin' /etc/ssh/sshd_config
    if [[ $check_root_login == "yes" || $check_root_login == "Yes" ]];
    then
      red "检测到该服务器可使用root直接登录ssh！为了安全起见请关闭root身份直接登录ssh" #,将在60s后自动关闭root登录ssh权限"
        # for time in `seq 9 -1 0`;do
      # echo -n -e "\b$time"
      # sleep 1
        # done
    #elif [[ $check_root_login == "no" ]];
    #then 
    else
      green "该服务器未允许root身份直接登录ssh"
    fi
    #=========================================================================================================
    
    blue "2.检测是否开启密码登录"
    check_passwd_login=$(cat /etc/ssh/sshd_config | grep -e '^\s*PasswordAuthentication\s' | awk '{ print $2 }') #| sed 's/[;]//g')
    # $(command)等效于`command` ，执行完command后把结果替换到command的位置接着外层执行
    #status_zhushi_pwd=$(cat /etc/ssh/sshd_config | grep -e '#\s*PasswordAuthentication\s' | wc -l)
    #status_zhushi_pwd=$(cat /etc/ssh/sshd_config | grep -e '^\s*PasswordAuthentication\s' | wc -l)
    #以\s匹配开头为0或多个空格，后接着PasswordAu的那行
    sleep 1
    cat /etc/ssh/sshd_config | grep -e '^\s*PasswordAuthentication\s'
    if [[ $check_passwd_login == "yes" || $check_passwd_login == "Yes" ]] #no 密码登录为yes且未被注释，则表示可以用密码登录
    then
      red "检测到该服务器使用密码登录ssh!  为了安全起见,请使用密钥登录ssh;"
    elif [[ $check_passwd_login == "no" || $check_passwd_login == "No" ]];
    then 
        green "该服务器未开启密码登录"
    else
        yellow "未检测到有效配置"
    fi
    sleep 1
    #=============================================================================================================
    blue "3.检测是否开启密钥登录"
    check_pubkey_login=$(cat /etc/ssh/sshd_config | grep -e '^\s*PubkeyAuthentication' | awk '{ print $2 }') #| sed 's/[;]//g') 
    #tips：注释符要与前面)间隔开, login=$(必须不留空格，if判断]必须空格，用双[[ ]]
    sleep 1
    cat /etc/ssh/sshd_config | grep -e '^\s*PubkeyAuthentication'
    if [[ $check_pubkey_login == "yes" || $check_pubkey_login == "Yes" ]];#no 如果密钥登录开关为no或者该条配置被注释，则判断为未开启密钥登录ssh
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
    fi
    blue "SSH configuration file security check completed successfully!"
}
#=================================================================================================================
check_nginx_config(){
    blue "=====第二项：Nginx配置检测====="
    #先检测是否存在nginx
    blue "1.检测运行身份"
    WhoisNginx=$(cat /etc/nginx/nginx.conf | grep -E '^user' | awk '{ print $2 }' | sed 's/[;]//g') #只匹配以^user开头的，此处用[^#]来排除#user情况不可取，正则表达式没问题，但是这里就是匹配不到，why?
    status_zhushi_root=$(cat /etc/nginx/nginx.conf | grep -E '#\s*user\s*root' | wc -l)
    sleep 1
    if [[ $WhoisNginx == "root" && $status_zhushi_pwd -eq 0 ]];
    #nginx用户为root且未匹配到被注释
    then
        red "检测到以root身份运行nginx服务……"
    else
        green "Nginx运行身份为$WhoisNginx"
    fi
    blue "2.检测Nginx日志开启情况"
    #status_zhushi_log=$(cat /etc/nginx/nginx.conf | grep -E '#\s*(access|error)_log' | wc -l)
    #status2_log=$(cat /etc/nginx/nginx.conf | grep -E '^(access|error)_log' | wc -l)
    #status_zhushi2_log=($status_zhushi_log+2) 
    status_nozhushi_log=$(cat /etc/nginx/nginx.conf | grep -E '^\s*(access|error)_log' | wc -l)
    sleep 1
    cat /etc/nginx/nginx.conf | grep -E '^\s*(access|error)_log'
    #if [[ status_zhushi2_log -le $status_nozhushi_log ]];
    if [[ status_nozhushi_log -eq 2 ]]
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
check_mysql_config(){
    blue "=====第三项：Mysql配置检测====="
    if [ ! -d /etc/mysql ]; 
        then
          yellow "未检测到安装Mysql"
        else
          blue "1.检测Mysql默认root账户密码"
          #检测是否为root设置密码
          #if [ -z "$(mysql -u root -e 'select @@validate_password.length;')" ]; 
          # result=$(mysql -u root -p"" -e "SELECT 'host' FROM mysql.user WHERE user='root' ")
          if [ -z "$(mysql -u root -e 'SELECT 'host' FROM mysql.user WHERE user='root'' 2>/dev/null )"  ]; #如果查成功了，说明没有密码，如果没查成功,access denied 抛出异常，但命令正常退出返回为0，那大概率有密码
          then #-z 后面string长度为0则为真
              green "MySQL已经设置了root密码." #判断逻辑有点问题
          else
              red "Mysql未设置root密码"
          fi
          #检测是否开启error日志
          blue "2.检测Mysql日志开启情况"
          sleep 1
          if pgrep "mysqld" > /dev/null
          then
              yellow "MySQL is running."
              # Check if general query log is enabled
              if [ ! -f /var/log/mysql/error.log ]; 
              then
                  red "未检测到error.log文件，请检查是否开启mysql日志"
              else
                  green "已开启error.log"
              fi
          else
              yellow "MySQL is not running."
              #exit 1
          fi
          #tree -L 1 /var/log/
          blue "Mysql configuration file security check completed successfully!"
        fi
}

#===========================================================================
check_redis_config(){
    blue "=====第四项：Redis配置检测====="
    if [ ! -f /etc/redis/redis.conf ]; 
    then
      yellow "未检测到Redis"
    else
      if pgrep "redis" > /dev/null
      then
          yellow "redis is running."
          blue "1.检查 redis 是否开启了密码认证"
          redis_passwd=$(grep -e '^\s*requirepass' /etc/redis/redis.conf | awk '{ print $2 }' | wc -l )
          #grep -q "^requirepass" /etc/redis/redis.conf
          #-q用于if逻辑判断 安静模式,不打印任何标准输出。
          grep -e '^\s*requirepass' /etc/redis/redis.conf
          if [[ $redis_passwd -eq 1 ]]; 
          then
            green "Redis已开启密码保护"
          else
            red "Warning: password authentication is not enabled for redis server!"
          fi

          blue "2.检查 redis 是否限制客户端连接的 IP 地址"
          #grep -q "^bind" /etc/redis/redis.conf
          redis_bind_IP=$(grep -e '^\s*bind' /etc/redis/redis.conf | awk '{ print $2 }' | wc -l )
          redis_bind_IPinfo=$(grep -e '^\s*bind' /etc/redis/redis.conf | awk '{ print $2 }' )
          sleep 1
          grep -e '^\s*bind' /etc/redis/redis.conf
          if [[ $redis_bind_IP -eq 0 || "$redis_bind_IPinfo" == "0.0.0.0"  ]];
          then
            red "Warning: redis未对访问IP做出限制!"
          else
            green "redis对访问IP有限制:$redis_bind_IPinfo"
          fi

          # blue "3.检查 redis 是否限制了客户端的访问权限，是否禁用高危指令"
          # redis_rename_command=$(grep -e "^\s*rename-command" /etc/redis/redis.conf | awk '{ print $2 }' | wc -l )
          # if [[ $redis_rename_command -ne 0 ]]; 
          # then
          #   green "redis已启用rename_command配置"
          # else
          #   red "Warning: redis server allows access to all client commands!"
          # fi
          # grep -e "^\s*rename-command" /etc/redis/redis.conf
      else
          yellow "redis is not running."
          #exit 1
      fi
      blue "Redis configuration file security check completed successfully!"
    fi
}
#================================================================================================================================
check_postgreSQL96_config(){
    #下面检查了是否开启了密码认证、是否限制了客户端连接的 IP 地址、是否限制了客户端的访问权限：
    blue "=====第五项：PostgreSQL 9.6配置检测====="
    # 检查 PostgreSQL 的配置文件是否存在，存在9.5版本
    sleep 2
    if [ ! -d /etc/postgresql ]; 
    then
      yellow "未检测到安装PostgreSQL"
    else
      blue "检测到已安装PostgreSQL"
      blue "1.检查是否开启了密码认证"
      # for((i=0;i<5;i++)); 
      # do
      #   ver=[9.6;10]
      #   $v=ver{i}
      #   echo "版本是$v"
      #   postgreSQL_passwd=$(grep -e "\s*md5" /etc/postgresql/${v}/main/pg_hba.conf | awk '{ print $2 }' | wc -l )
      # done
      postgreSQL_passwd=$(grep -e "\s*md5" /etc/postgresql/9.6/main/pg_hba.conf | awk '{ print $2 }' | wc -l )
      
      if [ $postgreSQL_passwd -eq 0 ]; 
      then
        red "Warning: password authentication is not enabled for PostgreSQL server!"
      fi

      blue "2.检查是否限制客户端连接 IP "
      postgreSQL_clint_IP=$(grep -e "^\s*host" /etc/postgresql/9.6/main/pg_hba.conf | awk '{ print $2 }' | wc -l )
      #postgreSQL_clint_IPinfo=$(grep -e "^\s*host" /etc/postgresql/9.6/main/pg_hba.conf | awk '{ print $4 }'  )
      postgreSQL_clint_IPinfo=$(grep -e "0.0.0.0" /etc/postgresql/9.6/main/pg_hba.conf | awk '{ print $4 }' | wc -l )
      if [[ $postgreSQL_clint_IP -ge 1 && $postgreSQL_clint_IPinfo -ge 1 ]]; 
      then
        red "Warning: PostgreSQL server is not bound to any specific IP address!"
      else
        green "PostgreSQL server配置无0.0.0.0"
      fi

      # blue "3.检查是否限制了客户端的访问权限，revoke权限回收配置 "
      # postgreSQL_clint_revoke=$(grep -q "^\s*revoke" /etc/postgresql/9.6/main/postgresql.conf | awk '{ print $2 }' | wc -l )
      # if [ $postgreSQL_clint_revoke -eq 0 ]; 
      # then
      #   red "Warning: PostgreSQL server allows access to all client commands!"
      # fi
    blue "PostgreSQL configuration file security check completed successfully!"
      #exit 1
    fi
    #这段代码需要修改配置文件的路径
}
#===================================================================================================================
check_whichLog_enabled(){
    # Check if Linux host logging is enabled
    blue "=====第六项：主机日志开启情况====="
    blue "1.检测主机system日志开启情况"
    if [ -f /var/log/syslog ]; 
    then
      green "主机system日志已开启"
    else
      red "主机system日志未开启"
    fi
    # Check if user command logging is enabled
    blue "2.检测用户日志开启情况"
    #wtmp日志文件记录了所有的登录过系统的用户信息，只记录了正确登录的用户。密码错误等所有尝试记录在btmp文件（lastb）和secure文件（可vim，记录整个登录过程的所有数据）中。是二进制文件，需要用last命令阅读 last -F，last --time-format iso
    if [ -f /var/log/wtmp ]; 
    then
      green "已开启用户登录日志"
    else
      red "未开启用户登录日志"
    fi
    blue "Logs security checked successfully!"
}

#=======================================================================================================
echo ""
echo ""
echo ""
check_sshd_config;
echo ""
check_nginx_config;
echo ""
check_mysql_config;
echo ""
check_redis_config;
echo ""
check_postgreSQL96_config;
echo ""
check_whichLog_enabled;
echo ""
echo ""
green "===========检测结束==========="
echo ""
echo ""