#!/bin/bash
project_dir="/home/app/fun.master"

printf "create and migrate db start"
cd "$project_dir" && mix ecto.create && mix ecto.migrate
printf "create and migrate db finish"

printf "run server"
cd "$project_dir" && mix compile --force
elixir --detached -S mix phx.server
/etc/init.d/nginx start
