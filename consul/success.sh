#!/bin/bash

IFS= read var << EOF
$(input)
EOF


curl -XPOST <slack-hock> --data-urlencode 'payload={"channel": "#alerts", "username": "webhookbot", "text": "Success: '"$input"'"}'
