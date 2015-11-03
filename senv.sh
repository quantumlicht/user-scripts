#!/bin/bash
###
# User script to ease the process of changing environment settings

# Also takes care of checking out the appropriate branch if you have a feature branch for that
###

### HELPER METHODS

initScript () {
  cd $HOME
  if [ ! -f "$HOME/config.sh" ]
  then
    echo "Config file config.sh not found"
    exit 0
  else
    echo "loading config config.sh"
    source config.sh
  fi
}

generateConfigFromTemplate () {
  # We validate that a template file is present
  echo "${CONFIG_PATH}.${TARGET_ENV}"
  if [ ! -f "${CONFIG_PATH}.${TARGET_ENV}" ] || [ ! -f "${CONFIG_PATH}.${TARGET_ENV}.template" ]
  then
    echo "Environment Specific file not found. If you want to have custom hosts you should specify a template config for your environment"
    exit 0
  else
    echo "Found host replacement. Will update template config at ${CONFIG_PATH}.${TARGET_ENV}.template"
    # Cleaning up existing temp file
    if [ -f "${CONFIG_PATH}.${TARGET_ENV}.tmp" ]
    then
      echo "removing tmp file ${CONFIG_PATH}.${TARGET_ENV}.tmp"
      rm "${CONFIG_PATH}.${TARGET_ENV}.tmp"
    fi

    # Generating temp work file
    cp "${CONFIG_PATH}.${TARGET_ENV}.template" "${CONFIG_PATH}.${TARGET_ENV}.tmp"

    # Replacing hosts
    replaceHosts

    # Replacing current file by this work file

  fi

}

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

runAsUser () {
  echo "Exec '$1' as ${USER}"
  su ${USER} -c "cd ${CHECKOUT_PATH}; $1"
}

checkoutBranch () {
  branch=$1
  echo "Checking out ${branch}"
  runAsUser "git checkout ${branch}"
}

getCurrentBranch () {
  runAsUser "git branch | sed -n '/\* /s///p'"
}

replaceHosts () {
  #TODO: Escape hostsname from config

  # Check if its the local flag has been set for this host. Override TARGET_ENV to LOCAL if yes
  # WIll also need to uppercase TARGET_ENVS
  upperEnv=`echo "${TARGET_ENV}" | awk '{print toupper($0)}'`
  for hostname in "${SERVICES[@]}"
  do
    localhost="LOCAL_$hostname"
    localhost_host="LOCAL_${hostname}_HOST"
    env_host="${upperEnv}_${hostname}_HOST"
    if [ "${!localhost}" == "true" ]
    then
      echo "Replacing %${hostname}_HOST% with ${!localhost_host} ${CONFIG_PATH}.${TARGET_ENV}.tmp"
      sed -i '' "s/\%${hostname}_HOST\%/${!localhost_host}/g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
    else
      echo "Replacing %${hostname}_HOST% with ${!env_host} in ${CONFIG_PATH}.${TARGET_ENV}.tmp"
      sed -i '' "s/\%${hostname}_HOST\%/${!env_host}/g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
    fi
  done
  echo "Copying ${CONFIG_PATH}.${TARGET_ENV}.tmp to ${CONFIG_PATH}.${TARGET_ENV}"
  cp "${CONFIG_PATH}.${TARGET_ENV}.tmp" "${CONFIG_PATH}.${TARGET_ENV}"
}


# REPO_PATH="$HOME/git"
# TECHOPS_FOLDER="demo-ops-console"
# TARGET_ENV="dev"
# CONFIG_PATH="$HOME/nginx.conf"
# HOST_FILE="$HOME/hosts.conf"
# DEFAULT_BRANCH="master"
# ENVS=( qa dev sandpit )
# BRANCH=
# initialBranch=$(getCurrentBranch)
# CHECKOUT_PATH="${REPO_PATH}/${TECHOPS_FOLDER}"
# USER="philippeguay"

