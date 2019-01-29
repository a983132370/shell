#!/bin/bash
# 此处配置master服务器与ip 
 host_names=('master')
 host_ips=('192.168.78.130')

 net=`ls /sys/class/net |grep -E 'eth0|ens3'`
 echo '网卡名称 ' $net $?
 ip=`ifconfig $net |grep broadcast |awk '{print $2}'`
 echo '本机ip '$ip $?
 host_names[1]=`cat /etc/hostname`
 host_ips[1]=$ip
 echo '节点'${host_names[1]}'安装中。。。'	 
 yum -y install flannel docker kubernetes >>/dev/null	 
 echo '节点'${host_names[1]}'安装结果 '$?	 
 echo '节点'${host_names[1]}'正在配置。。。'	 
 echo 'flannel 配置中。。。'	 
 mv /etc/sysconfig/flanneld /etc/sysconfig/flanneld.bak
 wget -O /etc/sysconfig/flanneld https://raw.githubusercontent.com/a983132370/shell/master/flanneld
 sed -i "s/#master/${host_names[0]}/g;s/#slave/${host_names[1]}/g" /etc/sysconfig/flanneld	 
 echo 'flannel 配置完成' $?	 
 echo 'kubelet 正在配置'	 
 mv /etc/kubernetes/kubelet /etc/kubernetes/kubelet.bak
 wget -O /etc/kubernetes/kubelet https://raw.githubusercontent.com/a983132370/shell/master/kubelet
 sed -i "s/#master/${host_names[0]}/g;s/#slave/${host_names[1]}/g" /etc/kubernetes/kubelet	 
 echo 'kubelet 配置完成' $?	 
 echo 'kubeconfig 正在配置'	 
 mv /etc/kubernetes/config /etc/kubernetes/config.bak
 wget -O /etc/kubernetes/config https://raw.githubusercontent.com/a983132370/shell/master/config
 sed -i "s/#master/${host_names[0]}/g;s/#slave/${host_names[1]}/g" /etc/kubernetes/config	 
 echo 'kubeconfig 配置完成' $?	 
 echo '节点'${host_names[1]}'服务启动'
 for SERVICES in kube-proxy kubelet flanneld; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES 
 done
 echo '节点'${host_names[1]}'服务启动完成'