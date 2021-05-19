#!/usr/bin/env bash

set -e

function echo.Cyan() { echo -e "\033[36m$*\033[m"; }
function echo.BoldRed() { echo -e "\033[1;31m$*\033[m"; }
#https://github.com/PeterDaveHello/ColorEchoForShell

SRC="https://www.taipower.com.tw/d006/loadGraph/loadGraph/data/loadpara.json"

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

cat <<< "$(jq -c .records "$TMP_FILE")" > "$TMP_FILE"

curr_load="$(jq -r '.[0].curr_load' "$TMP_FILE")"
curr_util_rate="$(jq -r '.[0].curr_util_rate' "$TMP_FILE")"
fore_maxi_sply_capacity="$(jq -r '.[1].fore_maxi_sply_capacity' "$TMP_FILE")"
fore_peak_dema_load="$(jq -r '.[1].fore_peak_dema_load' "$TMP_FILE")"
fore_peak_resv_capacity="$(jq -r '.[1].fore_peak_resv_capacity' "$TMP_FILE")"
fore_peak_resv_rate="$(jq -r '.[1].fore_peak_resv_rate' "$TMP_FILE")"
fore_peak_resv_indicator="$(jq -r '.[1].fore_peak_resv_indicator' "$TMP_FILE")"
fore_peak_hour_range="$(jq -r '.[1].fore_peak_hour_range' "$TMP_FILE")"
publish_time="$(jq -r '.[1].publish_time' "$TMP_FILE")"

text="
今日電力資訊 *${STATUS[$fore_peak_resv_indicator]}*\n
( $publish_time 更新 )\n\n
目前用電量： $curr_load 萬瓩
目前使用率： $curr_util_rate%
尖峰使用率： $(echo "$fore_peak_dema_load * 100 / $fore_maxi_sply_capacity" | bc)%
預估最高用電： $fore_peak_dema_load 萬瓩
預估最高用電時段： $fore_peak_hour_range
最大供電能力： $fore_maxi_sply_capacity 萬瓩
預估尖峰備轉容量率： $fore_peak_resv_rate%
預估尖峰備轉容量： $fore_peak_resv_capacity 萬瓩"

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
curl -s --fail -o /dev/null -X POST -H 'Content-type: application/json' --data "$mrkdown" "$SLACK_HOOK"

rm -f "$TMP_FILE"
