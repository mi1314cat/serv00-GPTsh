

#!/bin/bash

# 获取当前用户名
USER=$(whoami)
USER_LOWER="${USER,,}"
USER_HOME="/home/${USER_LOWER}"

# 定义 crontab 任务
CRON_JOB="0 */12 * * * screen -S xray ${USER_HOME}/catmi/xray/xray run"

# 定义函数来添加 crontab 任务，减少重复代码
add_cron_job() {
  local job=$1
  (crontab -l 2>/dev/null | grep -F "$job") || (crontab -l 2>/dev/null; echo "$job") | crontab -
}

# 添加 crontab 任务
echo "检查并添加 crontab 任务"
add_cron_job "$CRON_JOB"
echo "crontab 任务添加完成"
