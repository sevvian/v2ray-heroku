#!/bin/sh

# Download and install V2Ray
mkdir /tmp/v2ray
curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl

# Remove temporary directory
rm -rf /tmp/v2ray

# V2Ray new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
  "log" : {
    "access" : "/usr/local/etc/v2ray/access.log" ,
    "error" : "/usr/local/etc/v2ray/error.log" ,
    "loglevel" : "debug"
  },
  "inbound" : {
    "port": $PORT, 
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id" : "$UUID" ,
          "level" : 0,
          "alterId" : 2,
          "security": "aes-128-gcm"
        }
      ]
    },
    "streamSettings": {
      "network": "tcp",
      "tcpSettings": {
        "header": {
          "type": "http",
          "response": {
            "version": "1.1",
            "status": "200",
            "reason": "OK",
            "headers": {
              "Content-Type": ["application/octet-stream", "application/x-msdownload", "text/html", "application/x-shockwave-flash"],
              "Transfer-Encoding": ["chunked"],
              "Connection": ["keep-alive"],
              "Pragma": "no-cache"
            }
          }
        }
      }
    }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  },
  "outboundDetour": [
    {
      "protocol" : "blackhole" ,
      "settings" : {},
      "tag" : "blocked"
    }
  ],
  "routing": {
    "strategy": "rules",
    "settings": {
      "rules": [
        {
          "type" : "field" ,
          "ip" : [
            "0.0.0.0/8" ,
            "10.0.0.0/8" ,
            "100.64.0.0/10" ,
            "127.0.0.0/8" ,
            "169.254.0.0/16" ,
            "172.16.0.0/12" ,
            "192.0.0.0/24" ,
            "192.0.2.0/24" ,
            "192.168.0.0/16" ,
            "198.18.0.0/15" ,
            "198.51.100.0/24" ,
            "203.0.113.0/24" ,
            "::1/128" ,
            "fc00::/7" ,
            "fe80::/10"
          ],
          "outboundTag" : "blocked"
        }
      ]
    }
  },
"dns": {
    "server": [
      "1.1.1.1",
      "1.0.0.1",
      "8.8.8.8",
      "8.8.4.4",
      "localhost"
    ]
  },
  "transport": {
    "sockopt": {
      "tcpFastOpen": true
    }
  }
}

EOF

# Run V2Ray
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
