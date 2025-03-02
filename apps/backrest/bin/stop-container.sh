#!/bin/bash

# Überprüfen, ob die NOTIFY_URL gesetzt ist
if [ -z "${NOTIFY_URL}" ]; then
    echo "Fehler: Die Umgebungsvariable NOTIFY_URL ist nicht gesetzt."
    exit 2
fi

# Wenn NOTIFY_URL das Wort "ping" enthält, sende einen Start-Request
if [[ "${NOTIFY_URL}" == *ping* ]]; then
    FULL_URL="${NOTIFY_URL}/start"
    response=$(curl --user-agent "backrest" -s -o /dev/null -w "%{http_code}" "${FULL_URL}")
    if [ "$response" -eq 200 ]; then
        echo "Start-Notification erfolgreich an ${FULL_URL} gesendet."
    else
        echo "Fehler beim Senden der Start-Notification. HTTP-Statuscode: $response"
        exit 3
    fi
fi

# Alle Container abrufen
allContainers=$(docker ps -q)

# Variable zum Sammeln der Container-IDs, die gestoppt werden sollen
stopContainers=""

# Über jeden Container iterieren
for container in $allContainers; do
    # Das Image des Containers ermitteln
    image=$(docker inspect --format '{{.Config.Image}}' "$container")

    # Wenn das Image NICHT "garethgeorge/backrest" ist, Container zur Stoppliste hinzufügen
    if [ "$image" != "garethgeorge/backrest" ]; then
        stopContainers="$stopContainers $container"
    fi
done

# Prüfen, ob es Container zum Stoppen gibt
if [ -z "$stopContainers" ]; then
    echo "Keine Docker-Container gefunden, die gestoppt werden sollen."
else
    # Container stoppen
    docker stop $stopContainers
    if [ $? -eq 0 ]; then
        echo "Docker-Container erfolgreich gestoppt."
    else
        echo "Fehler: Docker-Container konnten nicht gestoppt werden."
        /scripts/report-status.sh down
        exit 1
    fi
fi

exit 0
