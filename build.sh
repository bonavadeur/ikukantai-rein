#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
NC="\e[0m"

REDBGR='\033[0;41m'
NCBGR='\033[0m'

########## CONFIG ##########
OPTION=$1
############################

logSuccess() { echo -e "$GREEN-----$1-----$NC";}
logInfo() { echo -e "$BLUE-----$1-----$NC";}
logError() { echo -e "$RED-----$1-----$NC";}
logStage() { echo -e "$YELLOW###############---$1---###############$NC";}

dockerBuild() {
    logStage "Docker build image"
    docker build --quiet -t bonavadeur/rein:dev .
}

convertImage() {
    logStage "change image from docker to crictl"
    image=$(docker images | grep bonavadeur | grep rein | grep dev | awk '{print $1}'):dev
    docker save -o rein.tar docker.io/bonavadeur/rein:dev
    logInfo "Saved atarashi-imeji to .tar file"
    sudo crictl rmi docker.io/bonavadeur/rein:dev
    sudo ctr -n=k8s.io images import rein.tar
    logInfo "Untar atarashi-imeji"
    rm -rf rein.tar
}

deployNewVersion() {
    logStage "remove current Pod"
    pods=($(kubectl -n default get pod | grep "rein" | awk '{print $1}'))
    for pod in ${pods[@]}
    do
        kubectl -n default delete pod/$pod &
    done
}

logPod() {
    sleep 1
    pods=($(kubectl -n default get pod | grep "rein" | grep Running | awk '{print $1}'))
    while [ "${pods[0]}" == "" ];
    do
        sleep 1
        pods=($(kubectl -n default get pod | grep "rein" | grep Running | awk '{print $1}'))
    done
    echo "pod:"${pods[0]}
    kubectl -n default wait --for=condition=ready pod ${pods[0]} > /dev/null 2>&1
    clear
    endTime=`date +%s`
    echo Build time was `expr $endTime - $startTime` seconds.
    logStage "Kn-Rein logs"
    echo "pod:"${pods[0]}
    kubectl -n default logs ${pods[0]} -f
}
#
#
#
#
#
#
#
#
#
#
clear
echo -e "$REDBGR このスクリプトはボナちゃんによって書かれています $NCBGR"

startTime=`date +%s`
if [ $OPTION == "build" ]; then
    dockerBuild
elif [ $OPTION == "dep" ]; then
    convertImage
    deployNewVersion
    logPod
elif [ $OPTION == "log" ]; then
    deployNewVersion
    logPod
elif [ $OPTION == "ful" ]; then
    dockerBuild
    if [ $? -eq "0" ]; then
        convertImage
        deployNewVersion
        logPod
    else
        exit 1
    fi
elif [ $OPTION == "debug" ]; then
    koBuild
    convertImage
fi
