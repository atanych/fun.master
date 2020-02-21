FROM forfunfun/base-elixir:0.1.0

RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default

# Create and set home directory
ENV HOME /home/app/fun.master
WORKDIR $HOME
ADD . /home/app/fun.master
RUN mkdir -p tmp content
RUN chmod 400 devops/origin.key
RUN chmod 400 devops/workers/workers.key

ENV MIX_ENV prod

# Set and expose PORT environmental variable
ENV PORT 4000

# Install hex (Elixir package manager)
RUN mix local.hex --force

# Install rebar (Erlang build tool)
RUN mix local.rebar --force

# Install all production dependencies
RUN mix deps.get --only prod
RUN mix compile

EXPOSE 80

# Run Ecto migrations and Phoenix server as an initial command
ENTRYPOINT ./app_start.sh
