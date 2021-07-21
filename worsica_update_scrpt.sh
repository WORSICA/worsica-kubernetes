source ./worsica_kubernetes_common.sh

CURRENT_PATH=$HOME/worsica/worsica-kubernetes
echo $CURRENT_PATH
CURRENT_BRANCH=development
echo $CURRENT_BRANCH
WORSICA_COMPONENT=$1
echo $WORSICA_COMPONENT
NO_CACHE_FLAG=$2
echo $NO_CACHE_FLAG

echo '------------------------------------'
cd $CURRENT_PATH
if ([[ -z $WORSICA_COMPONENT ]] || [[ $WORSICA_COMPONENT == 'kubernetes' ]]); then
	echo ' ==========Update worsica-kubernetes  =========='
	echo '1) git pull --------------'
	if (cd $CURRENT_PATH && git pull origin $CURRENT_BRANCH); then
		echo 'git pull success! --------------'
		cd $CURRENT_PATH/deploy
		echo '2) kompose --------------'
		if (kompose convert --controller "deployment" -f ../backend/backend.yml); then
			echo 'kompose success! --------------'
			cd $CURRENT_PATH
		else
			echo 'kompose fail! --------------'
			cd $CURRENT_PATH
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
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
                if (sudo bash -c "$FUNC; build_worsica_essentials $CURRENT_PATH $NO_CACHE_FLAG"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
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
                if (sudo bash -c "$FUNC; build_worsica_frontend $CURRENT_PATH"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
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
                if (sudo bash -c "$FUNC; build_worsica_intermediate $CURRENT_PATH"); then
			echo 'build success! --------------'
			cd $CURRENT_PATH
		else
			echo 'build fail! --------------'
			cd $CURRENT_PATH
		fi
	else
		echo 'git pull fail! --------------'
		cd $CURRENT_PATH
	fi
fi
