#!/bin/bash

PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/keys -d "{ \"key\": \"$PUBLIC_KEY\" }"
