#!/bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Base forensication script.
# This is customized by the master remaster script.

# First, check that we have internet
wget -q --spider http://www.google.com
if [[ $? -ne 0 ]]; then
  echo "ERROR: No internet connectivity"
  echo "Please make sure the system is connected to the internet"
  exit 1
fi

source config.sh

# Install pysmdev
wget -q https://github.com/libyal/libsmdev/releases/download/20181227/libsmdev-alpha-20181227.tar.gz
tar -xf libsmdev-alpha-20181227.tar.gz
cd libsmdev-20181227
python setup.py build
sudo python setup.py install
cd ..

# Make sure have the latest version of the auto_forensicate module
git clone https://github.com/someguyiknow/GiftStick
cd GiftStick
sudo python setup.py install

# We need to build a module for this system, this can't be installed before
# booting.
sudo pip install chipsec

# QR renderer
sudo pip install segno

UUID="`wget -qO- ${NO_BAKE_DOMAIN}`"

echo "${NO_BAKE_DOMAIN}/scantag/${UUID}"|segno

GCS_REMOTE_URL="`wget -qO- ${NO_BAKE_DOMAIN}/path/${UUID}`"
while [[ $? -ne 0 ]]; do
  sleep 30
  GCS_REMOTE_URL="`wget -qO- ${NO_BAKE_DOMAIN}/path/${UUID}`"
done

sudo "${AUTO_FORENSIC_SCRIPT_NAME}" \
  --logging stdout \
  --acquire all \
  ${EXTRA_OPTIONS} "${GCS_REMOTE_URL}/"

wget -qO- ${NO_BAKE_DOMAIN}/finish/${UUID}
