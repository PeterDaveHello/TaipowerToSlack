#!/usr/bin/env bash

set -e

function echo.Cyan() { echo -e "\033[36m$*\033[m"; }
function echo.BoldRed() { echo -e "\033[1;31m$*\033[m"; }
#https://github.com/PeterDaveHello/ColorEchoForShell

SRC="https://www.taipower.com.tw/d006/loadGraph/loadGraph/data/loadpara.json"
STATELESS="${STATELESS:-true}"
ONLY_POST_ON_STATUS_CHANGE="${ONLY_POST_ON_STATUS_CHANGE:-false}"

if [ -z "$SLACK_HOOK" ]; then
    echo.BoldRed >&2 "\$SLACK_HOOK variable not set!"
    exit 1
fi

for cmd in mktemp curl jq bc; do
    if ! command -v $cmd &> /dev/null; then
        echo.BoldRed >&2 "command: $cmd not found!"
        exit 1
    fi
done

TMP_FILE="$(mktemp)"
declare -A STATUS STATUS_PIC

STATUS[G]="🟢 供電充裕"
STATUS[Y]="🟡 供電吃緊"
STATUS[O]="🟠 供電警戒"
STATUS[R]="🔴 限電警戒"
STATUS[B]="⚫️ 限電準備"

STATUS_PIC[G]="01-green"
STATUS_PIC[Y]="02-yellow"
STATUS_PIC[O]="03-orange"
STATUS_PIC[R]="04-red"
STATUS_PIC[B]="05-black"

curl -sLo "$TMP_FILE" "$SRC"

if [ "true" != "$(jq -r .success "$TMP_FILE")" ]; then
    echo.BoldRed >&2 "Something wrong from the data source!"
    exit 1
fi

data="$(jq -c .records "$TMP_FILE")"
curr_load="$(jq -r '.[0].curr_load' <<< "$data")"
curr_util_rate="$(jq -r '.[0].curr_util_rate' <<< "$data")"
fore_maxi_sply_capacity="$(jq -r '.[1].fore_maxi_sply_capacity' <<< "$data")"
fore_peak_dema_load="$(jq -r '.[1].fore_peak_dema_load' <<< "$data")"
fore_peak_resv_capacity="$(jq -r '.[1].fore_peak_resv_capacity' <<< "$data")"
fore_peak_resv_rate="$(jq -r '.[1].fore_peak_resv_rate' <<< "$data")"
fore_peak_resv_indicator="$(jq -r '.[1].fore_peak_resv_indicator' <<< "$data")"
fore_peak_hour_range="$(jq -r '.[1].fore_peak_hour_range' <<< "$data")"
real_hr_maxi_sply_capacity="$(jq -r '.[3].real_hr_maxi_sply_capacity' <<< "$data")"
publish_time="$(jq -r '.[1].publish_time' <<< "$data")"

text="
今日電力資訊 *${STATUS[$fore_peak_resv_indicator]}*\n
( $publish_time 更新 )\n\n
目前用電量： $curr_load 萬瓩
目前供電能力： $real_hr_maxi_sply_capacity 萬瓩
目前使用率： $curr_util_rate%
尖峰使用率： $(echo "$fore_peak_dema_load * 100 / $fore_maxi_sply_capacity" | bc)%
預估最高用電： $fore_peak_dema_load 萬瓩
預估最高用電時段： $fore_peak_hour_range
預估最大供電能力： $fore_maxi_sply_capacity 萬瓩
預估尖峰備轉容量率： $fore_peak_resv_rate%
預估尖峰備轉容量： $fore_peak_resv_capacity 萬瓩"

rm -f "$TMP_FILE"

if [ "$STATELESS" != "true" ]; then
    function update_status() {
        echo "{\"latest_status\":\"$fore_peak_resv_indicator\",\"update_on\":\"$publish_time\"}" > "$STATUS_FILE"
    }
    STATUS_FILE="$HOME/.taipower.status"
    if [ -e "$STATUS_FILE" ]; then
        previous_status="$(jq -r .latest_status "$STATUS_FILE")"
        if [ "$fore_peak_resv_indicator" != "$previous_status" ]; then
            text="$text

上次狀態： ${STATUS[$previous_status]}
上次狀態改變時間： $(jq -r .update_on "$STATUS_FILE")
"
            update_status
        else
            if [ "$ONLY_POST_ON_STATUS_CHANGE" = "true" ]; then
                echo.Cyan "Status not changed, won't post to Slack!"
                POST_TO_SLACK="false"
            fi
        fi
    else
        update_status
    fi
fi

mrkdown="{
    'blocks': [
        {
            'type': 'section',
            'block_id': 'section567',
            'text': { 'type': 'mrkdwn', 'text': '$text' },
            'accessory': {
                'type': 'image',
                'image_url': 'https://www.taipower.com.tw/d006/loadGraph/loadGraph/images/${STATUS_PIC[$fore_peak_resv_indicator]}.png',
                'alt_text': '${STATUS[$fore_peak_resv_indicator]}'
            }
        }
    ]
}"

echo.Cyan "$text"

if [ "$POST_TO_SLACK" != "false" ]; then
    curl -s --fail -o /dev/null -X POST -H 'Content-type: application/json' --data "$mrkdown" "$SLACK_HOOK"
fi
