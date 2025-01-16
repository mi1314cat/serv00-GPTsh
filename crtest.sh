#!/bin/bash

# 获取当前用户的主目录
USER_HOME="$HOME"

# 定义 crontab 任务
XRAY_CRON_JOB="0 */12 * * * screen -S xray ${USER_HOME}/catmi/xray/xray run"
NGINX_CRON_JOB="0 */6 * * * ${USER_HOME}/catmi/nginx/sbin/nginx -c ${USER_HOME}/catmi/nginx/conf/nginx.conf"

# 定义函数来添加 crontab 任务，减少重复代码
add_cron_job() {
  local job=$1
  # 检查是否已存在任务
  if (crontab -l 2>/dev/null | grep -qF "$job"); then
    echo "任务已存在：$job"
  else
    (crontab -l 2>/dev/null; echo "$job") | crontab -
    if [[ $? -eq 0 ]]; then
      echo "成功添加任务：$job"
    else
      echo "添加任务失败：$job" >&2
      exit 1
    fi
  fi
}

# 检查所需命令是否存在
check_command() {
  local cmd=$1
  if ! command -v "$cmd" &>/dev/null && [[ ! -x "$cmd" ]]; then
    echo "错误：未找到命令 $cmd，请先安装或检查路径。" >&2
    exit 1
  fi
}

# 主程序
echo "检查所需命令..."
check_command "screen"
check_command "${USER_HOME}/catmi/xray/xray"
check_command "${USER_HOME}/catmi/nginx/sbin/nginx"

echo "检查并添加 crontab 任务..."
add_cron_job "$XRAY_CRON_JOB"
add_cron_job "$NGINX_CRON_JOB"
echo "crontab 任务处理完成。"
