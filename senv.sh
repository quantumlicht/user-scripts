#!/bin/bash
###
# User script to ease the process of changing environment settings
# When working with a local development proxy setup
# Also takes care of checking out the appropriate branch if you have a feature branch for that
###

repoPath="$HOME/git"
techopsFolderName="demo-ops-console"
TARGET_ENV="dev"
CONFIG_PATH="$HOME/nginx.conf"
DEFAULT_BRANCH="master"
ENVS=( qa dev sandpit )
### HELPER METHODS
getCurrentEnv () {
 for env in "${ENVS[@]}"
 do
   #echo "VALUE:`grep -c "${env}" ${CONFIG_PATH}`"
   if [[ `grep -c "${env}" ${CONFIG_PATH}` > 0 ]]
   then
      echo "${env}"
   fi
 done 
}

restartServer () {
   configPath=$1
   sudo nginx -s stop
   echo "Booting Nginx using config ${configPath}"
   sudo nginx -c ${configPath}
}

#### OPTION PARSING
while [[ $# > 1 ]]
do
key="$1"
case $key in
  -c|--conf|--config)
  CONFIG_PATH="$2"
  shift
  ;;
  -b|--branch)
  BRANCH="$2"
  shift
  ;;
  -e|--env)
   TARGET_ENV="$2"
   shift 
  ;;
esac
done

####
echo "-----ENVIRONMENT SWITCH---"
currentEnv=$(getCurrentEnv)
if [ ${currentEnv} == ${TARGET_ENV} ]
then
   echo "${TARGET_ENV} is already the current environment."
else
   if [ ! -f "${CONFIG_PATH}.${TARGET_ENV}" ]
   then
      echo "Changing from [${currentEnv}] to [${TARGET_ENV}] using config: [${CONFIG_PATH}]"
      sed -i '' "s/${currentEnv}/${TARGET_ENV}/g" ${CONFIG_PATH}
   else
     echo "Config for ${TARGET_ENV} was found at path ${CONFIG_PATH}.${TARGET_ENV}"
   fi
fi

###
echo "------BRANCH CHECKOUT----"
checkoutPath="${repoPath}/${techopsFolderName}"
cd ${checkoutPath}
git rev-parse --verify ${BRANCH}
if [ $? == 0 ] && [ -z "$BRANCH" ]
then
   echo "Branch ${BRANCH} was found."
else
   git rev-parse --verify ${TARGET_ENV}
   if [ $? == 0 ]
   then
     echo "An environment specific branch was found. Will use ${TARGET_ENV} branch"
     BRANCH=${TARGET_ENV}
   else
     echo "No branch specified or unknown branch ${BRANCH}.  Will use ${DEFAULT_BRANCH}"
     BRANCH=${DEFAULT_BRANCH}
   fi
fi
echo "Checking out ${BRANCH} at path ${checkoutPath}"
git checkout ${BRANCH}

###
echo "------SERVER RESTART-----"
echo "Restarting Nginx Proxy server for ENV:${TARGET_ENV}..."
if [ -f "${CONFIG_PATH}.${TARGET_ENV}" ]
then
   restartServer "${CONFIG_PATH}.${TARGET_ENV}"
else
   restartServer "${CONFIG_PATH}"
fi

###
echo "-----CLIENT SERVER RESTART-----"
emberProc=$(pgrep 'ember')
echo "Ember Proc [${emberProc}]"
if [ "${emberProc}" != "" ]
then
  echo "Killing Ember process ${emberProc}"
  kill -9 ${emberProc}
fi
echo "Restarting Ember server"
cd "${repoPath}/${techopsFolderName}"
ember s &

