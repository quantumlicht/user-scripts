#!/bin/bash
# User script to ease the process of changing environment settings
# Also takes care of checking out the appropriate branch if you have a feature branch for that

#IMPORTANT
#You need to have a config file named config.sh in your $HOME path
# This file should be based on config.sh.template and populated as needed


#HELPER METHODS
section () {
  echo ""
  echo "========== $1 =========="
  echo ""
}


checkRoot() {
  if [ `id|sed -e s/uid=//g -e s/\(.*//g` -ne 0 ]; then
      echo "This script requires root privileges"
      exit 1
  fi
}

initScript () {
  echo "Creating /var/log/nginx"
  mkdir /var/log/nginx
  cd $HOME
  if [ ! -f "$HOME/config.sh" ]
  then
    echo "Config file config.sh not found"
    exit 0
  else
    echo "loading config config.sh"
    source config.sh
  fi
  if [ ! -f "$HOME/help.sh" ]
  then
    echo "No help file found at $HOME/help.sh"
    exit 0
  else
    source help.sh
  fi
}

generateConfigFromTemplate () {
  # We validate that a template file is present
  if [ ! -f "${CONFIG_PATH}.${TARGET_ENV}.template" ]
  then
    echo $'ENV TPL NOT FOUND -> For custom hosts create: nginx.conf.<env>.template'
    ENV_TEMPLATE=${DEFAULT_ENV_TEMPLATE}
  fi

  echo "ENV TEMPLATE [${ENV_TEMPLATE}]"
  # Cleaning up existing env temp file
  if [ -f "${CONFIG_PATH}.${TARGET_ENV}.tmp" ]
  then
    echo "CLEANUP -> rm ${CONFIG_PATH}.${TARGET_ENV}.tmp"
    rm "${CONFIG_PATH}.${TARGET_ENV}.tmp"
  fi

  #Cleaning tmp default template
  if [ -f "${CONFIG_PATH}.${ENV_TEMPLATE}.tmp" ]
  then
    echo "CLEANUP -> rm ${CONFIG_PATH}.${ENV_TEMPLATE}.tmp"
    rm "${CONFIG_PATH}.${ENV_TEMPLATE}.tmp"
  fi

  # Generating temp work file
  echo "TMP FILE -> ${CONFIG_PATH}.${TARGET_ENV}.tmp"
  cp "${CONFIG_PATH}.${ENV_TEMPLATE}.template" "${CONFIG_PATH}.${TARGET_ENV}.tmp"

  replaceHosts
  if [ $(isValidPort) == "true" ]
  then
    replacePort
  else
    echo "INVALIDPORT [${PORT}]"
    exit 0
  fi

  if [ $(isValidSSL) == "true" ]
  then
    replaceSSL
  else
      echo "INVALID SSL [${SSL_CRT_PATH} ${SSL_KEY_PATH}]"
      exit 0
  fi

  # Replacing current file by this work file
  echo "COPY ${CONFIG_PATH}.${TARGET_ENV}.tmp -> ${CONFIG_PATH}.${TARGET_ENV}"
  cp "${CONFIG_PATH}.${TARGET_ENV}.tmp" "${CONFIG_PATH}.${TARGET_ENV}"

}

isValidSSL () {
 if [[ ! -f "${SSL_CRT_PATH}" ]] || [[ ! -f "${SSL_KEY_PATH}" ]]
 then
   echo "false"
 else
    echo "true"
 fi
# echo "true"
}

isValidPort () {
  re='^[0-9]+$'
  if ! [[ ${PORT} =~ $re ]] || [[ $"num" -gt 65535 ]] || [[ $"num" -lt 0 ]]
  then
   echo "false"
  else
    echo "true"
  fi
}
restartServer () {
  configPath=$1
  sudo nginx -s stop
  echo "BOOT NGINX... CONFIG [${configPath}]"
  sudo nginx -c ${configPath}
}

killServer () {
  echo "KILLING SERVER"
  sudo nginx -s stop
  exit 0
}

runAsUser () {
  echo "RUNAS [${USER}] -> $1"
  su ${USER} -c "cd ${CHECKOUT_PATH}; $1"
}

checkoutBranch () {
  branch=$1
  echo "CHECKOUT [${branch}]"
  runAsUser "git checkout ${branch}"
}

getCurrentBranch () {
  git branch | sed -n '/\* /s///p'
}

replaceHosts () {

  # Check if its the local flag has been set for this host. Override TARGET_ENV to LOCAL if yes
  upperEnv=`echo "${TARGET_ENV}" | awk '{print toupper($0)}'`
  echo "REPLACEHOST FILE [${CONFIG_PATH}.${TARGET_ENV}.tmp]"
  for hostname in "${SERVICES[@]}"
  do
    should_run_local="LOCAL_$hostname"
    localhost_host="LOCAL_${hostname}_HOST"
    env_host="${upperEnv}_${hostname}_HOST"
    if [ "${!should_run_local}" == "true" ]
    # Using commas for delimiters so that we don't have to escape hosts that use slashes
    then
      echo "REPLACEHOST %${hostname}_HOST% --> ${!localhost_host}"
      sed -i '' "s,%${hostname}_HOST%,${!localhost_host},g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
    else
      echo "REPLACEHOST %${hostname}_HOST% --> ${!env_host}"
      sed -i '' "s,%${hostname}_HOST%,${!env_host},g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
    fi
  done

  echo "REPLACEHOST %HOSTNAME% --> ${HOSTNAME}"
  sed -i '' "s,%HOSTNAME%,${HOSTNAME},g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"

}

