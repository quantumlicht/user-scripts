#!/bin/bash
REPO_PATH="$HOME/git"
TECHOPS_FOLDER="demo-ops-console"
TARGET_ENV="dev"
CONFIG_PATH="$HOME/nginx.conf"
DEFAULT_BRANCH="master"
ENVS=( qa dev sandpit )
BRANCH=
NGINX_LOGS="$HOME/nginx.log"

CHECKOUT_PATH="${REPO_PATH}/${TECHOPS_FOLDER}"
USER="philippeguay"
SERVICES=( SCHEDULER DATASOURCE CENTRAL REPORTER LIBRARY AGENT LAYOUTENGINE OAUTH )

#SCHEDULER
DEV_SCHEDULER_HOST="ops-schedule.videri.com"
SANDPIT_SCHEDULER_HOST="https://ops-sandpit.videri.com/scheduler/"
QA_SCHEDULER_HOST="qa-schedule.videri.com"
LOCAL_SCHEDULER_HOST="http://localhost:3000/v1/"

#DATASOURCE
DEV_DATASOURCE_HOST="ops-dev.videri.com/datasource"
SANDPIT_DATASOURCE_HOST="https://ops-sandpit.videri.com/datasource"
QA_DATASOURCE_HOST="ops-qa.videri.com/datasource"
LOCAL_DATASOURCE_HOST="https://ops.localhost.videri.com:9292/v1"

#CENTRAL
DEV_CENTRAL_HOST="ops-dev.videri.com/central"
SANDPIT_CENTRAL_HOST="https://ops-sandpit.videri.com/central/"
QA_CENTRAL_HOST="ops-qa.videri.com/central"
LOCAL_CENTRAL_HOST="http://localhost:9292/v1/"

#REPORTER
DEV_REPORTER_HOST="reporter-dev.videri.com"
SANDPIT_REPORTER_HOST="https://ops-sandpit.videri.com/reporter"
QA_REPORTER_HOST="ops-qa.videri.com/reporter"
LOCAL_REPORTER_HOST="https://ops-sandpit.videri.com/reporter"

#LIBRARY
DEV_LIBRARY_HOST="ops-dev.videri.com/library"
SANDPIT_LIBRARY_HOST="https://ops-sandpit.videri.com/library"
QA_LIBRARY_HOST="ops-qa.videri.com/library"
LOCAL_LIBRARY_HOST="http://ops.localhosrt.videri.com:3000/v1"

#AGENT
DEV_AGENT_HOST="agent-dev.videri.com"
SANDPIT_AGENT_HOST="https://ops-sandpit.videri.com/agent"
QA_AGENT_HOST="ops-qa.videri.com/agent"
LOCAL_AGENT_HOST="http://ops.localhost.videri.com:3000/v1"

#LAYOUTENGINE
DEV_LAYOUTENGINE_HOST="layout-dev.videri.com"
SANDPIT_LAYOUTENGINE_HOST="https://ops-sandpit.videri.com/layoutengine"
QA_LAYOUTENGINE_HOST="ops-qa.videri.com/layoutengine"
LOCAL_LAYOUTENGINE_HOST="http://ops.localhost.videri.com:3000/v1"

#OAUTH
DEV_OAUTH_HOST="layout-dev.videri.com"
SANDPIT_OAUTH_HOST="https://ops-sandpit.videri.com/oauth/"
QA_OAUTH_HOST="ops-qa.videri.com/oauth"
LOCAL_OAUTH_HOST="http://localhost:9292/oauth/"
