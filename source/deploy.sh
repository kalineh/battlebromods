#!/bin/bash
rm mod_scaling_avatar*.zip
pushd mod_scaling_avatar
7z a mod_scaling_avatar-0-0-2-dev.zip .
rm /c/Program\ Files\ \(x86\)/Steam/steamapps/common/Battle\ Brothers/data/mod_scaling_avatar*.zip
cp ./mod_scaling_avatar.zip /c/Program\ Files\ \(x86\)/Steam/steamapps/common/Battle\ Brothers/data/mod_scaling_avatar-0-0-2-dev.zip
popd
