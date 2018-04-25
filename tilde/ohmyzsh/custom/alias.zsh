workon() {
  . ./$1/bin/activate
}
alias gdc="git diff --cached"
alias gsh="git show HEAD"
alias gs="git status"
alias gffs="git flow feature start"
alias gffp="git flow feature publish"
alias vim="nvim"
alias gitsync="gco develop && git fetch upstream && git rebase upstream/develop"

