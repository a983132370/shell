# shell

k8s搭建脚本,仅适用于学习,严禁在正式环境使用,若造成损失请自行承担.

环境:
  centos 7.x
  ifconfig 
  wget
  各主机名id写入hosts
  防火墙已关闭并禁用,也可单独开放端口：2379 8080 10250
  主服务器对节点免密登录

参考命令:
  设置主机名
  hostnamectl set-hostname 你的主机名
  关闭并禁用防火墙
  systemctl stop firewalld
  systemctl disable firewalld
  开启netstat 和 ifconfig命令
  yum -y install net-tools
  安装后查看节点信息(master节点)
  kubectl get nodes  
