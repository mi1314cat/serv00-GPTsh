#!/bin/sh

# 定义任务命令
CRON_JOB="@daily screen -dmS xray \$HOME/catmi/xray/xray run"

# 检查是否已有任务，避免重复添加
(crontab -l 2>/dev/null | grep -F "$CRON_JOB") && echo "Cron job already exists." && exit 0

# 追加任务到当前用户的 crontab
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Cron job added successfully."
