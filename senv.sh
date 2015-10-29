#!/bin/bash

getCurrentEnv () {
 ENVS=( qa dev sandpit )
 for env in "${ENVS[@]}"
 do
   #echo "VALUE:`grep -c "${env}" ${file}`"
   if [[ `grep -c "${env}" ${file}` > 0 ]]
   then
      echo "${env}"
   fi
 done 
}
restartServer () {
   configPath=$1
   nginx -s stop
   echo "Booting Nginx using config ${configPath}"
   nginx -c ${configPath}
}

if [ $# -eq 0 ]
then
  ### 0 Args: All defaults
 targetEnv="dev"
 file="/Users/philippeguay/nginx.conf"
elif [ $# -eq 1 ]
then
 ### 1 Arg: environment
 file="/Users/philippeguay/nginx.conf"
 targetEnv=$1
elif [ $# -eq 2 ]
then
  ### 2 Args: $1: Environment, $2: config path
  targetEnv=$1
  file=$2 
else
  echo "Invalid number of arguments"
fi

currentEnv=$(getCurrentEnv)
if [ ${currentEnv} == ${targetEnv} ]
then
   echo "${targetEnv} is already the current environment."
else
   if [ ! -f "${file}.${targetEnv}" ]
   then
      echo "Changing from [${currentEnv}] to [${targetEnv}] using config: [${file}]"
      sed -i '' "s/${currentEnv}/${targetEnv}/g" ${file}
   else
     echo "Config for ${targetEnv} was found at path ${file}.${targetEnv}"
   fi
fi

echo "Restarting Nginx Proxy server for ENV:${targetEnv}..."
if [ -f "${file}.${targetEnv}" ]
then
   restartServer "${file}.${targetEnv}"
else
   restartServer "${file}"
fi
