function build_worsica_essentials {
	CURRENT_PATH=$1
	#WORSICA_NEXT_VERSION=$2
	NO_CACHE=$2	
	cd $CURRENT_PATH
	if [[ -z $NO_CACHE ]] ; then
		echo 'Use cache on the build'
		if docker build -t worsica/worsica-essentials:development -f $CURRENT_PATH/repositories/worsica-cicd/docker_essentials/aio_v4/Dockerfile.essentials . ; then 
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
			if docker build --no-cache -t worsica/worsica-essentials:development -f $CURRENT_PATH/repositories/worsica-cicd/docker_essentials/aio_v4/Dockerfile.essentials . ; then
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
	if docker build -t worsica/worsica-frontend:development -f $CURRENT_PATH/repositories/worsica-frontend/docker_frontend/aio_v4/Dockerfile.frontend . ; then
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
	if docker build -t worsica/worsica-intermediate:development -f $CURRENT_PATH/repositories/worsica-intermediate/docker_intermediate/aio_v4/Dockerfile.intermediate . ; then
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

function build_worsica_processing {
	CURRENT_PATH=$1
	WORSICA_NEXT_VERSION=$2
	cd $CURRENT_PATH 
	if docker build -t worsica/worsica-processing:development -f $CURRENT_PATH/repositories/worsica-processing/docker_backend/aio_v4/Dockerfile.backend . ; then
		echo 'Building worsica-backend: Success!'
		cd $CURRENT_PATH
	else
		echo 'Building worsica-backend: Fail!'
		cd $CURRENT_PATH
		exit 1
	fi
	#echo 'Saving image to tar'
	TAR_FILE=worsica-processing-dev.tar
	NEXTCLOUD_PATH="https://worsica-nextcloud.a.incd.pt/remote.php/dav/files/worsicaAdmin"
	if docker save -o $CURRENT_PATH/$TAR_FILE worsica/worsica-processing:development ; then
		echo 'Saved image, upload to Nextcloud'
	    	echo "Uploading $CURRENT_PATH/$TAR_FILE to $NEXTCLOUD_PATH/$TAR_FILE";
		CURL_STATUS=$(curl --max-time 600 -u worsicaAdmin:worsica2020 -T $CURRENT_PATH/$TAR_FILE $NEXTCLOUD_PATH/$TAR_FILE -w '<http_code>%{http_code}</http_code>' | grep -oP '(?<=<http_code>).*?(?=</http_code>)')
		echo $CURL_STATUS
		if [[ $CURL_STATUS -eq 201 ]] || [[ $CURL_STATUS -eq 204 ]]; then
			echo "[SUCCESS] Uploaded to nextcloud $CURRENT_PATH/$TAR_FILE to $NEXTCLOUD_PATH/$TAR_FILE"
			rm $CURRENT_PATH/$TAR_FILE
		else
			echo "[FAILURE] Fail upload to nextcloud $CURRENT_PATH/$TAR_FILE to $NEXTCLOUD_PATH/$TAR_FILE"
			exit 1
		fi
	else
		echo 'Saving image: Fail!'
		cd $CURRENT_PATH
		exit 1

	fi
}
