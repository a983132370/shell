#!/bin/bash

 net=`ls /sys/class/net |grep -E 'eth0|ens3'`
 echo '网卡名称 ' $net $?
 ip=`ifconfig $net |grep broadcast |awk '{print $2}'`
 echo '本机ip '$ip $?
 host_names=()
 host_ips=()
 host_names[0]=`cat /etc/hostname`
 host_ips[0]=$ip
 echo '安装中。。。'
 yum -y install etcd docker kubernetes >>/dev/null
 echo '安装结果 '$?
 echo '主机正在配置。。。'
 echo 'etcd 配置中。。。'
 mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak
 wget -O /etc/etcd/etcd.conf https://raw.githubusercontent.com/a983132370/shell/master/etcd.conf
 c=`echo 's/#master/'$master'/g'`
 sed -i "s/#master/${host_names[0]}/g" /etc/etcd/etcd.conf
 echo 'etcd 配置完成' $?
 echo 'apiserver 正在配置'
 mv /etc/kubernetes/apiserver /etc/kubernetes/apiserver.bak
 wget -O /etc/kubernetes/apiserver https://raw.githubusercontent.com/a983132370/shell/master/apiserver
 sed -i "s/#master/${host_names[0]}/g" /etc/kubernetes/apiserver
 echo 'apiserver 配置完成' $?
 echo 'kubeconfig 正在配置'
 mv /etc/kubernetes/config /etc/kubernetes/config.bak
 wget -O /etc/kubernetes/config https://raw.githubusercontent.com/a983132370/shell/master/config
 sed -i "s/#master/${host_names[0]}/g" /etc/kubernetes/config 
 echo 'kubeconfig 配置完成' $?
 echo '服务启动'
 for SERVICES  in etcd kube-apiserver kube-controller-manager kube-scheduler;  do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES 
 done
 etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'
 echo 'etcd网络配置结果'$?
 echo '服务启动完成'
 kubectl get nodes