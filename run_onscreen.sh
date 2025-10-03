#!/bin/bash

xhost +
source .env
docker compose up -d
docker exec -it fsds_container tmuxinator start -p tmuxinator/onscreen.yml
docker compose down
