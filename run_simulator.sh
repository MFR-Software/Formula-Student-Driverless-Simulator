#!/bin/bash

export SIM_MAP=TrainingMap
docker compose up -d
docker exec -it fsds_container tmuxinator start -p tmuxinator/default_layout.yml
docker compose down
