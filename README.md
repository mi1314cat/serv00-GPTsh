
### serv00一键安装hysteria2脚本
```bash
bash <(curl -fsSL https://github.com/mi1314cat/serv00-GPTsh/raw/main/serv00-hy2)

```
```bash
bash <(curl -fsSL https://github.com/mi1314cat/serv00-GPTsh/raw/refs/heads/main/ngxray.sh)

```

## Github Actions保活
添加 Secrets.`ACCOUNTS_JSON` 变量
```json
[
  {"username": "catmi", "password": "*********", "panel": "panel12.serv00.com", "ssh": "s12.serv00.com"},
  {"username": "catmi1", "password": "*********", "panel": "panel13.serv00.com", "ssh": "s13.serv00.com"},
  {"username": "catmi2", "password": "**********", "panel": "panel.ct8.pl", "ssh": "s1.ct8.pl"}
]
```
# cloudflare worker部署保活
## cloudflare 部署步骤
- 复制worker.js代码到cloudflare Workers保存
- Workers设置变量名称，添加 ACCOUNTS_JSON TELEGRAM_JSON 值，替换自己的账号 密码 面板
- 在设置里设置Cron 触发器，设置触发时间。

## worker部署变量
添加变量名称 ACCOUNTS_JSON 
添加变量值，复制下面代码替换成自己的账号 密码 面板

```json
[  
  { "username": "serv00user1", "password": "serv00password1", "panelnum": "0", "type": "serv00" },
  { "username": "serv00user2", "password": "serv00password2", "panelnum": "4", "type": "serv00" },
  { "username": "serv00user3", "password": "serv00password3", "panelnum": "7", "type": "serv00" },
  { "username": "ct8user1", "password": "ct8password1", "type": "ct8" },
  { "username": "ct8user2", "password": "ct8password2", "type": "ct8" }
]
```

添加变量名称 TELEGRAM_JSON 
添加变量值，复制下面代码替换成自己的TG TOKEN ID

```json
{
  "telegramBotToken": "YOUR_BOT_TOKEN",
  "telegramBotUserId": "YOUR_USER_ID"
}
```

