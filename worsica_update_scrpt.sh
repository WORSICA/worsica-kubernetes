source ./worsica_kubernetes_common.sh

CURRENT_PATH=$HOME/worsica/worsica-kubernetes
echo $CURRENT_PATH
CURRENT_BRANCH=development
echo $CURRENT_BRANCH
WORSICA_COMPONENT=$1
echo $WORSICA_COMPONENT
NO_CACHE_FLAG=$2
echo $NO_CACHE_FLAG
#if [[ -z $(echo $(cat $CURRENT_PATH/WORSICA_VERSION)) ]]; then
#	echo 'ERROR: No WORSICA_VERSION file set. Create this file and set version number (0.9.0)'
#	exit 1
#fi
#WORSICA_VERSION=$(cat $CURRENT_PATH/WORSICA_VERSION)
#echo "Actual version: ${WORSICA_VERSION}"
#WORSICA_NEXT_VERSION=$(echo ${WORSICA_VERSION} | awk -F. -v OFS=. '{$NF++;print}')
#echo "Next version: ${WORSICA_NEXT_VERSION}"

echo '------------------------------------'
cd $CURRENT_PATH
#make sure secrets are loaded
echo "=====check for secret worsica-cert-robot-key ====="
if (sudo kubectl get secrets -n worsica | grep -q worsica-cert-robot-key) ; then 
	echo "worsica-cert-robot-key exists, proceed!"
else 
	echo "worsica-cert-robot-key does not exist, create!"
	if sudo kubectl create secret tls worsica-cert-robot-key --key worsica_lnec_certs_robot.key --cert worsica_lnec_certs_robot.pem ; then
		echo 'update worsica_grid_launch_submission.sh'
		sed -i "s/worsica_lnec_certs_robot.pem/tls.crt/g" $CURRENT_PATH/repositories/worsica-processing/worsica_grid_launch_submission.sh
		sed -i "s/worsica_lnec_certs_robot.key/tls.key/g" $CURRENT_PATH/repositories/worsica-processing/worsica_grid_launch_submission.sh
	else
		echo "failed to add secret"
		exit 1
	fi
	#update worsica_grid_launch_submission.sh
