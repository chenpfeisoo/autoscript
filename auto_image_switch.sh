#! /bin/bash
# The ami of this script is  changing pubilc image to privte harbor's
#example :kubesphere/ks-apiserver:advanced-2.0.2
set -ex
input_info=$1
image_name=`echo $input_info | awk -F ':' '{ print $1  }'  | awk  -F '/' '{ print $NF  }'` 
image_tag=`echo $input_info | awk -F ':' '{ print $2  }'` 
harbor_registry='172.168.200.50/cfss'
function  docker_pull(){
   docker pull $input_info
}
function  docker_tag(){
   docker tag  $input_info   ${harbor_registry}/${image_name}:${image_tag}
}
function docker_push(){
   docker push ${harbor_registry}/${image_name}:${image_tag}
}
function docker_rmi(){
    #delete the pubilc image
   docker rmi $input_info
}

docker_pull
docker_tag
docker_push
docker_rmi
if [[ $? -eq 0 ]] ;then echo "changing pubilc image to privte harbor's is done!"; fi
