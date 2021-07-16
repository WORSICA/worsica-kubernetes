CURRENT_PATH=$HOME/worsica/worsica-kubernetes
#$(pwd)

if [[ $EUID -ne 0 ]] ; then
	echo "Uh-uh, no way! This script must be run as root."
	exit 1
fi

echo '------------------------------------'
echo '1) Building worsica-kubernetes-essentials'
cd $CURRENT_PATH/worsica-cicd/docker_essentials/aio_v4 
if [[ -z $1 ]] ; then
	echo 'Use cache on the build'
	if docker build -t worsica/worsica-kubernetes-essentials:development -f Dockerfile.kubernetes.essentials . ; then 
		echo 'Building worsica-kubernetes-essentials: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-kubernetes-essentials: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
else
	if [[ $1 == '--no-cache' ]]; then
		echo 'Do not use cache on the build, rebuild'
		if docker build --no-cache -t worsica/worsica-kubernetes-essentials:development -f Dockerfile.kubernetes.essentials . ; then
			echo 'Building worsica-kubernetes-essentials: Success!'
			cd $CURRENT_PATH
		else
			echo 'Building worsica-kubernetes-essentials: Fail!'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'Building worsica-kubernetes-essentials: Fail! Invalid argument '$1
		cd $CURRENT_PATH
		exit 1
	fi
fi


echo '------------------------------------'
echo '2) Building worsica-kubernetes-frontend'
cd $CURRENT_PATH/worsica_web/docker_frontend/aio_v4 
if docker build -t worsica/worsica-kubernetes-frontend:development -f Dockerfile.kubernetes.frontend . ; then
	echo 'Building worsica-kubernetes-frontend: Success!'
	cd $CURRENT_PATH
else
	echo 'Building worsica-kubernetes-frontend: Fail!'
	cd $CURRENT_PATH
	exit 1
fi

echo '------------------------------------'
echo '3) Building worsica-kubernetes-intermediate'
cd worsica_web_intermediate/docker_intermediate/aio_v4 
if docker build -t worsica/worsica-kubernetes-intermediate:development -f Dockerfile.kubernetes.intermediate . ; then
	echo 'Building worsica-kubernetes-intermediate: Success!'
	cd $CURRENT_PATH
else
	echo 'Building worsica-kubernetes-intermediate: Fail!'
	cd $CURRENT_PATH
	exit 1
fi

echo '------------------------------------'
echo '4) Building worsica-kubernetes-processing'
cd $CURRENT_PATH/worsica_web_products/docker_backend/aio_v4 
if docker build -t worsica/worsica-kubernetes-processing:development -f Dockerfile.kubernetes.backend . ; then
	echo 'Building worsica-kubernetes-backend: Success!'
	cd $CURRENT_PATH
else
	echo 'Building worsica-kubernetes-backend: Fail!'
	cd $CURRENT_PATH
	exit 1
fi

echo '------------------------------------'
echo '5) do docker copy'
echo '5.1) worsica-frontend'
if docker cp $HOME/worsica/worsica-frontend worsica/worsica-kubernetes-frontend:development:/usr/local/worsica_web ; then
	echo 'Copying worsica-frontend to docker frontend: Success!'
	cd $CURRENT_PATH
else
	echo 'Copying worsica-frontend to docker frontend: Fail!'
	cd $CURRENT_PATH
	exit 1
fi
echo '5.2) worsica-intermediate'
if docker cp $HOME/worsica/worsica-intermediate worsica/worsica-kubernetes-intermediate:development:/usr/local/worsica_web_intermediate ; then
	echo 'Copying worsica-intermediate to docker intermediate: Success!'
	cd $CURRENT_PATH
else
	echo 'Copying worsica-intermediate to docker intermediate: Fail!'
	cd $CURRENT_PATH
	exit 1
fi
echo '5.3) worsica-processing'
if docker cp $HOME/worsica/worsica-processing worsica/worsica-kubernetes-intermediate:development:/usr/local/worsica_web_products ; then
	echo 'Copying worsica-processing to docker intermediate: Success!'
	cd $CURRENT_PATH
else
	echo 'Copying worsica-processing to docker intermediate: Fail!'
	cd $CURRENT_PATH
	exit 1
fi

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

echo 'Finished!'

