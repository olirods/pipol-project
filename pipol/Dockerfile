FROM elixir:1.16-alpine

RUN mix local.hex --force && \
    mix local.rebar --force

RUN apk add --no-cache nodejs npm git build-base

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .

RUN source .env

# RUN npm install --prefix ./assets
# RUN npm run deploy --prefix ./assets
# RUN mix phx.digest

EXPOSE 4000

CMD ["mix", "phx.server"]