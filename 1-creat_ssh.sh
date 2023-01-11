#! /bin/bash
blue(){
    echo -e "\033[34m\033[01m$1\033[0m" 
    #控制码\033[01m设置高亮
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

#新建ssh用户
blue "=====开始新建linux用户====="
blue ""
blue "请输入所创建用户的用户名："
read username
useradd -s /bin/bash -c "AutoCBySScr_$username" -m $username  #-p $pwd4what 双引号变量有效，单引号变量无效
sleep 3
usermod -G sudo $username #把添加sudo用户组，sudoer文件中已分配sudo组权限
blue ""
blue ""
blue "=====已添加到sudo权限组====="
blue ""
blue ""
blue "请输入所创建用户的密码："
#read userpassword | 
passwd $username
#read userpassword
#添加如果错误的处理代码
sleep 1
green "=============================="
green "账户创建成功若密码输错,您也可以使用sudo passwd $username再次修改密码"
green "=============================="
green " "
green " "
blue "=====开始创建ssh密钥====="
cd /home/$username
#su $username
#mkdir .ssh
su - $username -c " ssh-keygen -t rsa -f "/home/$username/.ssh/id_rsa" "
sleep 2
cd .ssh
mv ./id_rsa.pub ./authorized_keys
green "请保存好你的ssh私钥,切勿泄露给他人,这将是你登录该服务器的唯一凭据"
green "$(cat /home/$username/.ssh/id_rsa)"


# #!/bin/bash

# # Check if the user exists
# if [ ! $(id -u "$1" > /dev/null 2>&1) ]; then
#   # Create the user
#   useradd "$1"

#   # Add the user to the sudo group
#   usermod -aG sudo "$1"

#   # Create the SSH key pair
#   su "$1" -c "ssh-keygen -t rsa -b 4096 -C '$1@server'"

#   # Print the public key
#   su "$1" -c "cat ~/.ssh/id_rsa.pub"
# else
#   echo "Error: user already exists."
# fi
#请注意，此脚本是示例代码，您可能需要根据自己的需求来更改它。您还可以通过修改命令行参数来自定义用户名、密钥类型和密钥长度等。