#!/bin/bash

# Requirement: homebrew

# Install unison
brew install unison

# Workaround for the missing unison-fsmonitor on MacOS
sudo pip install macfsevents
curl https://raw.githubusercontent.com/hnsl/unox/master/src/unox/unox.py | sudo tee /usr/local/bin/unison-fsmonitor >/dev/null
sudo chmod +x /usr/local/bin/unison-fsmonitor