# 监控并重启IONET脚本
## 1.进入wsl
先获得root权限
然后
<!--sec data-title="OS X и Linux" data-id="OSX_Linux_whoami" data-collapse=true ces-->
```
su
```
在Password:输入root密码
<!--endsec-->
## 2.创建脚本。
创建一个脚本，从网站 https://cloud.io.net/worker/devices 获取你的数据device_id、user_id、device_name，填入下边代码里

<!--sec data-title="OS X и Linux" data-id="OSX_Linux_whoami" data-collapse=true ces-->
```
cat > /root/check_ionet.sh <<EOF 
#!/bin/bash
device_id="Yours device_id"#替换成你的
user_id="Yours user_id"#替换成你的
device_name="Yours device_name"#替换成你的
system=linux #linux or mac
gpu=false #false or true
if [[ "$system" == "linux" ]]; then
    os="Linux"
elif [[ "$system" == "mac" ]]; then
    os="macOS"
if [[ $(docker ps | grep -c "io-worker-monitor") -eq 1 && $(docker ps | grep -c "io-worker-vc") -eq 1 ]]; then
    echo "NODE IS WORKING"
else
    echo "STOP AND DELETE ALL CONTAINERS"
    docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -q) 
    yes | docker system prune -a
    echo "DOWNLOAD FILES FOR $os"
    rm -rf launch_binary_$system && rm -rf ionet_device_cache.txt
    curl -L https://github.com/ionet-official/io_launch_binaries/raw/main/launch_binary_$system -o launch_binary_$system
    chmod +x launch_binary_$system
    echo "START NEW NODE"
    /root/launch_binary_$system --device_id=$device_id --user_id=$user_id --operating_system="$os" --usegpus=$gpu --device_name=$device_name
fi
EOF
```
<!--endsec-->
复制上述代码，把device_id、user_id、device_name替换成你的之后，直接粘贴到命令行。这三个内容，从下图对应位置代码里可以找到。

<img width="793" alt="image" src="https://github.com/hbnnwwt/ionet_restart/assets/116838445/de09a23b-4578-4ebf-a08a-e30c4025caa1">

## 3.修改脚本权限
<!--sec data-title="OS X и Linux" data-id="OSX_Linux_whoami" data-collapse=true ces-->
```
chmod +x /root/check_ionet.sh
```
<!--endsec-->
## 4.可以先运行一下，可以看到脚本正在运行。
<!--sec data-title="OS X и Linux" data-id="OSX_Linux_whoami" data-collapse=true ces-->
```
/root/check.sh
```
<!--endsec-->
<img width="376" alt="image" src="https://github.com/hbnnwwt/ionet_restart/assets/116838445/e3cde7ea-95d9-4e3b-a680-3d8b15ea85d9">

## 5.将脚本加入到定时运行。
<!--sec data-title="OS X и Linux" data-id="OSX_Linux_whoami" data-collapse=true ces-->
```
crontab<<EOF
HOME=/root/
*/5 * * * * check_ionet.sh
EOF
```
<!--endsec-->
