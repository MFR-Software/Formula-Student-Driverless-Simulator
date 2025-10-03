#!/bin/bash

source .env
docker compose up -d
docker exec -it fsds_container tmuxinator start -p tmuxinator/offscreen.yml
docker compose down
