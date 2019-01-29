#!/bin/bash
# 此处配置主机名与ip 第一个必须是master服务器 运行前配置:wget ssh免密 
 host_names=('master' 'slave1' 'slave2')
 host_ips=('192.168.78.130' '192.168.78.131' '192.168.78.132')

 echo $host_names
 net=`ls /sys/class/net |grep -E 'eth0|ens3'`
 echo '网卡名称 ' $net $?
 ip=`ifconfig $net |grep broadcast |awk '{print $2}'`
 echo '本机ip '$ip $?
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
 for SERVICES  in etcd docker kube-apiserver kube-controller-manager kube-scheduler;  do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES 
 done
 etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'
 echo 'etcd网络配置结果'$?
 echo '服务启动完成'

 index=0
 while (($index<${#host_names[@]})); do
	if (( $index>0 )); then
	 ssh root@${host_names[index]} << eeooff
	 echo '节点'$index'安装中。。。'	 
	 yum -y install flannel docker kubernetes >>/dev/null	 
	 echo '节点'$index'安装结果 '$?	 
	 echo '节点'$index'正在配置。。。'	 
	 echo 'flannel 配置中。。。'	 
	 mv /etc/sysconfig/flanneld /etc/sysconfig/flanneld.bak
	 wget -O /etc/sysconfig/flanneld https://raw.githubusercontent.com/a983132370/shell/master/flanneld
	 sed -i "s/#master/${host_names[0]}/g;s/#slave/${host_names[index]}/g" /etc/sysconfig/flanneld	 
	 echo 'flannel 配置完成' $?	 
	 echo 'kubelet 正在配置'	 
	 mv /etc/kubernetes/kubelet /etc/kubernetes/kubelet.bak
	 wget -O /etc/kubernetes/kubelet https://raw.githubusercontent.com/a983132370/shell/master/kubelet
	 sed -i "s/#master/${host_names[0]}/g;s/#slave/${host_names[index]}/g" /etc/kubernetes/kubelet	 
	 echo 'kubelet 配置完成' $?	 
	 echo 'kubeconfig 正在配置'	 
	 mv /etc/kubernetes/config /etc/kubernetes/config.bak
	 wget -O /etc/kubernetes/config https://raw.githubusercontent.com/a983132370/shell/master/config
	 sed -i "s/#master/${host_names[0]}/g;s/#slave/${host_names[index]}/g" /etc/kubernetes/config	 
	 echo 'kubeconfig 配置完成' $?	 
	 echo '节点'$index'服务启动'
	 systemctl restart kube-proxy
     systemctl enable kube-proxy
     systemctl status kube-proxy

	 systemctl restart docker
     systemctl enable docker
     systemctl status docker

	 systemctl restart kubelet
     systemctl enable kubelet
     systemctl status kubelet

	 systemctl restart flanneld
     systemctl enable flanneld
     systemctl status flanneld
	 echo '节点'$index'服务启动完成'
	 exit
eeooff
	fi;
 	let index+=1
done
 kubectl get nodes