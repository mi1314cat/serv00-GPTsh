#!/bin/bash

# 获取当前用户名
USER=$(whoami)
USER_LOWER="${USER,,}"
USER_HOME="/home/${USER_LOWER}"
HYSTERIA_WORKDIR="${USER_HOME}/catmi/hy2"

# 定义 crontab 任务
XRAY_CRON_JOB="0 */12 * * * screen -S xray ${USER_HOME}/catmi/xray/xray run"
HY2_CRON_JOB="0 */12 * * * screen -S hy2 $HYSTERIA_WORKDIR/web server -c $HYSTERIA_WORKDIR/config.yaml"

# 定义函数来添加 crontab 任务，减少重复代码
add_cron_job() {
  local job=$1
  (crontab -l 2>/dev/null | grep -F "$job") || (crontab -l 2>/dev/null; echo "$job") | crontab -
}

# 添加 crontab 任务
echo "检查并添加 xray 的 crontab 任务"
add_cron_job "$XRAY_CRON_JOB"

echo "检查并添加 hy2 的 crontab 任务"
add_cron_job "$HY2_CRON_JOB"

echo "所有 crontab 任务添加完成"
