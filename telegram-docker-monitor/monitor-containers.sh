#!/bin/bash
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TGM_BOT_TOKEN/sendMessage" \
        -d TGM_CHAT_ID="$TGM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML"
}

process_container_event() {
    local status="$1"
    local container="$2"
    local exit_code="$3"

    local message
    if [[ "$status" == "start" ]]; then
        message="✅ Container started: ${container}"
    else
        [[ -z "$exit_code" ]] && exit_code="N/A"
        message="💀 Container died: ${container} (${exit_code}) ${TGM_USERNAME}"
    fi

    send_telegram_message "$message"
}

# Main loop to monitor Docker events
docker events \
    --filter 'type=container' \
    --filter 'event=die' \
    --filter 'event=start' \
    --format '{{.Status}} {{.Actor.Attributes.name}} {{.Actor.Attributes.exitCode}}' | \
while read -r status container exit_code; do
    process_container_event "$status" "$container" "$exit_code"
done

