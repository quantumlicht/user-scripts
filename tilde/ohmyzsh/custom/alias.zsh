workon() {
  . ./$1/bin/activate
}

newvenv(){
 python3 -m venv venv && . ./venv/bin/activate
}

notify(){
 say command done
}

initgithooks(){
  cp ~/dev/user-scripts/dot-git/hooks/prepare-commit-msg/prepare-commit-msg ./.git/hooks/prepare-commit-msg
}

# Expects to have findutils brew package installed
run_per_users(){
   gfind /mnt/projects/eai-nlp/models-ckpt/eaiwb -type d -printf '%d\t%P\t%u\n' | egrep '^2' | cut -f3- | awk '{user[$0] += 1 } END { for (i in user) { printf "%s:%s\n",i, user[i]; }}'
}
# Expects to have findutils brew package installed
total_runs(){
   gfind /mnt/projects/eai-nlp/models-ckpt/eaiwb -type d -printf '%d\t%P\t%u\n' | egrep '^2' | wc -l
}

gitclean() {
   echo "erasing pattern: $1*"
   git for-each-ref --format="%(refname:short)" refs/heads/$1* | xargs git branch -D
}

# Git Aliases
alias gdc="git diff --cached"
alias gb="git branch --sort=-committerdate"
alias gsh="git show HEAD"
alias gs="git status"
alias gffs="git flow feature start"
alias gffp="git flow feature publish"
alias vim="nvim"
alias gitsync="gco develop && git fetch upstream && git rebase upstream/develop"
alias g.large="show_git_large_files"

# Docker Aliases
alias dkc="docker-compose"
alias docker.cleanall="~/dev/user-scripts/docker-cleanup.sh"
alias docker.prune="docker system prune --all --volumes"
alias docker.killall="~/dev/user-scripts/docker-killall.sh"
alias docker.rmall="~/dev/user-scripts/docker-remove-all.sh"

# Python Aliases
alias python.clean="~/dev/user-scripts/python-clean.sh"


# Kubernetes Aliases
alias k="kubectl"
alias h="helm"
alias k.deletetests="kubectl delete pods -l category=system-tests"
alias k.viewcontexts="kubectl config view contexts"
alias k.showcontext="kubectl config current-context"
alias k.watchpods="kubectl get pods --watch"
alias k.gp="kubectl get pods --show-labels"
alias k.gs="kubectl get services --show-labels"
alias k.usecontext="kubectl_use_context"
alias k.tests="kubectl get pods -l category=system-tests"

# System Aliases
alias mountprojects="sshfs -o allow_other,defer_permissions,reconnect wks1:/mnt/projects/ /mnt/projects"
alias mountdatasets="sshfs -o allow_other,defer_permissions,reconnect wks1:/mnt/datasets/ /mnt/datasets"
alias mounthome="sshfs -o defer_permissions,reconnect wks1:/mnt/home/ /mnt/home"
alias cdservices="cd /mnt/projects/eai-nlp/services"
alias cdckpt="cd /mnt/projects/eai-nlp/models-ckpt"
alias myalias='vim $ZSH_CUSTOM/alias.zsh'

zshalias(){
 grep -r 'alias .*=' ~/.oh-my-zsh | awk -F 'alias' '{print $2}'
}

kubectl_use_context(){
   kubectl config use-context $1
   export HELM_HOST=`kubectl get svc tiller-deploy -o=jsonpath='{.spec.clusterIP}:{.spec.ports[?(@.name=="tiller")].port}'`
}

setup_artifactory(){
        if [[ "$1" == "release" ]]; then
           export ARTIFACTORY_USERNAME="$ARTIFACTORY_RELEASE_USERNAME"
           export ARTIFACTORY_USER="$ARTIFACTORY_RELEASE_USERNAME"
           export ARTIFACTORY_TOKEN="$ARTIFACTORY_RELEASE_API_KEY"
           export ARTIFACTORY_API_KEY="$ARTIFACTORY_RELEASE_API_KEY"
        elif [[ "$1" == "scratch" ]]; then
           export ARTIFACTORY_USERNAME="$ARTIFACTORY_SCRATCH_USERNAME"
           export ARTIFACTORY_USER="$ARTIFACTORY_SCRATCH_USERNAME"
           export ARTIFACTORY_TOKEN="$ARTIFACTORY_SCRATCH_API_KEY"
           export ARTIFACTORY_API_KEY="$ARTIFACTORY_SCRATCH_API_KEY"
        else 
           echo "should be release or scratch"
        fi
}

show_git_large_files(){
   # From https://stackoverflow.com/a/42544963/1818327
   git rev-list --objects --all \
   | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
   | sed -n 's/^blob //p' \
   | sort --numeric-sort --key=2 \
   | cut -c 1-12,41- \
   | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest \
   | awk '$2 >= 2^20'
}

cAdvisor(){
# https://github.com/google/cadvisor
        docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest
  echo "cAdvisor runnin on localhost:8080"
}

