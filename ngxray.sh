#!/bin/bash

# 获取当前用户的主目录
USER_HOME="$HOME"

# 输出主目录路径
echo "用户主目录路径: $USER_HOME"



# 生成 UUID
generate_uuid() {
    uuidgen
}

# 示例操作：进入用户主目录
cd "$USER_HOME" || exit
echo "当前目录: $(pwd)"
mkdir -p catmi/nginx catmi/xray

# 提示输入监听端口号
read -p "请输入 Vless 监听端口: " PORT
PORT=${PORT:-5655}
read -p "请输入 reality 监听端口: " port
port=${port:-9999}
read -p "请输入证书域名: " DOMAIN_LOWER
# 生成 UUID 和 WS 路径
UUID=$(generate_uuid)


# 申请证书
ssl() {
   cd $USER_HOME
   read -p "请输入 cfapi: " api
   read -p "请输入 cf邮箱: " mail
   curl https://get.acme.sh | sh
   ~/.acme.sh/acme.sh --register-account -m ${mail}
   export CF_Token="${api}"
   export CF_Email="${mail}"
   ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${DOMAIN_LOWER}
}

# 安装 nginx
nginx() {
    cd $USER_HOME/catmi
    wget http://nginx.org/download/nginx-1.25.2.tar.gz
    tar -xzf nginx-1.25.2.tar.gz
    rm -rf nginx-1.25.2.tar.gz
    cd nginx-1.25.2
    ./configure --prefix=$USER_HOME/catmi/nginx --with-http_ssl_module --with-http_v2_module --with-http_sub_module --with-stream --with-stream_ssl_module
    make
    make install
    cd $USER_HOME/catmi
    rm -rf nginx-1.25.2

    # 配置 nginx
    cat << EOF > $USER_HOME/catmi/nginx/conf/nginx.conf
worker_processes  1;
error_log  $USER_HOME/catmi/nginx/logs/error.log;
pid        $USER_HOME/catmi/nginx/logs/nginx.pid;

events { worker_connections  1024; }

http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '\
                     '\$status \$body_bytes_sent "\$http_referer" '\
                     '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  $USER_HOME/catmi/nginx/logs/access.log  main;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen ${PORT} ssl;
        server_name ${DOMAIN_LOWER};
        http2 on;
        ssl_certificate       "$USER_HOME/.acme.sh/${DOMAIN_LOWER}_ecc/fullchain.cer";
        ssl_certificate_key   "$USER_HOME/.acme.sh/${DOMAIN_LOWER}_ecc/${DOMAIN_LOWER}.key";
        ssl_session_timeout 1d;
        ssl_session_cache shared:MozSSL:10m;
        ssl_session_tickets off;
        ssl_protocols    TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;

        location / {
            proxy_pass https://pan.imcxx.com;
            proxy_redirect off;
            proxy_ssl_server_name on;
            sub_filter_once off;
            sub_filter "pan.imcxx.com" \$server_name;
            proxy_set_header Host "pan.imcxx.com";
            proxy_set_header Referer \$http_referer;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header User-Agent \$http_user_agent;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header Accept-Encoding "";
            proxy_set_header Accept-Language "zh-CN";
        }

        location /VH1TaxC2d6 {
            proxy_redirect off;
            proxy_pass http://127.0.0.1:${PORT};
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
        }

        location /aCK13LYyWM {
            proxy_request_buffering off;
            proxy_redirect off;
            proxy_pass http://127.0.0.2:${PORT};
            proxy_http_version 1.1;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF

    # 启动 nginx
     # 定义 crontab 任务
    CRON_JOB_NGINX="0 */12 * * * screen -S nginx $USER_HOME/catmi/nginx/sbin/nginx -c $USER_HOME/catmi/nginx/conf/nginx.conf"

    # 添加 crontab 任务
    (crontab -l 2>/dev/null | grep -F "$CRON_JOB_NGINX") || (crontab -l 2>/dev/null; echo "$CRON_JOB_NGINX") | crontab -

    # 启动 Xray
    screen -dmS nginx $USER_HOME/catmi/nginx/sbin/nginx -c $USER_HOME/catmi/nginx/conf/nginx.conf
    
}

# 安装 xray
xray() {
    cd $USER_HOME/catmi/xray
    wget https://github.com/XTLS/Xray-core/releases/download/v24.12.31/Xray-freebsd-64.zip
    unzip Xray-freebsd-64.zip
    rm -rf Xray-freebsd-64.zip
    chmod +x xray

    cat <<EOF > $USER_HOME/catmi/xray/config.json
{
    "log": {
        "disabled": false,
        "level": "info",
        "timestamp": true
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": ${PORT},
            "tag": "VLESS-WS",
            "protocol": "VLESS",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "alterId": 64
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/VH1TaxC2d6"
                }
            }
        },
        {
            "listen": "127.0.0.2",
            "port": ${PORT},
            "protocol": "vless",
            "settings": {
                "decryption": "none",
                "clients": [
                    {
                        "id": "${UUID}"
                    }
                ]
            },
            "streamSettings": {
                "network": "xhttp",
                "xhttpSettings": {
                    "path": "/aCK13LYyWM"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ]
            },
            "tag": "in1"
        },
        {
            "listen": "0.0.0.0",
            "port": ${port},
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                      "dest": ${PORT}
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": true,
                    "dest": "swift.com:443",
                    "xver": 0,
                    "serverNames": [
                        "swift.com"
                    ],
                    "privateKey": "AH4KvC_bkqp1lzOsBafBeM-pcotZHgCar93FYe6SFgQ",
                    "minClientVer": "",
                    "maxClientVer": "",
                    "maxTimeDiff": 0,
                    "shortIds": [
                        "f286e42f0a4823f1"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
EOF

    # 定义 crontab 任务
    XRAY_CRON_JOB="0 */12 * * * screen -S xray $USER_HOME/catmi/xray/xray run"

    # 添加 crontab 任务
    (crontab -l 2>/dev/null | grep -F "$XRAY_CRON_JOB") || (crontab -l 2>/dev/null; echo "$XRAY_CRON_JOB") | crontab -

    # 启动 Xray
    screen -dmS xray $USER_HOME/catmi/xray/xray run
}

ssl
nginx
xray
share_link="
vless://${UUID}@${DOMAIN_LOWER}:443?encryption=none&security=tls&sni=${DOMAIN_LOWER}&type=ws&host=${DOMAIN_LOWER}&path=%2FaCK13LYyWM#vless+ws
vless://${UUID}@${DOMAIN_LOWER}:443?encryption=none&security=tls&sni=${DOMAIN_LOWER}&type=xhttp&host=${DOMAIN_LOWER}&path=%2FXkpgx2prIH&mode=auto#vless+xhttps
vless://${UUID}@${DOMAIN_LOWER}:${port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=swift.com&fp=chrome&pbk=MebmQyhcKACwO0jmL7SnV1TXycyxDjgkQ5LkzGEVOhs&sid=f286e42f0a4823f1&type=tcp&headerType=none#Reality
"
echo "${share_link}" > $USER_HOME/catmi/xray.txt
