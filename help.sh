#!/bin/bash
showHelp() {
  echo ""
  echo "Options:"
  echo ""
  echo "    [-h --help] Help menu (this menu)"
  echo "    [-c --conf --config] Specifies Nginx config path"
  echo "    [-b --branch] Specifies branch to checkout"
  echo "    [-e --env] Specifices target environment"
  echo "    [-s --same-br] Use current branch"
  echo "    [--new] Create branch if non existant"
  echo "    [-r --restart] Force restart of the client server"
  echo "    [--srvc] Use local Central service"
  echo "    [--srvlib] Use local Library service"
  echo "    [--srvs] Use local Scheduler service"
  echo "    [--srvd] Use local Datasource service"
  echo "    [--srvr] Use local Reporter service"
  echo "    [--srvl] Use local Layout Engine service"
  echo "    [--srva] Use local Agent service"
  echo "    [--srvo] Use local Oauth service"
  echo "    [--srvcrm] Use local CRM service"
  echo ""
  exit 0
}