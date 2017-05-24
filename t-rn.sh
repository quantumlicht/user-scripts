#!/bin/bash
tmux new-session -d -s rn -c ~/git/remindr
tmux new-window -n main -c ~/git/remindr
tmux new-window -n emulator -d /Users/philippeguay/Library/Android/sdk/tools/emulator -netdelay none -netspeed full -avd Nexus_6_API_23
tmux new-window -n ide -c ~/git/remindr atom . && open -a arduino
echo "SEND KEYS"
tmux send-keys -t main 'react-native run-android' 'C-m'
tmux split-window -t main -h -c ~/git/remindr
tmux send-keys -t main 'react-native log-android' 'C-m'
tmux new-window -n heroku -d heroku logs --app remindr-ws --tail
tmux select-window -t main
tmux -2 attach-session -t rn
