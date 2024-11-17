[Chinese](README.zh_cn.md)

# KDNS

## Introduction

KDNS is a high-performance DNS Server based on DPDK. Do not rely on the database, the user updates the data through the RESTful API.


## How to use

### 1. Compilation

Required  OS release: Ubuntu 22.04
Kernel version >= 4.14
glibc >= 2.7  (check with ldd --version)
DPDK version:- 22.11.6
GCC version:- 4.9+

1) Upgrade pkg-config while version < 0.28

```bash

wget https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
tar xzvf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2
./configure --with-internal-glib
make
make install
mv /usr/bin/pkg-config /usr/bin/pkg-config.bak
ln -s /usr/local/bin/pkg-config /usr/bin/pkg-config

```

2) Install Required packages


```bash

apt install update
apt install libtool libtool-bin libpcap-dev texinfo libnuma-dev
apt install kernel-headers-$(uname -r) kernel-devel-$(uname -r)

```

3) Clone the repo and set PKG_CONFIG_PATH environment variable and allocate hugepages.

```bash

git clone https://github.com/modi2207/kdns.git
cd kdns
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig
mkdir -p /mnt/huge
mount -t hugetlbfs nodev /mnt/huge

```

4) Make all for the first time, after that make kdns if you just change the DNS code.

```bash
make all
```

### 2. Startup

The default configuration path for KDNS is /etc/kdns/kdns.cfg. An example for kdns.cfg as follows :

EAL configuration reference [DPDK document](http://dpdk.org/doc/guides/testpmd_app_ug/run_app.html#eal-command-line-options).

```bash
[EAL]
cores = 0
memory = 1024
mem-channels = 4
 
[NETDEV]
; 默认KNI网口名称
name-prefix = kdns
mode = rss
mbuf-num = 65535
kni-mbuf-num = 8191
rxqueue-len = 1024
txqueue-len = 2048
    
rxqueue-num = 1
txqueue-num = 1

; KNI网口IP地址
kni-ipv4 = 2.2.2.240
; BGP 发布的VIP
kni-vip = 127.0.0.1

[COMMON]
log-file = /export/log/kdns/kdns.log

fwd-def-addrs = 114.114.114.114:53,8.8.8.8:53
; 转发线程数
fwd-thread-num = 4
; 转发模式
fwd-mode = cache
; 转发请求超时时间
fwd-timeout = 2
; 转发请求mbuf数
fwd-mbuf-num = 65535

; 每IP全部报文限速
all-per-second = 1000
; 每IP DNS转发请求限速
fwd-per-second = 10
; 限速客户端数, 设置为0, 则关闭限速功能
client-num = 10240

web-port = 5500
ssl-enable = no
cert-pem-file = /etc/kdns/server1.pem
key-pem-file = /etc/kdns/server1-key.pem
zones = tst.local,example.com,168.192.in-addr.arpa
```



Start kdns:

```bash
sh start.sh
```

## API 

### 1. Add domain datas

```bash
curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"type":"A","zoneName":"example.com","domainName":"chen.example.com","host":"192.168.2.2"}'  'http://127.0.0.1:5500/kdns/domain' 

curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"type":"CNAME","zoneName":"example.com","domainName":"chen.cname.example.com","host":"chen.example.com"}' 'http://127.0.0.1:5500/kdns/domain' 

curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"type":"SRV","zoneName":"example.com","domainName":"_srvtcp._tcp.example.com","host":"chen.example.com","priority":20,"weight":50,"port":8800}'  'http://127.0.0.1:5500/kdns/domain'
```

### 2. query domain datas

```bash
curl -H "Content-Type:application/json;charset=UTF-8" -X GET   'http://127.0.0.1:5500/kdns/perdomain/chen.example.com' 
curl -H "Content-Type:application/json;charset=UTF-8" -X GET   'http://127.0.0.1:5500/kdns/domain' 
```

### 3. statistics api

```bash
curl -H "Content-Type:application/json;charset=UTF-8" -X GET   'http://127.0.0.1:5500/kdns/statistics/get'
```

### 4. add view

```bash
 curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"cidrs":"192.168.0.0/24","viewName":"gz"}'  'http://127.0.0.1:5500/kdns/view' 
```

### 5. add lb info

```bash
 curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"type":"A","zoneName":"example.com","domainName":"chen.example.com","lbMode":1,"host":"1.1.1.1"}'  'http://127.0.0.1:5500/kdns/domain' 
 curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"type":"A","zoneName":"example.com","domainName":"chen.example.com","lbMode":1,"host":"2.2.2.2"}'  'http://127.0.0.1:5500/kdns/domain' 
 curl -H "Content-Type:application/json;charset=UTF-8" -X POST -d '{"type":"A","zoneName":"example.com","domainName":"chen.example.com","lbMode":1,"host":"3.3.3.3"}'  'http://127.0.0.1:5500/kdns/domain' 
```

## Performance

CPU model: Intel(R) Xeon(R) CPU E5-2698 v4 @ 2.20GHz

NIC model: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection

Jmeter version: apache-jmeter-3.1

Test sample:  single domain --- kubernetes.default.svc.skydns.local(10.0.0.1)
              50,000 domains --- random domain name with suffix skydns.local. Among them, 30,000  with one IP, 10,000 with two IPs, and 10,000 with 3-10 IPs (random).


performance data:

![performance](images/dns-performance.png "performance")
