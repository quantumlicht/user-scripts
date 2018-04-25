workon() {
  . ./$1/bin/activate
}

newvenv(){
 python3 -m venv venv && . ./venv/bin/activate
}

initgithooks(){
  cp ~/dev/user-scripts/dot-git/hooks/prepare-commit-msg/prepare-commit-msg ./.git/hooks/prepare-commit-msg
}
alias gdc="git diff --cached"
alias gsh="git show HEAD"
alias gs="git status"
alias gffs="git flow feature start"
alias gffp="git flow feature publish"
alias vim="nvim"
alias gitsync="gco develop && git fetch upstream && git rebase upstream/develop"
alias dkc="docker-compose"
alias docker.cleanall="~/dev/user-scripts/docker-cleanup.sh"
alias docker.killall="~/dev/user-scripts/docker-killall.sh"
alias python.clean="~/dev/user-scripts/python-clean.sh"
zshalias(){
 grep -r 'alias .*=' ~/.oh-my-zsh | awk -F 'alias' '{print $2}'
}
alias myalias='zshalias'
alias k="kubectl"
alias kctxs="kubectl config view contexts"
alias kctx="kubectl config current-context"
alias kctxu="kubectl config use-context"
