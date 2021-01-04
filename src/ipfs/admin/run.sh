# Copyright [2020] [Frantz Darbon, Gilles Seghaier, Johan Tombre, Frédéric Vaz]

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ==============================================================================


#!/bin/bash

# Initiate private network
# generate swarm file

winpty docker run -it --rm \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    --security-opt "apparmor=unconfined" \
    --env "AWS_S3_BUCKET=heroku-polls-user" \
    --env "AWS_S3_ACCESS_KEY_ID=AKIAWUFYU45RSPJGHIZK" \
    --env "AWS_S3_SECRET_ACCESS_KEY=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" \
    --env UID=$(id -u) \
    --env GID=$(id -g) \
    -v /mnt/tmp:/opt/s3fs/bucket:rshared \
    efrecon/s3fs
	
read -p "Press any key to finish ..."