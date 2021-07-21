function build_worsica_essentials {
	CURRENT_PATH=$1
	NO_CACHE=$2
	WORSICA_NEXT_VERSION=$3
	cd $CURRENT_PATH
	if [[ -z $NO_CACHE ]] ; then
		echo 'Use cache on the build'
		if docker build -t worsica/worsica-essentials:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/repositories/worsica-cicd/docker_essentials/aio_v4/Dockerfile.essentials . ; then 
			echo 'Building worsica-essentials: Success!'
			cd $CURRENT_PATH
		else
			echo 'Building worsica-essentials: Fail!'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		if [[ $NO_CACHE == '--no-cache' ]]; then
			echo 'Do not use cache on the build, rebuild'
			if docker build --no-cache -t worsica/worsica-essentials:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/repositories/worsica-cicd/docker_essentials/aio_v4/Dockerfile.essentials . ; then
				echo 'Building worsica-essentials: Success!'
				cd $CURRENT_PATH
			else
				echo 'Building worsica-essentials: Fail!'
				cd $CURRENT_PATH
				exit 1
			fi
		else
			echo 'Building worsica-essentials: Fail! Invalid argument '$CURRENT_PATH
			cd $CURRENT_PATH
			exit 1
		fi
	fi
}

function build_worsica_frontend {
	CURRENT_PATH=$1
	WORSICA_NEXT_VERSION=$2
	cd $CURRENT_PATH
	if docker build -t worsica/worsica-frontend:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/repositories/worsica-frontend/docker_frontend/aio_v4/Dockerfile.frontend . ; then
		echo 'Building worsica-frontend: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-frontend: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
	#cd $CURRENT_PATH
	if docker build -t worsica/worsica-kubernetes-frontend:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/worsica_web/docker_frontend/aio_v4/Dockerfile.kubernetes.frontend . ; then
		echo 'Building worsica-kubernetes-frontend: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-kubernetes-frontend: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
}

function build_worsica_intermediate {
	CURRENT_PATH=$1
	WORSICA_NEXT_VERSION=$2
	cd $CURRENT_PATH
	if docker build -t worsica/worsica-intermediate:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/repositories/worsica-intermediate/docker_intermediate/aio_v4/Dockerfile.intermediate . ; then
		echo 'Building worsica-intermediate: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-intermediate: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
	#cd $CURRENT_PATH 
	if docker build -t worsica/worsica-kubernetes-intermediate:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/worsica_web_intermediate/docker_intermediate/aio_v4/Dockerfile.kubernetes.intermediate . ; then
		echo 'Building worsica-kubernetes-intermediate: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-kubernetes-intermediate: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
}

#function build_worsica_processing {
	#CURRENT_PATH = $1
	#cd $CURRENT_PATH 
	#if docker build -t worsica/worsica-processing:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/repositories/worsica-processing/docker_backend/aio_v4/Dockerfile.backend . ; then
	#	echo 'Building worsica-backend: Success!'
	#	cd $CURRENT_PATH
	#else
	#	echo 'Building worsica-backend: Fail!'
	#	cd $CURRENT_PATH
	#	exit 1
	#fi
	#cd $CURRENT_PATH
	#if docker build -t worsica/worsica-kubernetes-processing:$WORSICA_NEXT_VERSION -f $CURRENT_PATH/worsica_web_products/docker_backend/aio_v4/Dockerfile.kubernetes.backend . ; then
	#	echo 'Building worsica-kubernetes-backend: Success!'
	#	cd $CURRENT_PATH
	#else
	#	echo 'Building worsica-kubernetes-backend: Fail!'
	#	cd $CURRENT_PATH
	#	exit 1
	#fi
#}
