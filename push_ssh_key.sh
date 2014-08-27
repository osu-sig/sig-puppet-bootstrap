#!/bin/bash

PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

: ${GITHUB_TOKEN:?"Environment variable GITHUB_TOKEN must be present."}

response=$(curl -w \\n%{http_code} --silent -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/keys -d "{ \"key\": \"$PUBLIC_KEY\" }")
statuscode=$(grep -Po '\s(\d+)$' <<< $response | sed 's/\s//')
message=$(grep -Po '"message":.*?[^\\]",' <<< $response)

if [[ $statuscode -ne '201' ]]
then
  echo "status code: $statuscode $message"
  exit 1
else
  exit 0
fi
