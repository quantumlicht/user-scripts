#!/usr/bin/env bash
echo "Copying '$HOME/user-scripts/senv.sh' to '/usr/local/bin/senv'"
chmod 777 $HOME/user-scripts/senv.sh
chown root $HOME/user-scripts/senv.sh
sudo cp $HOME/user-scripts/senv.sh /usr/local/bin/senv

echo "Copying '$HOME/user-scripts/config.sh' to '/usr/local/bin/senv'"
chmod 777 $HOME/user-scripts/config.sh
chown root $HOME/user-scripts/config.sh
sudo cp $HOME/user-scripts/config.sh /usr/local/bin/config

echo "Moving '$HOME/user-scripts/config.sh' to $HOME/config.sh"
sudo cp $HOME/user-scripts/config.sh $HOME/config.sh

echo "Copying '$HOME/user-scripts/help.sh' to $HOME/help.sh"
sudo cp $HOME/user-scripts/help.sh $HOME/help.sh

echo "Copying '$HOME/user-scripts/dnet' to /usr/local/bin/dnet"
chmod 777 $HOME/user-scripts/dnet
chown root $HOME/user-scripts/dnet
sudo cp $HOME/user-scripts/dnet /usr/local/bin/dnet


echo "Copying $HOME/user-scripts/nginx.conf.dev.template to '$HOME/nginx.conf.dev.template'"
sudo cp $HOME/user-scripts/nginx.conf.dev.template $HOME/nginx.conf.dev.template

echo "Copying $HOME/user-scripts/nginx.conf.sandpit.template -> '$HOME/nginx.conf.sandpit.template'"
sudo cp $HOME/user-scripts/nginx.conf.sandpit.template $HOME/nginx.conf.sandpit.template

echo "Copying $HOME/user-scripts/.gitconfig -> $HOME/.gitconfig"
sudo cp $HOME/user-scripts/.gitconfig $HOME/.gitconfig

echo "Copying $HOME/user-scripts/.gitconfig -> $HOME/.gitconfig"
sudo cp $HOME/user-scripts/.gitconfig $HOME/.gitconfig

echo "Copying $HOME/user-scripts/.bash_profile-> $HOME/.bash_profile"
sudo cp $HOME/user-scripts/.bash_profile $HOME/.bash_profile

echo "Sourcing bash_profile"
source ~/.bash_profile

echo "Copying $HOME/user-scripts/.vim -> $HOME/.vim"
sudo cp -R $HOME/user-scripts/.vim $HOME/.vim

echo "Copying $HOME/user-scripts/.vimrc -> $HOME/.vimrc"
sudo cp $HOME/user-scripts/.vimrc $HOME/.vimrc

echo "Copying Preferences.sublime-settings ->$HOME/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"
sudo cp $HOME/user-scripts/Preferences.sublime-settings $HOME/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

echo "changing root access timeout in /etc/sudoers"
echo "use the visudo command and enter the following Defaults:philippeguay timestamp_timeout=-1"

#echo "installing brew deps"
#sudo cat brew_deps.txt | xargs brew install
