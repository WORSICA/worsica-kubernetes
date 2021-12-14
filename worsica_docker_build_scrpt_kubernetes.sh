source ./worsica_kubernetes_common.sh

if [[ $EUID -ne 0 ]] ; then
	echo "Uh-uh, no way! This script must be run as root."
	exit 1
fi

CURRENT_PATH=$HOME/worsica/worsica-kubernetes
echo $CURRENT_PATH
NO_CACHE_FLAG=$1
echo $NO_CACHE_FLAG
if [[ -z $(echo $(cat WORSICA_VERSION)) ]]; then
	echo 'ERROR: No WORSICA_VERSION file set. Create this file and set version number (0.9.0)'
	exit 1
fi
WORSICA_VERSION=$(echo $(cat WORSICA_VERSION))
echo "Actual version: ${WORSICA_VERSION}"
WORSICA_NEXT_VERSION=$(echo ${WORSICA_VERSION} | awk -F. -v OFS=. '{$NF++;print}')
echo "Next version: ${WORSICA_NEXT_VERSION}"

echo '------------------------------------'
echo '1) Building worsica-essentials' 
#$1 is --no-cache argument (if set)
build_worsica_essentials $CURRENT_PATH $NO_CACHE_FLAG $WORSICA_NEXT_VERSION

echo '------------------------------------'
echo '2) Building worsica-kubernetes-frontend'
build_worsica_frontend $CURRENT_PATH $WORSICA_NEXT_VERSION

echo '------------------------------------'
echo '3) Building worsica-kubernetes-intermediate'
build_worsica_intermediate $CURRENT_PATH $WORSICA_NEXT_VERSION

#not needed for now
#echo '------------------------------------'
#echo '4) Building worsica-kubernetes-processing'
#build_worsica_frontend $CURRENT_PATH $WORSICA_NEXT_VERSION

#echo '------------------------------------'
#echo '6) Stop worsica-kubernetes-frontend docker and worsica-kubernetes-intermediate docker'
#if docker stop kubernetes-frontend ; then
#	echo 'Stop worsica-kubernetes-frontend docker: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Stop worsica-kubernetes-frontend docker: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi
#if docker stop kubernetes-intermediate ; then
#	echo 'Stop worsica-kubernetes-intermediate docker: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Stop worsica-kubernetes-intermediate docker: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi

#echo '------------------------------------'
#echo '7) Docker instances cleanup and image cleanup'
#if docker rm $(docker ps -a -q) ; then
#	echo 'Docker image cleanup: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Docker image cleanup: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi
#if docker rmi $(docker images -f 'dangling=true' -q) ; then
#	echo 'Docker image cleanup: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Docker image cleanup: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi

#echo '------------------------------------'
#echo '8) Run worsica-kubernetes-intermediate and run worsica-kubernetes-frontend'
#if docker-compose -f backend/backend.yml up -d kubernetes-intermediate ; then
#	echo 'Run worsica-kubernetes-intermediate: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Run worsica-kubernetes-intermediate: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi
#if docker-compose -f backend/backend.yml up -d kubernetes-frontend ; then
#	echo 'Run worsica-kubernetes-frontend: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Run worsica-kubernetes-frontend: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi

#if docker run -d --network worsica --network-alias intermediate --name intermediate -v /home/centos/worsica_web_intermediate:/usr/local/worsica_web_intermediate -v /etc/hosts:/etc/hosts -v /home/centos/worsica_web_products:/usr/local/worsica_web_products -v /dev/log:/dev/log -p 127.0.0.1:8002:8002 --entrypoint '/bin/bash' worsica/worsica-intermediate:development /usr/local/worsica_web_intermediate/worsica_runserver.sh ; then
#	echo 'Run worsica-intermediate: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Run worsica-intermediate: Fail!'
#	cd $CURRENT_PATH
#	exit 1
#fi
#if docker run -d --network worsica --network-alias frontend --name frontend -v /home/centos/worsica_web:/usr/local/worsica_web -v /etc/hosts:/etc/hosts -v /dev/log:/dev/log -p 127.0.0.1:8001:8001 --entrypoint '/bin/bash' worsica/worsica-frontend:development /usr/local/worsica_web/worsica_runserver.sh ; then
#	echo 'Run worsica-frontend: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Run worsica-frontend: Fail!'
#	cd $CURRENT_PATH
#	exit 1
#fi

#WORSICA_VERSION=$WORSICA_NEXT_VERSION
cd $CURRENT_PATH
echo $WORSICA_NEXT_VERSION > WORSICA_VERSION
WORSICA_VERSION=$(echo $(cat WORSICA_VERSION))
echo "Finished! Updated to version: ${WORSICA_VERSION}"

