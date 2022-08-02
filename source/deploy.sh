#!/bin/bash
OUTPUT_FILENAME=mod_scaling_avatar-0-0-2.zip
rm mod_scaling_avatar*.zip
pushd mod_scaling_avatar
7z a $OUTPUT_FILENAME .
rm /c/Program\ Files\ \(x86\)/Steam/steamapps/common/Battle\ Brothers/data/mod_scaling_avatar*.zip
cp ./mod_scaling_avatar-0-0-2.zip /c/Program\ Files\ \(x86\)/Steam/steamapps/common/Battle\ Brothers/data/$OUTPUT_FILENAME
popd
