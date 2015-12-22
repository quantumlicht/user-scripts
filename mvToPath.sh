echo "Copying '$HOME/user-scripts/senv.sh' to '/usr/bin/senv/'"
sudo cp $HOME/user-scripts/senv.sh /usr/bin/senv

echo "Copying '$HOME/user-scripts/config.sh' to '/usr/bin/senv/'"
sudo cp $HOME/user-scripts/config.sh /usr/bin/senv

# echo "Moving '$HOME/user-scripts/config.sh' to $HOME/config.sh"
# sudo cp $HOME/user-scripts/config.sh $HOME/config.sh

echo "Copying '$HOME/user-scripts/help.sh' to $HOME/help.sh"
sudo cp $HOME/user-scripts/help.sh $HOME/help.sh

echo "Copying $HOME/user-scripts/nginx.conf.dev.template to '$HOME/nginx.conf.dev.template'"
sudo cp $HOME/user-scripts/nginx.conf.dev.template $HOME/nginx.conf.dev.template

echo "Copying $HOME/user-scripts/nginx.conf.sandpit.template -> '$HOME/nginx.conf.sandpit.template'"
sudo cp $HOME/user-scripts/nginx.conf.sandpit.template $HOME/nginx.conf.sandpit.template