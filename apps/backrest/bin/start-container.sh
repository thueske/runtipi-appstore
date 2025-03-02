#!/bin/bash


# Alle gestoppten Container abrufen (Status "exited")
stoppedContainers=$(docker ps -a -q -f "status=exited")

if [ -z "$stoppedContainers" ]; then
    echo "Keine gestoppten Docker-Container gefunden."
else
    # Gestoppte Container starten
    docker start $stoppedContainers
    if [ $? -eq 0 ]; then
        echo "Docker-Container erfolgreich gestartet."
    else
        echo "Fehler: Docker-Container konnten nicht gestartet werden."
        /scripts/report-status.sh down
        exit 1
    fi
fi

exit 0
