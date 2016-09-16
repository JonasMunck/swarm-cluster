#!/bin/bash

function fv
{
    case "$1" in
    out) echo $VAR
    ;;
    *  ) VAR="$VAR $1"
    ;;
    esac
}

name_list=""
while read name
    do
      if [[ -z $name_list ]]; then
        name_list="$name"
      else
        name_list="$name_list,$name"
      fi
    done

#echo "$name_list" | sed 's/"//g' >> /jonas/output.log

name_list=$(sed "s/['\"]//g" <<< $name_list)
name_list=$(sed "s/,/\n/g" <<< $name_list)

# echo "----- text ------" >> /jonas/output.log
# echo $name_list  >> /jonas/output.log
# echo "----- text ------" >> /jonas/output.log

status='*CRITICAL* :rage:'
if echo "$name_list" | grep "Status:passing"; then
  #echo "----- PASSINg ------" >> /jonas/output.log
  status='*PASSING* :kissing_heart:'
else
  status='*CRITICAL* :rage:'
  #echo "----- FAIL ------" >> /jonas/output.log
fi

passing=$(echo "$name_list" | grep "Status:passing" | wc -l)
warning=$(echo "$name_list" | grep "Status:warning" | wc -l)
critical=$(echo "$name_list" | grep "Status:critical" | wc -l)

echo "----- passing  : $passing ------" >> /jonas/output.log
echo "----- warning  : $warning ------" >> /jonas/output.log
echo "----- critical : $critical ------" >> /jonas/output.log

sum=$((passing + critical))
echo "----- total : $sum ------" >> /jonas/output.log


status='*CRITICAL* :rage:'

if [[ ("$critical" == 0) && ("$warning" == 0) ]]; then
  status='*PASSING* :kissing_heart:'
elif [[ ("$critical" > 0) && ("$passing" > 0)]]; then
  status='*WARNING* :fearful:'
else [[ ("$passing" == 0)]]
  status='*CRITICAL* :rage:'
fi

# if echo "$name_list" | grep "Status:passing"; then
#   #echo "----- PASSINg ------" >> /jonas/output.log
#
# else
#
#   #echo "----- FAIL ------" >> /jonas/output.log
# fi


# text="```\n$name_list\n```"
text="================\n$status\n\n$name_list\n"

# echo "----- text ------" >> /jonas/output.log
echo $text  >> /jonas/output.log
# echo "----- text ------" >> /jonas/output.log


# curl -XPOST <slack-hook> --data-urlencode 'payload={"channel": "#alerts", "username": "webhookbot", "text": "'"$text"'"}'

echo "----- end ------" >> /jonas/output.log
