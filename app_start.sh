#!/bin/bash
project_dir="/home/app/fun.master"

printf "run server"
cd "$project_dir" && mix phx.digest && mix compile --force
elixir --name "master@$POD_IP" --cookie master --detached -S mix phx.server
/etc/init.d/nginx start
