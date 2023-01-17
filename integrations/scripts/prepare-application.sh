#!/bin/bash
# create simple app
rm -rf ./integrations/app
mkdir ./integrations/app
cd ./integrations
npx --yes ng new app --force --routing --style=scss --skip-git=true --skip-tests=true --minimal=true --interactive=false --force=true --commit=false
cd ../
# install test app
mkdir ./integrations/app/src/app/new-api
cp -Rf ./apps/demo/src/app/panels/new-api/* ./integrations/app/src/app/new-api/
cp -Rf ./integrations/default/* ./integrations/app/src/app/
node ./integrations/scripts/path-angular-files.js
# create a tgz of current dist build
mkdir ./integrations/app/lib
cp -Rf ./dist/libs/ngx-dynamic-form-builder/* ./integrations/app/lib
npx --yes replace-json-property ./integrations/app/lib/package.json version 0.0.0
# force name to ngx-dynamic-form-builder , removes yoolabs prefix & ensures import capability in test env
npx --yes replace-json-property ./integrations/app/lib/package.json name ngx-dynamic-form-builder
cd ./integrations/app/lib
npm pack .
cd ../
# on-the-fly installation of created tgz
npm install --save ./lib/ngx-dynamic-form-builder-0.0.0.tgz --force
npm run build
cd ../../
