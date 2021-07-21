source ./worsica_kubernetes_common.sh

CURRENT_PATH=$HOME/worsica/worsica-kubernetes
echo $CURRENT_PATH
CURRENT_BRANCH=development
echo $CURRENT_BRANCH
WORSICA_COMPONENT=$1
echo $WORSICA_COMPONENT
NO_CACHE_FLAG=$2
echo $NO_CACHE_FLAG
if [[ -z $WORSICA_VERSION ]]; then
	echo 'ERROR: Please set or export WORSICA_VERSION variable (e.g WORSICA_VERSION=0.9.0)'
	exit 1
fi
echo "Actual version: ${WORSICA_VERSION}"
WORSICA_NEXT_VERSION=$(echo ${WORSICA_VERSION} | awk -F. -v OFS=. '{$NF++;print}')
echo "Next version: ${WORSICA_NEXT_VERSION}"

echo '------------------------------------'
cd $CURRENT_PATH
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'kubernetes' ]]); then
	echo ' ==========Update worsica-kubernetes  =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH #/deploy
		#echo '2) kompose --------------'
		#if (kompose convert --controller "deployment" -f ../backend/backend.yml); then
		#	echo 'kompose success! --------------'
		#	cp $CURRENT_PATH/kustomization/* $CURRENT_PATH/deploy
		#	cd $CURRENT_PATH
		#else
		#	echo 'kompose fail! --------------'
		#	cd $CURRENT_PATH
		#	exit 1
		#fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
		exit 1
	fi
fi
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'essentials' ]]); then
	echo ' ==========Update worsica-essentials  =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH/repositories/worsica-cicd && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH
		echo '2) build with no-cache --------------'
		FUNC=$(declare -f build_worsica_essentials) #force sudo
                if (sudo bash -c "$FUNC; build_worsica_essentials $CURRENT_PATH $NO_CACHE_FLAG $WORSICA_NEXT_VERSION"); then
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
		echo '2) build --------------'
		FUNC=$(declare -f build_worsica_frontend) #force sudo
                if (sudo bash -c "$FUNC; build_worsica_frontend $CURRENT_PATH $WORSICA_NEXT_VERSION"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH
			if (sudo docker save worsica/worsica-kubernetes-frontend:development | ssh vnode-1 "sudo docker load"); then
				echo 'deployment success! --------------'
				cd $CURRENT_PATH
			else
				echo 'deployment fail! --------------'
				cd $CURRENT_PATH
				exit 1
			fi	
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
		echo '2) build --------------'
		FUNC=$(declare -f build_worsica_intermediate) #force sudo
                if (sudo bash -c "$FUNC; build_worsica_intermediate $CURRENT_PATH $WORSICA_NEXT_VERSION"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH
			if (sudo docker save worsica/worsica-kubernetes-intermediate:development | ssh vnode-2 "sudo docker load"); then
				echo 'deployment success! --------------'
				cd $CURRENT_PATH
			else
				echo 'deployment fail! --------------'
				cd $CURRENT_PATH
				exit 1
			fi	
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

WORSICA_VERSION=$WORSICA_NEXT_VERSION
echo "Finished! Updated to version: ${WORSICA_NEXT_VERSION}"
