#!/bin/bash

# Standardmäßig "DOWN", wenn kein Parameter oder ein ungültiger Wert übergeben wird.
if [ $# -eq 0 ]; then
    STATUS="down"
else
    NORMALIZED_STATUS=$(echo "$1" | tr '[:upper:]' '[:lower:]') # Konvertiere in Kleinbuchstaben
    if [[ ! "$NORMALIZED_STATUS" =~ ^(up|down)$ ]]; then
        echo "Ungültiger Status übergeben. Standardmäßig 'down' verwenden."
        STATUS="down"
    else
        STATUS="$NORMALIZED_STATUS"
    fi
fi

# Überprüfen, ob die NOTIFY_URL gesetzt ist.
if [ -z "${NOTIFY_URL}" ]; then
    echo "Fehler: Die Umgebungsvariable NOTIFY_URL ist nicht gesetzt."
    exit 2
fi

# Anpassen der URL je nach Bedingungen.
if [ "$STATUS" == "down" ] && [[ "${NOTIFY_URL}" == *ping* ]]; then
    FULL_URL="${NOTIFY_URL}/fail"
else
    FULL_URL="${NOTIFY_URL}?status=${STATUS}"
fi

# Senden der Anfrage und Überprüfung des Ergebnisses.
response=$(curl --user-agent "backrest" -s -o /dev/null -w "%{http_code}" "${FULL_URL}")

if [ "$response" -eq 200 ]; then
    echo "Erfolgreich an die Monitoring-API gesendet."
else
    echo "Fehler beim Senden an die Monitoring-API. HTTP-Statuscode: $response"
    exit 3
fi

exit 0