replacePort () {
  echo "REPLACEPORT %PORT% --> ${PORT}"
  sed -i '' "s,%PORT%,${PORT},g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
}

replaceSSL() {
  echo "REPLACESSL %SSL_KEY_PATH% --> ${SSL_KEY_PATH}"
  echo "REPLACESSL %SSL_CRT_PATH% --> ${SSL_CRT_PATH}"
  sed -i '' "s,%SSL_CRT_PATH%,${SSL_CRT_PATH},g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
  sed -i '' "s,%SSL_KEY_PATH%,${SSL_KEY_PATH},g" "${CONFIG_PATH}.${TARGET_ENV}.tmp"
}


########################################################################################
section "INIT"
checkRoot
initScript
while [[ $# > 0 ]]
do
key="$1"
case $key in
  -h|--help)
    showHelp
  ;;
  -p|--port)
    PORT="$2"
    shift
  ;;
  -c|--conf|--config)
    CONFIG_PATH="$2"
    shift
  ;;
  -k|--kill)
    killServer
    exit 0
  ;;
  -b|--branch)
    BRANCH="$2"
    shift
  ;;
  -e|--env)
    TARGET_ENV="$2"
    ENV_TEMPLATE="$2"
    shift
  ;;
  -s|--same-br)
    SAME_BRANCH="true"
    shift
  ;;
  --new)
    CREATE_BRANCH="true"
    shift
  ;;
  -r|--restart)
    RESTART_CLIENT="true"
    shift
  ;;

  -i|--install-deps)
    INSTALL_DEPS="true"
    shift
  ;;

  --srvc)
    LOCAL_CENTRAL="true"
    shift
  ;;
  --srvlib)
    LOCAL_LIBRARY="true"
    shift
  ;;
  --srvs)
    LOCAL_SCHEDULER="true"
    shift
  ;;
  --srvd)
    LOCAL_DATASOURCE="true"
    shift
  ;;
  --srvr)
    LOCAL_REPORTER="true"
    shift
  ;;
  --srvl)
    LOCAL_LAYOUTENGINE="true"
    shift
  ;;
  --srva)
    AGENT_HOST="true"
    shift
  ;;
  --srvo)
    LOCAL_OAUTH="true"
    shift
  ;;
   --srvcrm)
    LOCAL_CRM="true"
    shift
  ;;
  *)
    shift
  ;;
esac
done

section "ENVIRONMENT SWITCH"
generateConfigFromTemplate
cd ${CHECKOUT_PATH}
initialBranch=$(getCurrentBranch)

########################################################################################
section "BRANCH CHECKOUT"

git show-ref --verify --quiet refs/heads/${BRANCH}
res=$?
if [ "${SAME_BRANCH}" != "true" ]
then
  if [ "${res}" == "0" ]
  then
    checkoutBranch ${BRANCH}
  else
    echo "BRANCH NOT FOUND [${BRANCH}]"
    if [ "${CREATE_BRANCH}" == "true" ]
    then
      echo "creating new branch ${BRANCH}"
      runAsUser "git checkout ${DEFAULT_BRANCH}"
      runAsUser "git pull origin ${DEFAULT_BRANCH}"
      runAsUser "git branch ${BRANCH}"
      checkoutBranch ${BRANCH}
    else
      git show-ref --verify --quiet refs/heads/${TARGET_ENV}
      if [ $? == 0 ]
      then
        echo "An environment specific branch was found. Will use ${TARGET_ENV}"
        checkoutBranch ${TARGET_ENV}
      else
        echo "No branch specified or unknown branch ${BRANCH}. Will use ${DEFAULT_BRANCH}"
        checkoutBranch ${DEFAULT_BRANCH}
      fi
    fi
  fi
else
  echo "SAMEBRANCH Requested. Using [$(getCurrentBranch)]"
fi
########################################################################################
section "NGINX SERVER RESTART [${TARGET_ENV}]"
restartServer "${CONFIG_PATH}.${TARGET_ENV}"

########################################################################################
section "CLIENT SERVER RESTART"
currentBranch=$(getCurrentBranch)
emberPID=$(pgrep 'ember')
if [ "$RESTART_CLIENT" == "true" ] || [ "${initialBranch}" != "${currentBranch}" ]
then
  if [ "${emberPID}" != "" ]
  then
    echo "KILL EMBER PROC [${emberPID}]"
    kill -9 ${emberPID}
  fi
  if [ "$INSTALL_DEPS" == "true" ]
  then
    runAsUser "npm install && bower install"
  fi
  runAsUser "cd ${REPO_PATH}/${TECHOPS_FOLDER}"
  runAsUser "ember s &"
else
  if [ "${emberPID}" == "" ]
  then
    echo "NO EMBER PROCESS -- Launching Ember App Server"
    runAsUser "ember s &"
  else
    echo "NORESTART -- BRANCHES (init: ${initialBranch}, current: ${currentBranch})"
    echo "EMBER PID [${emberPID}]"
  fi
fi
