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
# 检测是否只能由密钥登录
blue "开始sshd_config配置安全性检测……"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
blue "已备份sshd_config.bak"
# blue "1、确认是否允许root登录"

# check_root_login=$(cat /etc/ssh/sshd_config | grep PermitRootLogin | awk '{ print $2 }' | sed 's/[;]//g')

# if [ $check_root_login == "root" ]; 
# #no
# then
# 	red "检测到该服务器可使用root登录ssh!为了安全起见,将在60s后自动关闭root登录ssh权限"
#     # for time in `seq 9 -1 0`;do
# 	# echo -n -e "\b$time"
# 	# sleep 1
#     # done
# fi
blue "=====检测是否开启密码登录====="
check_passwd_login=$(cat /etc/ssh/sshd_config | grep -e 'PasswordAuthentication\s' | awk '{ print $2 }') #| sed 's/[;]//g')
#shell中的$(command)等效于`command`反引号，执行完command后把结果替换到command的位置接着外层执行
status_zhushi_pwd=$(cat /etc/ssh/sshd_config | grep -e '#PasswordAuthentication\s' | wc -l)
sleep 2
if [[ $check_passwd_login == "yes" && $status_zhushi_pwd -eq 0 ]]; 
#no 密码登录为yes且未被注释，则表示可以用密码登录
then
	red "检测到该服务器使用密码登录ssh!  为了安全起见,请使用密钥登录ssh"
elif [[ $check_passwd_login == "no" ]];
then 
    green "该服务器未开启密码登录"
else
    red "检测到未知配置情况，请手动到/etc/ssh/sshd_config中查看"
fi
sleep 2

blue "=====检测是否开启密钥登录====="
check_pubkey_login=$(cat /etc/ssh/sshd_config | grep PubkeyAuthentication | awk '{ print $2 }') #| sed 's/[;]//g') 
#tips：注释符要与前面)间隔开, login=$(必须不留空格，if判断]必须空格，推荐用双[[ ]]
status_zhushi_pk=$(cat /etc/ssh/sshd_config | grep \#PubkeyAuthentication | wc -l)
sleep 2
if [[ $check_pubkey_login == "no" || $status_zhushi_pk -eq 1 ]]; 
#no 如果密钥登录开关为no或者该条配置被注释，则判断为未开启密钥登录ssh
then
	red "检测到该服务器未开启密钥登录ssh"
 #   blue "正在开启……"
 #   sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config 
 #   sleep 2
 #   sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config  #这里测试，支持空格，否则用\s匹配空格
  #  systemctl restart sshd #ubuntu20
  #  green "执行结束"
elif [[ $check_pubkey_login == "yes" && $status_zhushi_pk -eq 0 ]];
then
    green "密钥登录功能已开启"
    green " "
	green " "
else
    red "遇到未知配置情况，请手动到/etc/ssh/sshd_config中查看"
fi

#这段代码主要是用来检查和修改 SSH 服务器的安全配置的。它检查了是否允许用 root 账号登录，是否开启密码登录和密钥登录，如果检测到安全风险，会提示用户并自动修改配置。代码中还包含几个颜色输出函数，用来在终端上输出不同颜色的文字。