#### OPTION PARSING
echo "---INIT----"
initScript

while [[ $# > 0 ]]
do
key="$1"
case $key in
  -h|--help)
    echo "[-h --help] Help  [-c --conf --config] Nginx Config path [-b --branch] Branch to checkout [-e --env] target environment"
    exit
  ;;
  -c|--conf|--config)
    CONFIG_PATH="$2"
    shift
  ;;
  --host)
    HOST_PATH="$2"
    shift
  ;;
  -b|--branch)
    BRANCH="$2"
    shift
  ;;
  -e|--env)
    echo "TARGET_ENV $2"
    TARGET_ENV="$2"
    shift
  ;;
  -s|--same-br)
    SAME_BRANCH="true"
    shift
  ;;
  --create-br)
    CREATE_BRANCH="true"
    shift
  ;;
  -r)
    RESTART_CLIENT="true"
    shift
  ;;
  --central)
    LOCAL_CENTRAL="true"
    shift
  ;;
  --library)
    LOCAL_LIBRARY="true"
    shift
  ;;
  --scheduler)
    LOCAL_SCHEDULER="true"
    shift
  ;;
  --datasource)
    LOCAL_DATASOURCE="true"
    shift
  ;;
  --reporter)
    LOCAL_REPORTER="true"
    shift
  ;;
  --layout)
    LOCAL_LAYOUTENGINE="true"
    shift
  ;;
  --agent)
    AGENT_HOST="true"
    shift
  ;;
  *)
    shift
  ;;
esac
done

echo "-----ENVIRONMENT SWITCH---"
currentEnv=$(getCurrentEnv)
generateConfigFromTemplate
####
# if [ "${LOCAL_SCHEDULER}" == "true" ] || [ "${LOCAL_CENTRAL}" == "true" ] || [ "${LOCAL_DATASOURCE}" == "true" ] || [ "${LIBRARY_HOST}" == "true" ]
# then
#   if [ ! -f "${CONFIG_PATH}.${TARGET_ENV}" ] || [ ! -f "${CONFIG_PATH}.${TARGET_ENV}.template" ]
#   then
#     echo "Environment Specific file not found. If you want to have custom hosts you should specify a template config for your environment"
#     exit 0
#   else
#     generateConfigFromTemplate
#   fi
# fi


cd ${CHECKOUT_PATH}
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
# cd ${CHECKOUT_PATH}
runAsUser "git show-ref --verify --quiet refs/heads/${BRANCH}"

if [ "${SAME_BRANCH}" != "true" ]
then
  if [ $? == 0 ] && [ "$BRANCH" != "" ]
  then
    echo "Branch ${BRANCH} was found."
    checkoutBranch ${BRANCH}
  else
    runAsUser "git show-ref --verify --quiet refs/heads/${TARGET_ENV}"
    if [ $? == 0 ]
    then
      echo "An environment specific branch was found. Will use ${TARGET_ENV} branch"
      checkoutBranch ${TARGET_ENV}
    else
      if [ "${CREATE_BRANCH}" == "true" ]
      then
        echo "creating new branch ${BRANCH}"
        runAsUser "git branch ${BRANCH}"
        checkoutBranch ${BRANCH}
      else
        echo "No branch specified or unknown branch ${BRANCH}.  Will use ${DEFAULT_BRANCH}"
        checkoutBranch ${DEFAULT_BRANCH}
      fi
    fi
  fi
else
  echo "Using current branch [$(getCurrentBranch)]"
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
echo "${initialBranch} ${currentBranch}"
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
  runAsUser "npm install && bower install"
  echo "Restarting Ember server"
  runAsUser "cd ${REPO_PATH}/${TECHOPS_FOLDER}"
  runAsUser "ember s &"
else
  echo "No branch change occured (init: ${initialBranch}, current: ${currentBranch}). No need to restart client server"
fi
