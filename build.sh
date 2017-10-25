#! /bin/bash

echo 'Installing bundler...'
sudo gem install bundler

echo 'Installing gems...'
bundle install

echo 'Running migrations...'
rake db:migrate
