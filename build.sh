#!/bin/sh

set -ex

rm --recursive --force ./output_prod
./vendor/bin/sculpin generate --clean --env=prod

rm --recursive --force ./gh-pages-deployment
git clone git@github.com:Slamdunk/slamdunk.github.io.git ./gh-pages-deployment
cd gh-pages-deployment
git checkout master

rsync --quiet --archive --delete ../output_prod/ ./
git add -A :/
git commit -a -m "Deploying sculpin-generated pages to \`master\` branch"
