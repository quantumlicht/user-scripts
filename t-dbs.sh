#bin/bash/
if [ $# -eq 1 ];
then 
	tmux new-session -d -s dbs
	tmux new-window -n postgres -d pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop
	tmux send-keys 'pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start' 'C-m'
	tmux split-window -h  
	tmux send-keys 'sudo mongod' 'C-m'
else
        tmux kill-session -t dbs
fi
