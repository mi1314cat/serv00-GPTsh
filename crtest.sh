#!/bin/bash

# 获取当前用户名
USER=$(whoami)
USER_LOWER="${USER,,}"
USER_HOME="/home/${USER_LOWER}"
HYSTERIA_WORKDIR="${USER_HOME}/.hysteria"
HYSTERIA_CONFIG="${HYSTERIA_WORKDIR}/config.yaml"  # Hysteria 配置文件路径

# 定义 crontab 任务
CRON_HYSTERIA_START="@reboot pkill -kill -u $USER && nohup ${HYSTERIA_WORKDIR}/web server -c ${HYSTERIA_CONFIG} >/dev/null 2>&1 &"
CRON_HYSTERIA_CHECK="*/12 * * * * pgrep -x \"web\" > /dev/null || nohup ${HYSTERIA_WORKDIR}/web server -c ${HYSTERIA_CONFIG} >/dev/null 2>&1 &"
PM2_PATH="${USER_HOME}/.npm-global/lib/node_modules/pm2/bin/pm2"
CRON_PM2_JOB="*/12 * * * * $PM2_PATH resurrect >> ${USER_HOME}/pm2_resurrect.log 2>&1"

# 定义函数来添加 crontab 任务，减少重复代码
add_cron_job() {
  local job=$1
  (crontab -l 2>/dev/null | grep -F "$job" > /dev/null) || (echo "$job"; crontab -l 2>/dev/null) | crontab -
}

# 检查并添加 crontab 任务
echo "检查并添加 crontab 任务"

# 检查是否安装 pm2
if command -v pm2 > /dev/null 2>&1 && [[ $(which pm2) == "${USER_HOME}/.npm-global/bin/pm2" ]]; then
  echo "已安装 pm2 ，启用 pm2 保活任务"
  add_cron_job "$CRON_PM2_JOB"
else
  # Hysteria 的重启任务
  if [ -f "$HYSTERIA_CONFIG" ]; then
    echo "添加 Hysteria 的 crontab 重启任务"
    add_cron_job "$CRON_HYSTERIA_START"
    add_cron_job "$CRON_HYSTERIA_CHECK"
  fi
fi

# 输出当前 crontab 任务列表，便于检查
echo "当前 crontab 任务列表:"
crontab -l

echo "crontab 任务添加完成"
