#!/bin/bash

# 输出图案和面板信息
printf "\e[92m"
printf "                       |\\__/,|   (\\\\ \n"
printf "                     _.|o o  |_   ) )\n"
printf "       -------------(((---(((-------------------\n"
printf "                       serv00-catmi \n" 
printf "       -----------------------------------------\n"
printf "\e[0m"

# 提供安装选项
echo "请选择要执行的操作:"
echo "1. 安装 Xray"
echo "2. 安装 Hy2"
echo "3. 清理服务"
echo "0. 退出脚本"

# 读取用户输入
read -p "请输入选项 (0/1/2/3): " option

case $option in
  1)
    # 安装 Xray
    echo "正在安装 Xray..."
    bash <(curl -fsSL https://github.com/mi1314cat/serv00-GPTsh/raw/refs/heads/main/ngxray.sh)
    ;;
  2)
    # 安装 Hy2
    echo "正在安装 Hy2..."
    bash <(curl -fsSL https://github.com/mi1314cat/serv00-GPTsh/raw/main/serv00-hy2)
    ;;
  3)
    # 清理服务
    echo "正在清理服务..."
    USER=$(whoami)
    
    # 杀死当前用户的所有进程
    pkill -kill -u ${USER}
    
    # 修改当前用户的文件权限
    chmod -R 755 ~/* 
    chmod -R 755 ~/.* 
    
    # 删除当前用户主目录下的所有文件（注意：此操作不可恢复）
    rm -rf ~/.* 
    rm -rf ~/*

    echo "服务已清理完毕。"
    ;;
  0)
    # 退出脚本
    echo "退出脚本"
    exit 0
    ;;
  *)
    # 无效选项
    echo "无效的选项，退出脚本。"
    exit 1
    ;;
esac
