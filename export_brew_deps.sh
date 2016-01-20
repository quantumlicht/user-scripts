#!/bin/sh
touch brew_deps.txt
brew list >> brew_deps.txt
brew cask list >> brew_deps.txt