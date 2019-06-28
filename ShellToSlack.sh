#!/bin/bash

#
# Tufora.com
# https://github.com/tufora/ShellToSlack.sh.git
# 

ServerName=$HOSTNAME

function help {
    ShellToSlack=$0
    echo -e ""
    echo -e "SCRIPT DETAILS"
    echo -e "Use script to post messages to a specific Slack channel\n"
    echo -e "SCRIPT USAGE"
    echo -e "$ShellToSlack [-a \"Application title\"] [-t \"Message title\"] [-m \"Message body\"] [-s \"Message severity\"] [-c \"#Channel-name\"] [-w \"Slack webhook URL\"]\n"
    echo -e "    -a    Slack application title"
    echo -e "          Example: -a \"MySQL Alerts\"\n"
    echo -e "    -t    Message title"
    echo -e "          Example: -t \"MySQL Replication Status\"\n"
    echo -e "    -m    Message body"
    echo -e "          Example: -m \"MySQL replication failed\"\n"
    echo -e "    -s    Message severity level (info|good|warning|danger)"
    echo -e "          Example: -s \"warning\"\n"
    echo -e "    -c    Slack channel you are posting to"
    echo -e "          Example: -c \"#alerts-channel\"\n"
    echo -e "    -w    Slack webhook url to post to"
    echo -e "          Example: -w https://hooks.slack.com/services/AAAAAAAA/BBBBBBBB/CCCCCCCCCCCCCCC\n"
    echo -e "EXAMPLE"
    echo -e $0 "-a \"MySQL Alerts\" -t \"MySQL Replication Status for $(HOSTNAME)\" -m \"MySQL Slave $(HOSTNAME) has some issues\" -s \"warning\" -c \"#dba-team\" -w https://hooks.slack.com/services/AAAAAAAA/BBBBBBBB/CCCCCCCCCCCCCCC\n"
    exit 1
}

while getopts ":a:t:m:s:c:w:h" opt; do
  case ${opt} in
    a) ApplicationTitle="$OPTARG"
    ;;
    t) MessageTitle="$OPTARG"
    ;;
    m) MessageBody="$OPTARG"
    ;;
    s) MessageLevel="$OPTARG"
    ;;
    c) SlackChannel="$OPTARG"
    ;;
    w) WebhookUrl="$OPTARG"
    ;;
    h) help
    ;;
    \?) echo "Invalid argument passed -$OPTARG" >&2
    ;;
  esac
done

if [[ ! "${ApplicationTitle}"  || ! "${MessageTitle}" || ! "${MessageBody}" || ! "${MessageLevel}" || ! "${SlackChannel}" || ! "${WebhookUrl}" ]]; then
    echo ""
    echo "NOTE"
    echo "All arguments are mandatory"
    help
fi

read -d '' SlackPayLoad << EOF
{
        "channel": "#${SlackChannel}",
        "username": "${ServerName}",
        "icon_emoji": ":globe_with_meridians:",
        "attachments": [
            {
                "fallback": "${ApplicationTitle}",
                "color": "${MessageLevel}",
                "title": "${ApplicationTitle}",
                "fields": [{
                    "title": "${MessageTitle}",
                    "value": "${MessageBody}",
                    "short": false
                }]
            }
        ]
    }
EOF


SlackRequest=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${SlackPayLoad}" ${WebhookUrl})

echo "Slack request response code:" ${SlackRequest}
