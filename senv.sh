#!/bin/bash
###
# User script to ease the process of changing environment settings

# Also takes care of checking out the appropriate branch if you have a feature branch for that
###

### HELPER METHODS
getCurrentEnv () {
  #TODO: Interrogate current running Nginx Process to know if we are running an environment specific config. That will tell us the currentEnv more accurately.
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

checkoutBranch () {
  branch=$1
  echo "Checking out ${branch}"
  git checkout ${branch}
}

getCurrentBranch () {
  git branch | sed -n '/\* /s///p'
}

REPO_PATH="$HOME/git"
TECHOPS_FOLDER="demo-ops-console"
TARGET_ENV="dev"
CONFIG_PATH="$HOME/nginx.conf"
DEFAULT_BRANCH="master"
ENVS=( qa dev sandpit )
BRANCH=
initialBranch=$(getCurrentBranch)


#### OPTION PARSING
while [[ $# > 1 ]]
do
key="$1"
case $key in
  -h|--help)
    echo "[-h --help] Help  [-c --conf --config] Nginx Config path [-b --branch] Branch to checkout [-e --env] target environment"
    shift
  ;;
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
  -f)
    CREATE_BRANCH="true"
    shift
  ;;
  -r)
    RESTART_CLIENT="true"
    shift
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
checkoutPath="${REPO_PATH}/${TECHOPS_FOLDER}"
cd ${checkoutPath}
git show-ref --verify --quiet refs/heads/${BRANCH}
if [ $? == 0 ] && [ "$BRANCH" != "" ]
then
  echo "Branch ${BRANCH} was found."
else
  git show-ref --verify --quiet refs/heads/${TARGET_ENV}
  if [ $? == 0 ]
  then
    echo "An environment specific branch was found. Will use ${TARGET_ENV} branch"
    checkoutBranch ${TARGET_ENV}
  else
    if [ "${CREATE_BRANCH}" == "true" ]
    then
      echo "creating new branch ${BRANCH}"
      git branch ${BRANCH}
      checkoutBranch ${BRANCH}
    else
      echo "No branch specified or unknown branch ${BRANCH}.  Will use ${DEFAULT_BRANCH}"
      checkoutBranch ${DEFAULT_BRANCH}
    fi
  fi
fi

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
currentBranch=$(getCurrentBranch)
if [ "$RESTART_CLIENT" == "true" ] || [ "${initialBranch}" != "${currentBranch}" ]
then
  emberProc=$(pgrep 'ember')
  echo "Ember Proc [${emberProc}]"
  if [ "${emberProc}" != "" ]
  then
    echo "Killing Ember process ${emberProc}"
    kill -9 ${emberProc}
  fi
  echo "Installing dependencies (npm + bower)"
  npm install && bower install
  echo "Restarting Ember server"
  cd "${REPO_PATH}/${TECHOPS_FOLDER}"
  ember s &
else
  echo "No branch change occured (init: ${initialBranch}, current: ${currentBranch}). No need to restart client server"
fi
