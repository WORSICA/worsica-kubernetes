CURRENT_PATH=/home/centos

if [[ $EUID -ne 0 ]] ; then
	echo "Uh-uh, no way! This script must be run as root."
	exit 1
fi

echo '------------------------------------'
echo '1) Building worsica-essentials'
cd $CURRENT_PATH/worsica-cicd/docker_essentials/aio_v4 
if [[ -z $1 ]] ; then
	echo 'Use cache on the build'
	if docker build -t worsica/worsica-essentials:development -f Dockerfile.kubernetes.essentials . ; then 
		echo 'Building worsica-essentials: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-essentials: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
else
	if [[ $1 == '--no-cache' ]]; then
		echo 'Do not use cache on the build, rebuild'
		if docker build --no-cache -t worsica/worsica-essentials:development -f Dockerfile.kubernetes.essentials . ; then
			echo 'Building worsica-essentials: Success!'
			cd $CURRENT_PATH
		else
			echo 'Building worsica-essentials: Fail!'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'Building worsica-essentials: Fail! Invalid argument '$1
		cd $CURRENT_PATH
		exit 1
	fi
fi


echo '------------------------------------'
echo '2) Building worsica-frontend'
cd $CURRENT_PATH/worsica_web/docker_frontend/aio_v4 
if docker build -t worsica/worsica-frontend:development -f Dockerfile.kubernetes.frontend . ; then
	echo 'Building worsica-frontend: Success!'
	cd $CURRENT_PATH
else
	echo 'Building worsica-frontend: Fail!'
	cd $CURRENT_PATH
	exit 1
fi

echo '------------------------------------'
echo '3) Building worsica-intermediate'
cd worsica_web_intermediate/docker_intermediate/aio_v4 
if docker build -t worsica/worsica-intermediate:development -f Dockerfile.kubernetes.intermediate . ; then
	echo 'Building worsica-intermediate: Success!'
	cd $CURRENT_PATH
else
	echo 'Building worsica-intermediate: Fail!'
	cd $CURRENT_PATH
	exit 1
fi

echo '------------------------------------'
echo '4) Building worsica-processing'
cd $CURRENT_PATH/worsica_web_products/docker_backend/aio_v4 
if docker build -t worsica/worsica-processing:development -f Dockerfile.kubernetes.backend . ; then
	echo 'Building worsica-backend: Success!'
	cd $CURRENT_PATH
else
	echo 'Building worsica-backend: Fail!'
	cd $CURRENT_PATH
	exit 1
fi


echo '------------------------------------'
echo '6) Stop worsica-frontend docker and worsica-intermediate docker'
#if docker-compose -f backend/backend.yml down ; then
#	echo 'Stop worsica-frontend docker: Success!'
#	cd $CURRENT_PATH
#else
#	echo 'Stop worsica-frontend docker: Fail!'
#	cd $CURRENT_PATH
#	#exit 1
#fi
if docker stop frontend ; then
	echo 'Stop worsica-frontend docker: Success!'
	cd $CURRENT_PATH
else
	echo 'Stop worsica-frontend docker: Fail!'
	cd $CURRENT_PATH
	#exit 1
fi
if docker stop intermediate ; then
	echo 'Stop worsica-intermediate docker: Success!'
	cd $CURRENT_PATH
else
	echo 'Stop worsica-intermediate docker: Fail!'
	cd $CURRENT_PATH
	#exit 1
fi

echo '------------------------------------'
echo '7) Docker instances cleanup and image cleanup'
if docker rm $(docker ps -a -q) ; then
	echo 'Docker image cleanup: Success!'
	cd $CURRENT_PATH
else
	echo 'Docker image cleanup: Fail!'
	cd $CURRENT_PATH
	#exit 1
fi
if docker rmi $(docker images -f 'dangling=true' -q) ; then
	echo 'Docker image cleanup: Success!'
	cd $CURRENT_PATH
else
	echo 'Docker image cleanup: Fail!'
	cd $CURRENT_PATH
	#exit 1
fi

echo '------------------------------------'
echo '8) Run worsica-intermediate and run worsica-frontend'
if docker-compose -f backend/backend.yml up -d intermediate ; then
	echo 'Run worsica-intermediate: Success!'
	cd $CURRENT_PATH
else
	echo 'Run worsica-intermediate: Fail!'
	cd $CURRENT_PATH
	#exit 1
fi
if docker-compose -f backend/backend.yml up -d frontend ; then
	echo 'Run worsica-frontend: Success!'
	cd $CURRENT_PATH
else
	echo 'Run worsica-frontend: Fail!'
	cd $CURRENT_PATH
	#exit 1
fi

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