fi
#
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'essentials' ]]); then
	echo ' ==========Update worsica-essentials  =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH/repositories/worsica-cicd && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH
		echo '2) build with no-cache --------------'
		FUNC=$(declare -f build_worsica_essentials) #force sudo
                if (sudo bash -c "$FUNC; build_worsica_essentials $CURRENT_PATH $NO_CACHE_FLAG"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH		
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
		exit 1
	fi
fi
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'frontend' ]]); then
	echo ' ==========Update worsica-frontend =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH/repositories/worsica-frontend && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH
		if [[ -z $(echo $(cat $CURRENT_PATH/repositories/worsica-frontend/WORSICA_VERSION)) ]]; then
			echo 'ERROR: No WORSICA_VERSION file set. Create this file and set version number (0.9.0)'
			exit 1
		fi
		WORSICA_FRONTEND_VERSION=$(cat $CURRENT_PATH/repositories/worsica-frontend/WORSICA_VERSION)
		echo "Actual version: ${WORSICA_FRONTEND_VERSION}"
		WORSICA_FRONTEND_NEXT_VERSION=$(echo ${WORSICA_FRONTEND_VERSION}-$(date +%s))
		echo "Next version: ${WORSICA_FRONTEND_NEXT_VERSION}"
		echo '2) build --------------'
		FUNC=$(declare -f build_worsica_frontend) #force sudo
                if (sudo bash -c "$FUNC; build_worsica_frontend $CURRENT_PATH $WORSICA_FRONTEND_NEXT_VERSION"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH			
			echo 'deploying, please wait...'
			if (sudo docker save worsica/worsica-kubernetes-frontend:$WORSICA_FRONTEND_NEXT_VERSION | ssh vnode-1 "sudo docker load"); then
				echo 'deployment success! --------------'
				cd $CURRENT_PATH
			else
				echo 'deployment fail! --------------'
				cd $CURRENT_PATH
				exit 1
			fi	
			#echo 'remove old images'
			#if (ssh vnode-1 "sudo docker images -q worsica/worsica-kubernetes-frontend:* | xargs sudo docker rmi -f || true"); then
			#	echo 'removed with success! --------------'
			#	cd $CURRENT_PATH
			#else
			#	echo 'remove fail! --------------'
			#	cd $CURRENT_PATH
			#	exit 1
			#fi	
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
		exit 1
	fi
fi
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'processing' ]]); then
	echo ' ==========Update worsica-processing =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH/repositories/worsica-processing && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH
		if [[ -z $(echo $(cat $CURRENT_PATH/repositories/worsica-processing/WORSICA_VERSION)) ]]; then
			echo 'ERROR: No WORSICA_VERSION file set. Create this file and set version number (0.9.0)'
			exit 1
		fi
		WORSICA_PROCESSING_VERSION=$(cat $CURRENT_PATH/repositories/worsica-processing/WORSICA_VERSION)
		echo "Actual version: ${WORSICA_PROCESSING_VERSION}"
		WORSICA_PROCESSING_NEXT_VERSION=$(echo ${WORSICA_PROCESSING_VERSION}-$(date +%s))
		echo "Next version: ${WORSICA_PROCESSING_NEXT_VERSION}"
		echo '2) build --------------'
		FUNC=$(declare -f build_worsica_processing) #force sudo
		if (sudo bash -c "$FUNC; build_worsica_processing $CURRENT_PATH $WORSICA_PROCESSING_NEXT_VERSION"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
		exit 1
	fi
fi
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'intermediate' ]]); then
	echo ' ==========Update worsica-intermediate  =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH/repositories/worsica-intermediate && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH
		if [[ -z $(echo $(cat $CURRENT_PATH/repositories/worsica-intermediate/WORSICA_VERSION)) ]]; then
			echo 'ERROR: No WORSICA_VERSION file set. Create this file and set version number (0.9.0)'
			exit 1
		fi
		WORSICA_INTERMEDIATE_VERSION=$(cat $CURRENT_PATH/repositories/worsica-intermediate/WORSICA_VERSION)
		echo "Actual version: ${WORSICA_INTERMEDIATE_VERSION}"
		WORSICA_INTERMEDIATE_NEXT_VERSION=$(echo ${WORSICA_INTERMEDIATE_VERSION}-$(date +%s))
		echo "Next version: ${WORSICA_INTERMEDIATE_NEXT_VERSION}"
		echo '2) build --------------'
		FUNC=$(declare -f build_worsica_intermediate) #force sudo
                if (sudo bash -c "$FUNC; build_worsica_intermediate $CURRENT_PATH $WORSICA_INTERMEDIATE_NEXT_VERSION"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH	
			echo 'deploying, please wait...'
			if (sudo docker save worsica/worsica-kubernetes-intermediate:$WORSICA_INTERMEDIATE_NEXT_VERSION | ssh vnode-2 "sudo docker load"); then
				echo 'deployment success! --------------'
				cd $CURRENT_PATH
			else
				echo 'deployment fail! --------------'
				cd $CURRENT_PATH
				exit 1
			fi	
			#echo 'remove old images'
			#if (ssh vnode-2 "sudo docker images -q worsica/worsica-kubernetes-intermediate:* | xargs sudo docker rmi -f || true"); then
			#	echo 'removed with success! --------------'
			#	cd $CURRENT_PATH
			#else
			#	echo 'remove fail! --------------'
			#	cd $CURRENT_PATH
			#	exit 1
			#fi
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
		exit 1
	fi
fi
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'kubernetes' ]]); then
	echo ' ==========Update worsica-kubernetes  =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH/deploy
		echo '2) kompose --------------'
		export WORSICA_FRONTEND_NEXT_VERSION
		export WORSICA_INTERMEDIATE_NEXT_VERSION
		if (kompose convert --controller "deployment" -f ../backend/backend.yml); then
			echo 'kompose success! --------------'
			cp $CURRENT_PATH/kustomization/* $CURRENT_PATH/deploy
			#change storage size
			echo 'apply changes by patch'
			cd $CURRENT_PATH
			#diff -Naur $CURRENT_PATH/default/ $CURRENT_PATH/deploy/
			patch -i $CURRENT_PATH/kustomization/update_storage_and_node_selection.patch -p1 -d deploy/
			echo 'done'
			cd $CURRENT_PATH
		else
			echo 'kompose fail! --------------'
			cd $CURRENT_PATH
			exit 1
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
		exit 1
	fi
fi
if ([[ -z $WORSICA_COMPONENT ]]); then
	echo 'apply changes'
	sudo kubectl apply -k deploy
	echo 'ok, applied changes'
	echo 'wait...'
	sudo kubectl wait deploy --all --for condition=available -n worsica --timeout=240s
	#echo 'update hosts files'
	sudo kubectl get pods -n worsica -o wide | awk '(NR>1) { sub(/kubernetes-/,"",$1); sub(/-[A-Za-z0-9-]*/,"",$1); print $6 " " $1; }' > $CURRENT_PATH/kustomization/hosts
	#sudo kubectl get services -n worsica -o wide | awk '(NR>1) { sub(/kubernetes-/,"",$1); sub(/-[A-Za-z0-9-]*/,"",$1); print $3 " " $1 }' >> $CURRENT_PATH/kustomization/hosts	
	echo 'cleanup evicted pods'
	for each in $(sudo kubectl get pods -n worsica | grep Evicted | awk '{print $1}'); do
	        sudo kubectl delete pods $each -n worsica
	done
	echo 'cleaned evicted pods'
	for c in $(sudo kubectl get pods -n worsica | awk '(NR>1) { print $1 }'); do 
		echo "$c"
		NETCDF_PATH=bin/FES2014/data/
		if [[ $c == *'intermediate'* ]]; then
			echo "copy /pv/temp/netcdf/$NETCDF_PATH worsica/$c:/usr/local/bin/FES2014/"
			sudo kubectl cp /pv/temp/netcdf/$NETCDF_PATH worsica/$c:/usr/local/bin/FES2014/
			echo "copied /pv/temp/netcdf/$NETCDF_PATH worsica/$c:/usr/local/bin/FES2014/"
		fi
		echo 'add or update the hosts'
		#this is a very dirty hack, copy original hosts to new, edit new with sed, and copy new back to original
		sudo kubectl exec -n worsica --stdin --tty $c -- bash -c "cp /etc/hosts ~/hosts.new && sed -i 's/10.[0-9.]*[[:space:]]*[a-z]*//g' ~/hosts.new && sed -i '/^$/d' ~/hosts.new && cp -f ~/hosts.new /etc/hosts"
		cat ~/worsica/worsica-kubernetes/kustomization/hosts | sudo kubectl exec -i -n worsica $c -- bash -c 'cat >> /etc/hosts'
		echo 'added or updated the hosts'
		if [[ $c == *'frontend'* ]] || [[ $c == *'intermediate'* ]]; then
			echo "apply collect static to $c"
			sudo kubectl exec -n worsica --stdin --tty $c -- bash -c "python3 manage.py collectstatic --noinput"
			echo "applied collect static to $c"
		fi
		echo 'done!'
	done
	
fi

##WORSICA_VERSION=$WORSICA_NEXT_VERSION
cd $CURRENT_PATH
#echo $WORSICA_NEXT_VERSION > WORSICA_VERSION
#WORSICA_VERSION=$(cat $CURRENT_PATH/WORSICA_VERSION)
#echo "Finished! Updated to version: ${WORSICA_VERSION}"
echo "remove worsica-kubernetes-* images from host"
sudo docker images -q worsica/worsica-kubernetes-frontend:* | xargs sudo docker rmi -f
sudo docker images -q worsica/worsica-kubernetes-intermediate:* | xargs sudo docker rmi -f
echo "Finished! Updated all WORSICA components!"
