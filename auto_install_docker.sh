 #! /bin/bash
set -ex
echo -e "auto install  docker" 
function  remove_old_version() {
    yum remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-engine
};
function install_driver() {
    yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
};

function add_repo() {
   yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    #modify repo reachable
    sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
    
};
function install_wget(){
    yum install wget -y
}
# fix the bug of container-selinux >= 2.9
function add_container_selinux() {
    install_wget
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo  
    yum install epel-release -y
    yum install container-selinux -y
};
# The default choice is installed the last version of docker
function install_docker() {
   yum makecache fast -y
   yum install docker-ce docker-ce-cli containerd.io -y

};
function rpm_install_container_selinux() {
    wget http://mirrors.atosworldline.com/public/centos/7/extras/x86_64/Packages/container-selinux-2.68-1.el7.noarch.rpm
    rpm -ivh container-selinux-2.68-1.el7.noarch.rpm --nodeps --force

};
function  enable_docker(){
    systemctl  enable  docker
}

function  start_docker(){
    systemctl  start  docker
}
function  modify_docker_daemon(){
    touch  /etc/docker/daemon.json
    cat >> /etc/docker/daemon.json <<EOF  
{
  "registry-mirrors": ["http://f1361db2.m.daocloud.io"],
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  },
  "insecure-registries": [
      "192.168.200.37:10000" #私有仓库地址，根据实际情况配置
  ],
  "storage-driver": "overlay2"
}

EOF
};
# make softlink for docker the dst is /data/docker
function modify_docker_storage_path(){
   systemctl  stop docker
   mv /var/lib/docker  /data/docker
   ln -s /data/docker /var/lib/docker
   systemctl  start docker
};

remove_old_version
install_driver
add_repo
add_container_selinux
if [[ $? -eq 0 ]] ; then   rpm_install_container_selinux ; fi
install_docker
enable_docker
start_docker
modify_docker_daemon
modify_docker_storage_path
