export PATH="/Users/philippeguay/Downloads/android-sdk-macosx/:$PATH"
export PATH="/usr/local/etc/mongodb/bin:$PATH"
HISTFILESIZE=100000
export NVM_DIR="/Users/philippeguay/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

alias grep='grep --color=auto'
alias ll='ls -lart'

gitclean() {
  echo "erasing pattern: $1*"
  git for-each-ref --format="%(refname:short)" refs/heads/$1* | xargs git branch -D
}
alias cleangit="gitclean"
